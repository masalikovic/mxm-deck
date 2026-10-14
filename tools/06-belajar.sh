#!/usr/bin/env bash
# tools/06-belajar.sh — kategori: Belajar & eksperimen
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$DIR/lib/warna.sh"
. "$DIR/lib/banner.sh"
. "$DIR/lib/layar.sh"
. "$DIR/lib/pasang.sh"

TOOLS=(
  "rust|Bahasa yang dipakai gb-core|pkg|rust"
  "clang + make|Kompilasi program C kecil|pkg|clang make"
  "figlet / toilet|Buat banner ASCII sendiri|pkg|figlet toilet"
  "asciinema|Rekam sesi terminal|pip|asciinema"
)

mxm_kategori "Belajar & eksperimen"
