#!/usr/bin/env bash
# tests/uji_dasar.sh — uji alur menu, pasang & hapus tanpa terminal.
#
# Memakai pkg/dpkg/pip palsu di tests/palsu/ yang mencatat status ke berkas,
# jadi aman dijalankan di mana saja dan tidak memasang apa pun sungguhan.
# Pola "kondisi && ok || salah" aman di sini: ok selalu berhasil.
# shellcheck disable=SC2015
set -uo pipefail
AKAR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

lulus=0 gagal=0
ok()    { lulus=$((lulus + 1)); printf '  ok   %s\n' "$1"; }
salah() { gagal=$((gagal + 1)); printf '  GAGAL %s\n' "$1"; [[ -n "${2:-}" ]] && printf '%s\n' "$2" | sed 's/^/        | /'; }

# Siapkan HOME & status bersih untuk satu kasus.
baru() {
  rm -rf "${TMP:?}/home" "${TMP:?}/status" "${TMP:?}/status.log"
  mkdir -p "$TMP/home"
  : >"$TMP/status"
}

# deck <input> <argumen deck.sh...>  → keluaran di $KELUAR
deck() {
  local input=$1; shift
  KELUAR=$(printf '%b' "$input" | env HOME="$TMP/home" NO_COLOR=1 \
    MXM_UJI_STATUS="$TMP/status" PATH="$AKAR/tests/palsu:$PATH" \
    bash "$AKAR/deck.sh" "$@" 2>&1)
}

ada()   { grep -qx "$1" "$TMP/status"; }
punya() { grep -qF -- "$1" <<<"$KELUAR"; }

echo "== sintaks"
for f in "$AKAR"/deck.sh "$AKAR"/lib/*.sh "$AKAR"/tools/*.sh; do
  if bash -n "$f" 2>/dev/null; then ok "bash -n ${f#"$AKAR"/}"; else salah "bash -n ${f#"$AKAR"/}"; fi
done

echo "== banner"
deck '' pratinjau
n=$(grep -c '^ [0-9]) ' <<<"$KELUAR")
[[ "$n" == 7 ]] && ok "pratinjau menampilkan 7 gaya" || salah "pratinjau menampilkan 7 gaya (dapat $n)" "$KELUAR"
for g in "$AKAR"/seni/*-mxm.txt; do
  nama=$(basename "$g" -mxm.txt)
  grep -q "^$nama|" "$AKAR/seni/gaya.txt" && [[ -f "$AKAR/seni/$nama-deck.txt" ]] \
    && ok "gaya $nama terdaftar & lengkap" || salah "gaya $nama terdaftar & lengkap"
done
baru; deck '0\n'
punya '|_|  |_/_/\_\_|  |_|' && ok "tanpa terminal: banner standar dicetak biasa" || salah "banner standar tanpa terminal" "$KELUAR"
baru; MXM_GAYA=tidak-ada deck '0\n'
punya '|_|  |_/_/\_\_|  |_|' && ok "gaya tak dikenal → standar" || salah "gaya tak dikenal → standar" "$KELUAR"

echo "== pasang"
baru; deck '1 3\n' 2
ada pkg:rsync && ada pkg:tar && ada pkg:zip && ! ada pkg:fd \
  && ok "pilih 1 3 memasang rsync, tar, zip saja" || salah "pilih 1 3" "$(cat "$TMP/status")"
grep -q 'OK    File, arsip & cadangan  rsync' "$TMP/home/.mxm-deck/pasang.log" 2>/dev/null \
  && ok "hasil dicatat di pasang.log" || salah "hasil dicatat di pasang.log"

deck 'q\n' 2
punya ' 1) ✓ rsync' && ok "✓ untuk alat terpasang" || salah "✓ untuk alat terpasang" "$KELUAR"
punya ' 4)   fd' && ok "tanpa tanda untuk alat belum terpasang" || salah "tanpa tanda untuk fd" "$KELUAR"
sed -i '/^pkg:zip$/d' "$TMP/status"; deck 'q\n' 2
punya ' 3) ~ tar / zip' && ok "~ untuk terpasang sebagian" || salah "~ untuk terpasang sebagian" "$KELUAR"

deck 'a\n' 2
punya 'rsync sudah terpasang.' && ok "yang sudah ada dilewati" || salah "yang sudah ada dilewati" "$KELUAR"

baru; MXM_UJI_GAGAL=fd deck 'a\n' 2
ada pkg:ripgrep && ! ada pkg:fd && punya 'Gagal: fd' \
  && ok "satu gagal tidak menghentikan yang lain" || salah "satu gagal tidak menghentikan yang lain" "$KELUAR"

baru; MXM_COBA=1 deck 'a\n' 2
[[ ! -s "$TMP/status" ]] && punya '$ pkg install -y rsync' \
  && ok "mode coba tidak memasang apa pun" || salah "mode coba" "$KELUAR"

baru; KELUAR=$(printf 'a\n' | env HOME="$TMP/home" NO_COLOR=1 PATH=/usr/bin:/bin bash "$AKAR/deck.sh" 2 2>&1)
grep -qF "Perintah 'pkg' tidak ditemukan" <<<"$KELUAR" && ok "tanpa pkg → pesan jelas" || salah "tanpa pkg" "$KELUAR"

echo "== aturan jaringan"
baru; deck 'n\na\n' 4
[[ ! -s "$TMP/status" ]] && punya 'tidak ada yang dipasang' \
  && ok "menolak Aturan → tidak memasang" || salah "menolak Aturan" "$KELUAR"
baru; deck 'y\n1\n' 4
ada pkg:nmap && ok "menyetujui Aturan → memasang" || salah "menyetujui Aturan" "$KELUAR"

echo "== hapus"
baru; printf 'pkg:rsync\npkg:fd\n' >"$TMP/status"; deck 'h\n1\ny\n' 2
! ada pkg:rsync && ada pkg:fd && ok "hapus 1 menghapus rsync saja" || salah "hapus rsync" "$KELUAR"
grep -q 'pkg-palsu uninstall rsync$' "$TMP/status.log" \
  && ok "pkg uninstall dipanggil tanpa -y" || salah "pkg uninstall tanpa -y" "$(cat "$TMP/status.log")"
grep -q 'HAPUS File, arsip & cadangan  rsync' "$TMP/home/.mxm-deck/pasang.log" \
  && ok "penghapusan dicatat" || salah "penghapusan dicatat"

baru; printf 'pkg:rsync\n' >"$TMP/status"; deck 'h\n1\nn\n' 2
ada pkg:rsync && ok "menjawab n → batal menghapus" || salah "batal menghapus" "$KELUAR"

baru; printf 'pkg:termux-tools\n' >"$TMP/status"; deck 'h\n4\ny\n' 1
ada pkg:termux-tools && punya 'termux-tools dibutuhkan Termux' \
  && ok "termux-tools dilindungi" || salah "termux-tools dilindungi" "$KELUAR"

baru; printf 'pkg:tar\npkg:zip\n' >"$TMP/status"; deck 'h\n3\ny\n' 2
ada pkg:tar && ! ada pkg:zip && ok "tar dilindungi, zip tetap dihapus" || salah "tar/zip" "$KELUAR"

baru; printf 'pip:csvkit\n' >"$TMP/status"; deck 'h\n6\ny\n' 3
! ada pip:csvkit && grep -q 'pip-palsu uninstall csvkit$' "$TMP/status.log" \
  && ok "hapus paket pip" || salah "hapus paket pip" "$KELUAR"

baru; deck 'h\n1\ny\n' 2
punya 'rsync: tidak ada yang perlu dihapus' && ok "hapus alat yang belum ada → dilewati" || salah "hapus yang belum ada" "$KELUAR"

baru; printf 'pkg:rsync\n' >"$TMP/status"; MXM_COBA=1 deck 'h\n1\ny\n' 2
ada pkg:rsync && punya '$ pkg uninstall rsync' && ok "mode coba tidak menghapus" || salah "mode coba hapus" "$KELUAR"

echo
echo "Lulus: $lulus  Gagal: $gagal"
((gagal == 0))
