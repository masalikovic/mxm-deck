# shellcheck shell=bash
# lib/warna.sh — palet MXM untuk terminal.
#
#   Latar   hitam tinta     #0e0e0e
#   Utama   cream           #f5ebd7  ≈ 256-warna 223
#   Aksen   oranye          #ff8a3d  ≈ 256-warna 215
#   Sekunder abu-abu tenang #8a857c  ≈ 256-warna 245
#
# Warna dimatikan otomatis kalau keluaran bukan terminal atau NO_COLOR diset.

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  MXM_ORANYE=$'\e[38;5;215m'
  MXM_CREAM=$'\e[38;5;223m'
  MXM_ABU=$'\e[38;5;245m'
  MXM_MERAH=$'\e[38;5;203m'
  MXM_TEBAL=$'\e[1m'
  MXM_RESET=$'\e[0m'
else
  MXM_ORANYE='' MXM_CREAM='' MXM_ABU='' MXM_MERAH='' MXM_TEBAL='' MXM_RESET=''
fi

mxm_teks()  { printf '%s%s%s\n' "$MXM_CREAM" "$*" "$MXM_RESET"; }
mxm_aksen() { printf '%s%s%s\n' "$MXM_ORANYE" "$*" "$MXM_RESET"; }
mxm_redup() { printf '%s%s%s\n' "$MXM_ABU" "$*" "$MXM_RESET"; }

mxm_info()  { printf '%s[*]%s %s%s%s\n' "$MXM_ORANYE" "$MXM_RESET" "$MXM_CREAM" "$*" "$MXM_RESET"; }
mxm_ok()    { printf '%s[+]%s %s%s%s\n' "$MXM_ORANYE" "$MXM_RESET" "$MXM_CREAM" "$*" "$MXM_RESET"; }
mxm_warn()  { printf '%s[!]%s %s%s%s\n' "$MXM_ORANYE" "$MXM_RESET" "$MXM_ABU" "$*" "$MXM_RESET"; }
mxm_galat() { printf '%s[x]%s %s%s%s\n' "$MXM_MERAH" "$MXM_RESET" "$MXM_CREAM" "$*" "$MXM_RESET" >&2; }

# Garis kotak selebar layar, paling lebar 50 kolom.
mxm_garis() {
  local n=${MXM_KOLOM:-50} s
  ((n > 50)) && n=50
  printf -v s '%*s' $((n - 2)) ''
  printf '%s+%s+%s\n' "$MXM_ABU" "${s// /-}" "$MXM_RESET"
}
