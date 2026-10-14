#!/usr/bin/env bash
# tests/jalankan.sh — jalankan semua uji MXM Deck (dipakai juga oleh CI).
#
#   bash tests/jalankan.sh
#
# Pemeriksaan shellcheck dan uji layar (python + pyte) dilewati bila alatnya tidak ada,
# kecuali MXM_UJI_KETAT=1 (di CI): alat yang hilang dianggap gagal.
set -uo pipefail
AKAR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$AKAR" || exit 1
PYTHON=${PYTHON:-python3}
hasil=0

lewati() {
  if [[ "${MXM_UJI_KETAT:-0}" == 1 ]]; then
    echo "GAGAL: $1 (MXM_UJI_KETAT=1)"; hasil=1
  else
    echo "lewati: $1"
  fi
}

echo "### shellcheck"
if command -v shellcheck >/dev/null; then
  shellcheck -x deck.sh lib/*.sh tools/*.sh tests/*.sh tests/palsu/* && echo "bersih" || hasil=1
else
  lewati "shellcheck tidak terpasang"
fi

echo; echo "### uji dasar (menu, pasang, hapus)"
bash tests/uji_dasar.sh || hasil=1

echo; echo "### uji layar (header tetap)"
if "$PYTHON" -c 'import pyte' 2>/dev/null; then
  "$PYTHON" tests/uji_layar.py || hasil=1
else
  lewati "python/pyte tidak ada (pip install pyte)"
fi

echo
((hasil == 0)) && echo "SEMUA UJI LULUS" || echo "ADA UJI YANG GAGAL"
exit $hasil
