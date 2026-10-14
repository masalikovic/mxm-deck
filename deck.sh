#!/usr/bin/env bash
# deck.sh — menu utama MXM Deck: banner + pilih kategori.
#
#   bash deck.sh              menu interaktif, header tetap di atas
#   bash deck.sh 3            langsung ke kategori 3
#   bash deck.sh pratinjau    tampilkan semua gaya banner
#   MXM_COBA=1 bash deck.sh   mode coba (perintah hanya ditampilkan)
#   MXM_GAYA=bayangan ...     pakai gaya banner tertentu (atau "acak")
#   MXM_HEADER=0 ...          header ikut menggulir seperti biasa
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib/warna.sh"
. "$DIR/lib/banner.sh"
. "$DIR/lib/layar.sh"

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
  printf '%s  g)%s %sGanti gaya banner%s\n' "$MXM_ORANYE" "$MXM_RESET" "$MXM_CREAM" "$MXM_RESET"
  printf '%s  a)%s %sBaca Aturan%s\n' "$MXM_ORANYE" "$MXM_RESET" "$MXM_CREAM" "$MXM_RESET"
  printf '%s  0)%s %sKeluar%s\n' "$MXM_ORANYE" "$MXM_RESET" "$MXM_CREAM" "$MXM_RESET"
  mxm_garis
}

pratinjau() {
  local nama lebar ket no=0
  while IFS='|' read -r nama lebar ket; do
    no=$((no + 1))
    echo
    printf '%s %d) %s%s%s  %s(%s · %s kolom)%s\n' "$MXM_ORANYE" "$no" "$MXM_TEBAL$MXM_CREAM" "$nama" "$MXM_RESET" \
      "$MXM_ABU" "$ket" "$lebar" "$MXM_RESET"
    mxm_seni "$nama" "${MXM_KOLOM:-80}"
  done < <(mxm_gaya_indeks)
}

pilih_gaya() {
  local daftar=() pilih g
  mapfile -t daftar < <(mxm_gaya_indeks | cut -d'|' -f1)
  pratinjau
  echo
  printf '%s %d) %sacak%s  %s(gaya berbeda tiap kali dibuka)%s\n' "$MXM_ORANYE" $((${#daftar[@]} + 1)) \
    "$MXM_TEBAL$MXM_CREAM" "$MXM_RESET" "$MXM_ABU" "$MXM_RESET"
  printf '%s[?]%s %sPilih gaya (nomor, kosong = batal): %s' "$MXM_ORANYE" "$MXM_RESET" "$MXM_CREAM" "$MXM_RESET"
  read -r pilih || return 0
  if [[ "$pilih" =~ ^[0-9]+$ ]] && ((pilih >= 1 && pilih <= ${#daftar[@]} + 1)); then
    if ((pilih == ${#daftar[@]} + 1)); then g=acak; else g=${daftar[pilih-1]}; fi
    mxm_gaya_simpan "$g"
    MXM_GAYA=$g
    unset MXM_GAYA_TERPILIH
    mxm_layar_mulai
    mxm_ok "Gaya banner: $g (tersimpan)."
  elif [[ -n "$pilih" ]]; then
    mxm_warn "Pilihan tidak dikenal: $pilih"
  fi
}

jalankan() {
  local pilih=$1 skrip
  case "$pilih" in
    [1-6])
      IFS='|' read -r skrip _ <<<"${KATEGORI[pilih-1]}"
      bash "$DIR/tools/$skrip"
      mxm_layar_pulihkan
      ;;
    g|G) pilih_gaya ;;
    pratinjau) MXM_GAYA_SIMPAN=/dev/null pratinjau ;;
    a|A)
      if command -v less >/dev/null && [[ -t 1 ]]; then
        less "$DIR/docs/ATURAN.md"
        mxm_layar_pulihkan
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

prompt() { printf '%smxm%s > %s' "$MXM_ORANYE" "$MXM_ABU" "$MXM_RESET"; }

# Baca pilihan menu; selama menunggu, gambar ulang layar bila ukurannya
# berubah (HP diputar, keyboard muncul).
_ubah=0
trap '_ubah=1' WINCH
trap 'mxm_layar_selesai' EXIT
trap 'exit 130' INT TERM
baca_pilihan() {
  local s
  while true; do
    IFS= read -r -t 1 pilih && return 0
    s=$?
    ((s > 128)) || return 1
    if ((_ubah)); then
      _ubah=0
      mxm_layar_mulai
      menu
      prompt
    fi
  done
}

mxm_layar_mulai
while true; do
  menu
  prompt
  baca_pilihan || { echo; break; }
  jalankan "$pilih" || break
  echo
done
mxm_redup "Sampai jumpa. Satu langkah per waktu."
