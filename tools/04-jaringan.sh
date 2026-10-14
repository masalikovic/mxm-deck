#!/usr/bin/env bash
# tools/04-jaringan.sh — kategori: Diagnostik jaringan sendiri
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$DIR/lib/warna.sh"
. "$DIR/lib/pasang.sh"

TOOLS=(
  "nmap|Daftar perangkat DI JARINGAN ANDA SENDIRI|pkg|nmap"
  "iproute2|Lihat alamat IP & rute perangkat Anda|pkg|iproute2"
  "mtr|Ping + traceroute gabungan|pkg|mtr"
  "httpie|Uji API/situs milik Anda|pkg|httpie"
  "speedtest-cli|Ukur kecepatan internet Anda|pip|speedtest-cli"
)

# Kategori ini menyangkut jaringan: minta persetujuan Aturan dulu.
echo
mxm_aksen "== Aturan jaringan =="
mxm_teks "Alat di sini HANYA boleh diarahkan ke perangkat dan jaringan"
mxm_teks "milik Anda sendiri atau yang Anda kelola dengan izin tertulis."
mxm_redup "Memindai milik orang lain tanpa izin melanggar hukum (UU ITE)."
mxm_redup "Selengkapnya: docs/ATURAN.md"
echo
if ! mxm_tanya "Saya paham dan setuju"; then
  mxm_redup "Tidak setuju — tidak ada yang dipasang."
  exit 0
fi
mxm_kategori "Diagnostik jaringan sendiri"
