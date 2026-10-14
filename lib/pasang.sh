# shellcheck shell=bash
# lib/pasang.sh — pemasang bersama untuk skrip di tools/.
#
# Tiap skrip kategori mengisi array TOOLS dengan baris "nama|guna|pengelola|paket"
# (pengelola: pkg atau pip; paket boleh lebih dari satu, dipisah spasi),
# lalu memanggil mxm_kategori "Judul".
#
# Hanya pkg/pip resmi yang dipanggil. Tidak ada unduhan lain.
#
# Variabel lingkungan:
#   MXM_COBA=1   mode coba: tampilkan perintah tanpa menjalankannya
#   MXM_YA=1     lewati pertanyaan konfirmasi
#   MXM_LOG      berkas catatan (bawaan: ~/.mxm-deck/pasang.log)

MXM_LOG="${MXM_LOG:-$HOME/.mxm-deck/pasang.log}"

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

mxm_daftar() {
  local baris nama guna pengelola paket no=0
  mxm_garis
  for baris in "${TOOLS[@]}"; do
    IFS='|' read -r nama guna pengelola paket <<<"$baris"
    no=$((no + 1))
    printf '%s %2d)%s %s%-14s%s %s%s%s\n' \
      "$MXM_ORANYE" "$no" "$MXM_RESET" "$MXM_TEBAL$MXM_CREAM" "$nama" "$MXM_RESET" \
      "$MXM_ABU" "$guna" "$MXM_RESET"
  done
  mxm_garis
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
}

# Alur satu kategori: tampilkan daftar, tanya, pasang satu per satu.
mxm_kategori() {
  local judul=$1 baris nama pilih i berhasil=0 gagal=()
  echo
  mxm_aksen "== $judul =="
  mxm_daftar

  _mxm_cek_lingkungan || return 1

  printf '%s[?]%s %sPasang: [a]=semua, nomor dipisah spasi (mis. 1 3), [q]=batal: %s' \
    "$MXM_ORANYE" "$MXM_RESET" "$MXM_CREAM" "$MXM_RESET"
  if [[ "${MXM_YA:-0}" == 1 ]]; then
    pilih=a; echo a
  else
    read -r pilih || return 0
  fi

  local terpilih=()
  case "$pilih" in
    a|A) terpilih=("${TOOLS[@]}") ;;
    q|Q|'') mxm_redup "Batal."; return 0 ;;
    *)
      for i in $pilih; do
        if [[ "$i" =~ ^[0-9]+$ ]] && ((i >= 1 && i <= ${#TOOLS[@]})); then
          terpilih+=("${TOOLS[i-1]}")
        else
          mxm_warn "Abaikan pilihan tidak sah: $i"
        fi
      done
      ;;
  esac
  ((${#terpilih[@]} == 0)) && { mxm_redup "Tidak ada yang dipilih."; return 0; }

  # Langkah per langkah: satu kegagalan tidak menghentikan yang lain.
  for baris in "${terpilih[@]}"; do
    IFS='|' read -r nama _ <<<"$baris"
    if mxm_pasang_satu "$baris"; then
      berhasil=$((berhasil + 1))
      [[ "${MXM_COBA:-0}" == 1 ]] || _mxm_catat "OK    $judul  $nama"
    else
      gagal+=("$nama")
      _mxm_catat "GAGAL $judul  $nama"
    fi
  done

  echo
  mxm_ok "Selesai: $berhasil berhasil."
  if ((${#gagal[@]})); then
    mxm_warn "Gagal: ${gagal[*]} (lihat pesan di atas)."
    return 1
  fi
}
