# shellcheck shell=bash
# lib/banner.sh — banner ASCII MXM dalam berbagai gaya.
#
# Gaya berbasis berkas ada di seni/: <gaya>-mxm.txt dan <gaya>-deck.txt,
# didaftarkan di seni/gaya.txt (nama|lebar|keterangan). Bagian MXM diwarnai
# oranye, bagian DECK cream. Gaya "gameboy" digambar oleh kode di bawah,
# lengkap dengan info perangkat seperti neofetch.
#
# Pilihan gaya: MXM_GAYA=<nama|acak>, atau yang tersimpan di ~/.mxm-deck/gaya
# (diatur lewat menu "g" di deck.sh). Bawaan: standar.
#
# Butuh: lib/warna.sh sudah di-source, dan DIR = akar repo.

MXM_SENI="${MXM_SENI:-$DIR/seni}"
MXM_GAYA_SIMPAN="$HOME/.mxm-deck/gaya"

# Baris indeks "nama|lebar|keterangan", tanpa komentar.
mxm_gaya_indeks() {
  local baris
  while IFS= read -r baris; do
    [[ -z "$baris" || "$baris" == '#'* ]] && continue
    printf '%s\n' "$baris"
  done <"$MXM_SENI/gaya.txt"
}

mxm_gaya_ada() {
  local nama
  while IFS='|' read -r nama _; do
    [[ "$nama" == "$1" ]] && return 0
  done < <(mxm_gaya_indeks)
  return 1
}

mxm_gaya_lebar() {
  local nama lebar
  while IFS='|' read -r nama lebar _; do
    [[ "$nama" == "$1" ]] && { echo "$lebar"; return; }
  done < <(mxm_gaya_indeks)
  echo 999
}

# Gaya yang dipilih pengguna: env > berkas > standar. "acak" diundi di sini.
mxm_gaya_pilihan() {
  local g="${MXM_GAYA:-}" semua=()
  [[ -z "$g" && -r "$MXM_GAYA_SIMPAN" ]] && read -r g <"$MXM_GAYA_SIMPAN"
  if [[ "$g" == acak ]]; then
    mapfile -t semua < <(mxm_gaya_indeks | cut -d'|' -f1)
    g=${semua[RANDOM % ${#semua[@]}]}
  fi
  mxm_gaya_ada "$g" || g=standar
  echo "$g"
}

mxm_gaya_simpan() {
  mkdir -p "$(dirname "$MXM_GAYA_SIMPAN")" 2>/dev/null
  printf '%s\n' "$1" >"$MXM_GAYA_SIMPAN" 2>/dev/null
}

# --- gaya berbasis berkas ------------------------------------------------

_mxm_seni_berkas() {
  local gaya=$1 m=() d=() i n l
  mapfile -t m <"$MXM_SENI/$gaya-mxm.txt"
  mapfile -t d <"$MXM_SENI/$gaya-deck.txt"
  n=${#m[@]}; ((${#d[@]} > n)) && n=${#d[@]}
  for ((i = 0; i < n; i++)); do
    l=${m[i]:-}
    if [[ "$gaya" == bayangan ]]; then
      # Blok oranye, garis bayangan abu-abu.
      l="${MXM_ABU}${l//█/${MXM_ORANYE}█${MXM_ABU}}"
    else
      l="${MXM_ORANYE}${l}"
    fi
    printf '%s%s%s%s\n' "$MXM_TEBAL" "$l" "$MXM_CREAM" "${d[i]:-}$MXM_RESET"
  done
}

# --- gaya gameboy (ala neofetch) ------------------------------------------

_mxm_info_perangkat() {
  local os up mem_t mem_a k v paket=() dpkg_info
  if command -v getprop >/dev/null; then
    os="Android $(getprop ro.build.version.release 2>/dev/null)"
  else
    os=$(uname -o 2>/dev/null || uname -s)
  fi
  if [[ -r /proc/uptime ]]; then
    read -r up _ </proc/uptime; up=${up%.*}
    if ((up >= 86400)); then
      up="$((up / 86400)) hari, $((up % 86400 / 3600)) jam"
    else
      up="$((up / 3600)) jam, $((up % 3600 / 60)) mnt"
    fi
  fi
  if [[ -r /proc/meminfo ]]; then
    while read -r k v _; do
      case $k in MemTotal:) mem_t=$v ;; MemAvailable:) mem_a=$v ;; esac
    done </proc/meminfo
  fi
  dpkg_info="${PREFIX:-/usr}/var/lib/dpkg/info"
  [[ -d "$dpkg_info" ]] || dpkg_info=/var/lib/dpkg/info
  shopt -s nullglob; paket=("$dpkg_info"/*.list); shopt -u nullglob

  printf '%s\n' \
    "${USER:-$(id -un 2>/dev/null)}@${HOSTNAME:-$(uname -n)}" \
    "OS|$os" \
    "Kernel|$(uname -r)" \
    "Uptime|${up:-?}" \
    "Paket|${#paket[@]}" \
    "Shell|bash ${BASH_VERSION%%(*}" \
    "Memori|$(((${mem_t:-0} - ${mem_a:-0}) / 1024))MiB / $((${mem_t:-0} / 1024))MiB"
}

_mxm_seni_gameboy() {
  local maks=${1:-80} seni info=() i baris kunci isi lebar_info
  seni=(
    " ,-----------. "
    " | .-------. | "
    " | |  MXM  | | "
    " | |  DECK | | "
    " | '-------' | "
    " | -+-   o o | "
    " |  '   .  . | "
    " '-----------' "
  )
  mapfile -t info < <(_mxm_info_perangkat)
  lebar_info=$((maks - 17))
  for ((i = 0; i < ${#seni[@]}; i++)); do
    printf '%s%s%s  ' "$MXM_ORANYE" "${seni[i]}" "$MXM_RESET"
    baris=${info[i]:-}
    if ((i == 0)); then
      printf '%s%s%s\n' "$MXM_TEBAL$MXM_ORANYE" "${baris:0:lebar_info}" "$MXM_RESET"
    elif [[ "$baris" == *'|'* ]]; then
      kunci=${baris%%|*}; isi=${baris#*|}
      isi=${isi:0:lebar_info - ${#kunci} - 2}
      printf '%s%s:%s %s%s%s\n' "$MXM_ORANYE" "$kunci" "$MXM_RESET" "$MXM_CREAM" "$isi" "$MXM_RESET"
    else
      echo
    fi
  done
}

# Cetak banner satu gaya. Argumen kedua: lebar maksimum (untuk gameboy).
mxm_seni() {
  case "$1" in
    gameboy) _mxm_seni_gameboy "${2:-80}" ;;
    polos) printf '%s%s[ MXM %sDECK ]%s\n' "$MXM_TEBAL" "$MXM_ORANYE" "$MXM_CREAM" "$MXM_RESET" ;;
    *) _mxm_seni_berkas "$1" ;;
  esac
}

# Banner lengkap (seni + baris info) untuk dicetak biasa, tanpa header tetap.
mxm_banner() {
  mxm_seni "$(mxm_gaya_pilihan)"
  echo
  printf '%s+ -- -- =[%s %s%s\n' "$MXM_ABU" "$MXM_CREAM" "MXM Deck · perkakas Termux eksperimen" "$MXM_RESET"
  printf '%s+ -- -- =[%s %s%s\n' "$MXM_ABU" "$MXM_CREAM" "Aturan: hanya perangkat & data milik sendiri" "$MXM_RESET"
  echo
}
