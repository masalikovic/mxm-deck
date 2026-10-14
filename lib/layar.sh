# shellcheck shell=bash
# lib/layar.sh — header MXM yang tetap di atas layar.
#
# Caranya: header dicetak di baris teratas, lalu "scroll region" terminal
# (kode ANSI DECSTBM, \e[atas;bawahr) dibatasi ke baris di bawahnya. Semua
# keluaran berikutnya — menu, pkg install, pip — hanya menggulir di area
# bawah, sementara header diam di tempat.
#
# Beberapa program (apt, less, htop) mengatur ulang scroll region; panggil
# mxm_layar_pulihkan sesudahnya. Matikan semuanya dengan MXM_HEADER=0.
#
# Butuh: lib/warna.sh dan lib/banner.sh sudah di-source.

# Sisa baris minimum untuk area gulir di bawah header.
MXM_SISA_MIN=10
_MXM_HEADER=()

_mxm_ukuran() {
  local s
  s=$(stty size 2>/dev/null </dev/tty) || s=
  MXM_BARIS=${s% *} MXM_KOLOM=${s#* }
  [[ "$MXM_BARIS" =~ ^[1-9][0-9]*$ ]] || MXM_BARIS=${LINES:-24}
  [[ "$MXM_KOLOM" =~ ^[1-9][0-9]*$ ]] || MXM_KOLOM=${COLUMNS:-80}
  export MXM_BARIS MXM_KOLOM
}

# Gaya yang muat di layar: pilihan pengguna, lalu "tipis", lalu "polos".
_mxm_gaya_muat() {
  local g=$1 tinggi
  for g in "$g" tipis polos; do
    [[ "$g" == polos ]] && { echo polos; return; }
    case "$g" in gameboy) tinggi=9 ;; *) tinggi=$(($(wc -l <"$MXM_SENI/$g-mxm.txt") + 3)) ;; esac
    if (($(mxm_gaya_lebar "$g") <= MXM_KOLOM && MXM_BARIS - tinggi >= MXM_SISA_MIN)); then
      echo "$g"; return
    fi
  done
}

# Teks header: seni + baris info (dipotong selebar layar) + garis.
mxm_header_teks() {
  local gaya muat info n=$((MXM_KOLOM - 11))
  gaya=${MXM_GAYA_TERPILIH:-$(mxm_gaya_pilihan)}
  muat=$(_mxm_gaya_muat "$gaya")
  mxm_seni "$muat" "$MXM_KOLOM"
  if [[ "$muat" != gameboy ]]; then
    info="MXM Deck · gaya: $muat"
    [[ "$muat" != "$gaya" ]] && info="MXM Deck · $muat (sempit)"
    printf '%s+ -- -- =[%s %s%s\n' "$MXM_ABU" "$MXM_CREAM" "${info:0:n}" "$MXM_RESET"
    info="Hanya perangkat & data sendiri"
    printf '%s+ -- -- =[%s %s%s\n' "$MXM_ABU" "$MXM_CREAM" "${info:0:n}" "$MXM_RESET"
  fi
  mxm_garis
}

_mxm_header_gambar() {
  local baris
  printf '\e[r\e[H'
  for baris in "${_MXM_HEADER[@]}"; do
    printf '%s\e[K\n' "$baris"
  done
  printf '\e[%d;%dr' $((MXM_HEADER_TINGGI + 1)) "$MXM_BARIS"
}

mxm_layar_bisa() { [[ -t 1 && "${MXM_HEADER:-1}" != 0 ]]; }

# Bersihkan layar, pasang header tetap, kursor ke awal area gulir.
mxm_layar_mulai() {
  if ! mxm_layar_bisa; then
    mxm_banner
    return
  fi
  _mxm_ukuran
  export MXM_GAYA_TERPILIH=${MXM_GAYA_TERPILIH:-$(mxm_gaya_pilihan)}
  mapfile -t _MXM_HEADER < <(mxm_header_teks)
  MXM_HEADER_TINGGI=${#_MXM_HEADER[@]}
  if ((MXM_BARIS - MXM_HEADER_TINGGI < MXM_SISA_MIN)); then
    # Layar terlalu pendek untuk header tetap: cetak biasa saja.
    printf '\e[r\e[H\e[2J'
    printf '%s\n' "${_MXM_HEADER[@]}"
    MXM_LAYAR_AKTIF=0
    return
  fi
  printf '\e[2J'
  _mxm_header_gambar
  printf '\e[%d;1H' $((MXM_HEADER_TINGGI + 1))
  export MXM_LAYAR_AKTIF=1 MXM_HEADER_TINGGI
}

# Gambar ulang header & scroll region tanpa menghapus area bawah.
# Dipakai sesudah program yang mungkin mengatur ulang terminal.
mxm_layar_pulihkan() {
  [[ "${MXM_LAYAR_AKTIF:-0}" == 1 ]] && mxm_layar_bisa || return 0
  local b=$MXM_BARIS k=$MXM_KOLOM
  _mxm_ukuran
  if [[ "$b" != "$MXM_BARIS" || "$k" != "$MXM_KOLOM" || ${#_MXM_HEADER[@]} -eq 0 ]]; then
    # Ukuran berubah (atau dipanggil dari proses anak): susun ulang header.
    mapfile -t _MXM_HEADER < <(mxm_header_teks)
    MXM_HEADER_TINGGI=${#_MXM_HEADER[@]}
  fi
  printf '\e7'
  _mxm_header_gambar
  printf '\e8'
  # Jangan biarkan kursor tertinggal di dalam header.
  local baris
  baris=$(_mxm_baris_kursor)
  if [[ -z "$baris" ]]; then
    printf '\e[%d;1H' "$MXM_BARIS"
  elif ((baris <= MXM_HEADER_TINGGI)); then
    printf '\e[%d;1H' $((MXM_HEADER_TINGGI + 1))
  fi
}

# Baris kursor saat ini (tanya terminal lewat \e[6n); kosong bila tak dijawab.
_mxm_baris_kursor() {
  local jawab baris stty_lama
  stty_lama=$(stty -g </dev/tty 2>/dev/null) || return 0
  stty -echo -icanon </dev/tty 2>/dev/null
  printf '\e[6n' >/dev/tty
  IFS= read -r -s -t 1 -d R jawab </dev/tty
  stty "$stty_lama" </dev/tty 2>/dev/null
  baris=${jawab#*\[}; baris=${baris%;*}
  [[ "$baris" =~ ^[0-9]+$ ]] && echo "$baris"
}

# Kembalikan terminal ke normal (dipanggil saat keluar).
mxm_layar_selesai() {
  [[ "${MXM_LAYAR_AKTIF:-0}" == 1 ]] || return 0
  printf '\e[r\e[%d;1H' "${MXM_BARIS:-24}"
  MXM_LAYAR_AKTIF=0
}
