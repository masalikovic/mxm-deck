#!/usr/bin/env bash
# tools/03-data.sh — kategori: Data pribadi
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$DIR/lib/warna.sh"
. "$DIR/lib/pasang.sh"

TOOLS=(
  "jq|Olah file JSON|pkg|jq"
  "sqlite|Basis data kecil tanpa server|pkg|sqlite"
  "python|Bahasa untuk analisis data|pkg|python"
  "pandas|Analisis CSV/tabel (butuh python)|pip|pandas"
  "visidata|Lihat & bersihkan tabel di terminal|pip|visidata"
  "csvkit|Perkakas CSV|pip|csvkit"
)

mxm_kategori "Data pribadi"
