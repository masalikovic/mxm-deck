#!/usr/bin/env bash
# tools/05-dev.sh — kategori: Alat pengembang
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$DIR/lib/warna.sh"
. "$DIR/lib/banner.sh"
. "$DIR/lib/layar.sh"
. "$DIR/lib/pasang.sh"

TOOLS=(
  "git|Versi kode & kelola repo|pkg|git"
  "python|Bahasa serbaguna|pkg|python"
  "nodejs|JavaScript/alat web|pkg|nodejs"
  "micro|Editor teks ramah pemula|pkg|micro"
  "openssh|SSH ke server milik Anda sendiri|pkg|openssh"
)

mxm_kategori "Alat pengembang"
