#!/usr/bin/env bash
# tools/02-file.sh — kategori: File, arsip & cadangan
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
. "$DIR/lib/warna.sh"
. "$DIR/lib/pasang.sh"

TOOLS=(
  "rsync|Salin/sinkron file milik Anda|pkg|rsync"
  "rclone|Cadangkan ke cloud akun Anda sendiri|pkg|rclone"
  "tar / zip|Arsipkan folder|pkg|tar zip"
  "fd|Cari file dengan cepat|pkg|fd"
  "ripgrep|Cari isi file dengan cepat (rg)|pkg|ripgrep"
)

mxm_kategori "File, arsip & cadangan"
