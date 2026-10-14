# shellcheck shell=bash
# lib/pasang.sh — pemasang bersama untuk skrip di tools/.
#
# Tiap skrip kategori mengisi array TOOLS dengan baris "nama|guna|pengelola|paket"
# (pengelola: pkg atau pip; paket boleh lebih dari satu, dipisah spasi),
# lalu memanggil mxm_kategori "Judul".
#
# Hanya pkg/pip resmi yang dipanggil. Tidak ada unduhan lain.
#
# Menghapus memakai "pkg uninstall"/"pip uninstall" tanpa -y, jadi apt/pip
# tetap menampilkan apa saja yang ikut terhapus dan meminta konfirmasi.
# Paket inti Termux di MXM_LINDUNGI tidak pernah dihapus lewat menu.
#
# Variabel lingkungan:
#   MXM_COBA=1   mode coba: tampilkan perintah tanpa menjalankannya
#   MXM_YA=1     lewati pertanyaan konfirmasi
#   MXM_LOG      berkas catatan (bawaan: ~/.mxm-deck/pasang.log)

MXM_LOG="${MXM_LOG:-$HOME/.mxm-deck/pasang.log}"

# Dibutuhkan Termux sendiri (pkg ada di termux-tools; dpkg butuh tar).
MXM_LINDUNGI=(termux-tools tar)
_MXM_TERPILIH=()

_mxm_catat() {
  mkdir -p "$(dirname "$MXM_LOG")" 2>/dev/null || return 0
  printf '%s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$MXM_LOG" 2>/dev/null || true
}

_mxm_jalankan() {
  mxm_redup "    \$ $*"
  if [[ "${MXM_COBA:-0}" == 1 ]]; then
    return 0
  fi
  "$@"
}

_mxm_sudah_ada() {
  local pengelola=$1 paket=$2
  case "$pengelola" in
    pkg) command -v dpkg >/dev/null && dpkg -s "$paket" >/dev/null 2>&1 ;;
    pip) command -v pip >/dev/null && pip show "$paket" >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}

_mxm_cek_lingkungan() {
  if [[ "${MXM_COBA:-0}" == 1 ]]; then
    mxm_warn "Mode coba: perintah hanya ditampilkan, tidak dijalankan."
    return 0
  fi
  if ! command -v pkg >/dev/null; then
    mxm_galat "Perintah 'pkg' tidak ditemukan. MXM Deck dibuat untuk Termux."
    mxm_redup "    Jalankan dengan MXM_COBA=1 untuk melihat perintahnya saja."
    return 1
  fi
}

mxm_tanya() {
  local jawab
  [[ "${MXM_YA:-0}" == 1 ]] && return 0
  printf '%s[?]%s %s%s [y/N] %s' "$MXM_ORANYE" "$MXM_RESET" "$MXM_CREAM" "$1" "$MXM_RESET"
  read -r jawab || return 1
  [[ "$jawab" == [yY] || "$jawab" == [yY][aA] ]]
}

# Status satu baris TOOLS: "semua" (✓), "sebagian" (~), atau "belum".
_mxm_status() {
  local pengelola=$1 paket=$2 p ada=0 total=0
  for p in $paket; do
    total=$((total + 1))
    _mxm_sudah_ada "$pengelola" "$p" && ada=$((ada + 1))
  done
  if ((ada == total)); then echo semua
  elif ((ada > 0)); then echo sebagian
  else echo belum
  fi
}

mxm_daftar() {
  local baris nama guna pengelola paket no=0 tanda
  mxm_garis
  for baris in "${TOOLS[@]}"; do
    IFS='|' read -r nama guna pengelola paket <<<"$baris"
    no=$((no + 1))
    case $(_mxm_status "$pengelola" "$paket") in
      semua) tanda="${MXM_ORANYE}✓" ;;
      sebagian) tanda="${MXM_ABU}~" ;;
      *) tanda=" " ;;
    esac
    printf '%s %2d)%s %s%s %s%-14s%s %s%s%s\n' \
      "$MXM_ORANYE" "$no" "$MXM_RESET" "$tanda" "$MXM_RESET" "$MXM_TEBAL$MXM_CREAM" "$nama" "$MXM_RESET" \
      "$MXM_ABU" "$guna" "$MXM_RESET"
  done
  mxm_garis
  mxm_redup "  ✓ terpasang   ~ sebagian"
}

# Ubah "1 3 5" menjadi baris-baris TOOLS di array _MXM_TERPILIH.
_mxm_pilih_nomor() {
  local i
  _MXM_TERPILIH=()
  for i in $1; do
    if [[ "$i" =~ ^[0-9]+$ ]] && ((i >= 1 && i <= ${#TOOLS[@]})); then
      _MXM_TERPILIH+=("${TOOLS[i-1]}")
    else
      mxm_warn "Abaikan pilihan tidak sah: $i"
    fi
  done
}

_mxm_dilindungi() {
  local p
  for p in "${MXM_LINDUNGI[@]}"; do
    [[ "$p" == "$1" ]] && return 0
  done
  return 1
}

# Pasang satu baris TOOLS. Kembali 0 bila berhasil/sudah ada.
mxm_pasang_satu() {
  local nama guna pengelola paket p perlu=()
  IFS='|' read -r nama guna pengelola paket <<<"$1"

  for p in $paket; do
    _mxm_sudah_ada "$pengelola" "$p" || perlu+=("$p")
  done
  if ((${#perlu[@]} == 0)); then
    mxm_ok "$nama sudah terpasang."
    return 0
  fi

  mxm_info "Memasang $nama ..."
  case "$pengelola" in
    pkg) _mxm_jalankan pkg install -y "${perlu[@]}" ;;
    pip) _mxm_jalankan pip install "${perlu[@]}" ;;
    *) mxm_galat "Pengelola tidak dikenal: $pengelola"; return 1 ;;
  esac
  local hasil=$?
  # apt suka mengatur ulang scroll region; pasang lagi header tetap.
  declare -F mxm_layar_pulihkan >/dev/null && mxm_layar_pulihkan
  return $hasil
}

# Hapus satu baris TOOLS (hanya paket yang terpasang & tidak dilindungi).
mxm_hapus_satu() {
  local nama guna pengelola paket p hapus=()
  IFS='|' read -r nama guna pengelola paket <<<"$1"

  for p in $paket; do
    if _mxm_dilindungi "$p"; then
      mxm_warn "$p dibutuhkan Termux, tidak dihapus."
    elif _mxm_sudah_ada "$pengelola" "$p"; then
      hapus+=("$p")
    fi
  done
  if ((${#hapus[@]} == 0)); then
    mxm_redup "$nama: tidak ada yang perlu dihapus."
    return 0
  fi

  mxm_info "Menghapus $nama ..."
  case "$pengelola" in
    pkg) _mxm_jalankan pkg uninstall "${hapus[@]}" ;;
    pip) _mxm_jalankan pip uninstall "${hapus[@]}" ;;
    *) mxm_galat "Pengelola tidak dikenal: $pengelola"; return 1 ;;
  esac
  local hasil=$?
  declare -F mxm_layar_pulihkan >/dev/null && mxm_layar_pulihkan
  return $hasil
}

# Jalankan aksi (pasang/hapus) untuk tiap baris di _MXM_TERPILIH.
_mxm_proses() {
  local judul=$1 aksi=$2 baris nama berhasil=0 gagal=() fungsi=mxm_pasang_satu label=OK
  [[ "$aksi" == hapus ]] && fungsi=mxm_hapus_satu label=HAPUS

  # Langkah per langkah: satu kegagalan tidak menghentikan yang lain.
  for baris in "${_MXM_TERPILIH[@]}"; do
    IFS='|' read -r nama _ <<<"$baris"
    if "$fungsi" "$baris"; then
      berhasil=$((berhasil + 1))
      [[ "${MXM_COBA:-0}" == 1 ]] || _mxm_catat "$(printf '%-5s' "$label") $judul  $nama"
    else
      gagal+=("$nama")
      _mxm_catat "GAGAL $judul  $nama ($aksi)"
    fi
  done

  echo
  mxm_ok "Selesai: $berhasil berhasil."
  if ((${#gagal[@]})); then
    mxm_warn "Gagal: ${gagal[*]} (lihat pesan di atas)."
    return 1
  fi
}

_mxm_menu_hapus() {
  local judul=$1 pilih baris nama nama_semua=()
  printf '%s[?]%s %sHapus nomor (mis. 2 4), [q]=batal: %s' "$MXM_ORANYE" "$MXM_RESET" "$MXM_CREAM" "$MXM_RESET"
  read -r pilih || return 0
  [[ -z "$pilih" || "$pilih" == [qQ] ]] && { mxm_redup "Batal."; return 0; }
  _mxm_pilih_nomor "$pilih"
  ((${#_MXM_TERPILIH[@]} == 0)) && { mxm_redup "Tidak ada yang dipilih."; return 0; }
  for baris in "${_MXM_TERPILIH[@]}"; do
    IFS='|' read -r nama _ <<<"$baris"
    nama_semua+=("$nama")
  done
  mxm_warn "Yang dihapus: ${nama_semua[*]}"
  mxm_redup "    pkg/pip akan menampilkan apa saja yang ikut terhapus dan bertanya lagi."
  MXM_YA=0 mxm_tanya "Lanjut menghapus?" || { mxm_redup "Batal."; return 0; }
  _mxm_proses "$judul" hapus
}

# Alur satu kategori: tampilkan daftar, tanya, pasang/hapus satu per satu.
mxm_kategori() {
  local judul=$1 pilih
  echo
  mxm_aksen "== $judul =="
  mxm_daftar

  _mxm_cek_lingkungan || return 1

  printf '%s[?]%s %sPasang: [a]=semua, nomor (mis. 1 3) · [h]=hapus · [q]=batal: %s' \
    "$MXM_ORANYE" "$MXM_RESET" "$MXM_CREAM" "$MXM_RESET"
  if [[ "${MXM_YA:-0}" == 1 ]]; then
    pilih=a; echo a
  else
    read -r pilih || return 0
  fi

  case "$pilih" in
    a|A) _MXM_TERPILIH=("${TOOLS[@]}") ;;
    h|H) _mxm_menu_hapus "$judul"; return ;;
    q|Q|'') mxm_redup "Batal."; return 0 ;;
    *) _mxm_pilih_nomor "$pilih" ;;
  esac
  ((${#_MXM_TERPILIH[@]} == 0)) && { mxm_redup "Tidak ada yang dipilih."; return 0; }
  _mxm_proses "$judul" pasang
}
