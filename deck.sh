#!/usr/bin/env bash
# deck.sh — menu utama MXM Deck: banner + pilih kategori.
#
#   bash deck.sh            menu interaktif
#   bash deck.sh 3          langsung ke kategori 3
#   MXM_COBA=1 bash deck.sh mode coba (perintah hanya ditampilkan)
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib/warna.sh"

KATEGORI=(
  "01-dasar.sh|Dasar Termux & sistem"
  "02-file.sh|File, arsip & cadangan"
  "03-data.sh|Data pribadi"
  "04-jaringan.sh|Diagnostik jaringan sendiri"
  "05-dev.sh|Alat pengembang"
  "06-belajar.sh|Belajar & eksperimen"
)

menu() {
  local baris skrip judul no=0
  mxm_garis
  for baris in "${KATEGORI[@]}"; do
    IFS='|' read -r skrip judul <<<"$baris"
    no=$((no + 1))
    printf '%s  %d)%s %s%s%s\n' "$MXM_ORANYE" "$no" "$MXM_RESET" "$MXM_CREAM" "$judul" "$MXM_RESET"
  done
  mxm_garis
  printf '%s  a)%s %sBaca Aturan%s\n' "$MXM_ORANYE" "$MXM_RESET" "$MXM_CREAM" "$MXM_RESET"
  printf '%s  0)%s %sKeluar%s\n' "$MXM_ORANYE" "$MXM_RESET" "$MXM_CREAM" "$MXM_RESET"
  mxm_garis
}

jalankan() {
  local pilih=$1 skrip
  case "$pilih" in
    [1-6])
      IFS='|' read -r skrip _ <<<"${KATEGORI[pilih-1]}"
      bash "$DIR/tools/$skrip"
      ;;
    a|A)
      if command -v less >/dev/null && [[ -t 1 ]]; then
        less "$DIR/docs/ATURAN.md"
      else
        cat "$DIR/docs/ATURAN.md"
      fi
      ;;
    0|q|Q) return 1 ;;
    *) mxm_warn "Pilihan tidak dikenal: $pilih" ;;
  esac
  return 0
}

if (($# > 0)); then
  jalankan "$1"
  exit $?
fi

clear 2>/dev/null || true
mxm_banner
while true; do
  menu
  printf '%smxm%s > %s' "$MXM_ORANYE" "$MXM_ABU" "$MXM_RESET"
  read -r pilih || { echo; break; }
  jalankan "$pilih" || break
  echo
done
mxm_redup "Sampai jumpa. Satu langkah per waktu."
