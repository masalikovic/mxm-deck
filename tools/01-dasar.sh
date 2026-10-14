#!/usr/bin/env bash
# tools/01-dasar.sh — kategori: Dasar Termux & sistem
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$DIR/lib/warna.sh"
. "$DIR/lib/banner.sh"
. "$DIR/lib/layar.sh"
. "$DIR/lib/pasang.sh"

TOOLS=(
  "termux-api|Baterai, sensor, notifikasi (perangkat sendiri)|pkg|termux-api"
  "neofetch|Ringkasan perangkat|pkg|neofetch"
  "htop|Pantau proses & memori|pkg|htop"
  "termux-tools|Perintah bantu bawaan Termux|pkg|termux-tools"
  "tldr|Contoh singkat tiap perintah|pkg|tldr"
)

mxm_kategori "Dasar Termux & sistem"
