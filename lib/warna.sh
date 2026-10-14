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

mxm_banner() {
  printf '%s%s' "$MXM_ORANYE" "$MXM_TEBAL"
  cat <<'EOF'
 __  __ __  __ __  __     ____  _____ ____ _  __
|  \/  |\ \/ /|  \/  |   |  _ \| ____/ ___| |/ /
| |\/| | \  / | |\/| |   | | | |  _|| |   | ' /
| |  | | /  \ | |  | |   | |_| | |__| |___| . \
|_|  |_|/_/\_\|_|  |_|   |____/|_____\____|_|\_\
EOF
  printf '%s\n' "$MXM_RESET"
  printf '%s+ -- -- =[%s %s\n' "$MXM_ABU" "$MXM_CREAM" "MXM Deck · perkakas Termux eksperimen${MXM_RESET}"
  printf '%s+ -- -- =[%s %s\n' "$MXM_ABU" "$MXM_CREAM" "Gaya: orange-black-cream (identitas MXM)${MXM_RESET}"
  printf '%s+ -- -- =[%s %s\n' "$MXM_ABU" "$MXM_CREAM" "Aturan: hanya perangkat & data milik sendiri${MXM_RESET}"
  echo
}

# Garis kotak sederhana selebar 50 kolom.
mxm_garis() { printf '%s+%s+%s\n' "$MXM_ABU" "------------------------------------------------" "$MXM_RESET"; }
