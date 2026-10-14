# MXM DECK

```
 __  __ __  __ __  __     ____  _____ ____ _  __
|  \/  |\ \/ /|  \/  |   |  _ \| ____/ ___| |/ /
| |\/| | \  / | |\/| |   | | | |  _|| |   | ' /
| |  | | /  \ | |  | |   | |_| | |__| |___| . \
|_|  |_|/_/\_\|_|  |_|   |____/|_____\____|_|\_\

+ -- -- =[ MXM Deck · perkakas Termux eksperimen
+ -- -- =[ Gaya: orange-black-cream (identitas MXM)
+ -- -- =[ Aturan: hanya perangkat & data milik sendiri
```

> **MXM Deck** adalah kumpulan perkakas eksperimen untuk **Termux** di Android.
> Isinya alat sehari-hari untuk belajar, mengelola file, mendiagnosis
> perangkat sendiri, dan mengolah data pribadi — dipasang lewat satu skrip.
> Proyek ini adik dari [mxm-gameboy](https://github.com/Masalikovic/mxm-gameboy):
> identitas visual yang sama, filosofi yang sama (satu langkah per waktu,
> semua tercatat).

---

## ⚖️ Aturan pemakaian (baca dulu)

MXM Deck **hanya** untuk:

- perangkat Android **milik Anda sendiri**;
- jaringan **milik Anda sendiri** (Wi-Fi rumah Anda, perangkat Anda);
- data **milik Anda sendiri** yang Anda izinkan untuk diolah.

MXM Deck **tidak** berisi, dan tidak akan menerima, alat untuk:

- menyerang, memindai, atau masuk ke sistem/jaringan milik orang lain;
- menerobos login, memecahkan sandi orang lain, atau menyadap lalu lintas
  orang lain;
- menyamar sebagai orang/organisasi lain, atau menipu.

Diagnosis jaringan (mis. `nmap`, `ping`) **hanya** boleh diarahkan ke
perangkat dan jaringan yang Anda miliki atau kelola. Memindai milik orang
lain tanpa izin tertulis melanggar hukum di banyak negara, termasuk Indonesia
(UU ITE). Kalau ragu soal sebuah alat, jangan pasang.

---

## 📦 Kategori & tools yang direkomendasikan

Semua tool di bawah bersifat umum, legal, dan aman untuk pemakaian pribadi.
Pemasangan lewat `pkg` (Termux) atau `pip` (Python).

### 1) Dasar Termux & sistem
Mengenal perangkat sendiri dan membuat Termux nyaman.

| Tool | Guna | Pasang |
|---|---|---|
| `termux-api` | Baca baterai, sensor, lokasi, kirim notifikasi (perangkat sendiri) | `pkg install termux-api` |
| `neofetch` | Ringkasan perangkat (seperti banner di atas) | `pkg install neofetch` |
| `htop` | Pantau proses & memori | `pkg install htop` |
| `termux-tools` | Perintah bantu bawaan Termux | `pkg install termux-tools` |
| `tldr` | Contoh singkat tiap perintah (lebih ramah dari `man`) | `pkg install tldr` |

### 2) File, arsip & cadangan
Mengelola dan mencadangkan file Anda sendiri.

| Tool | Guna | Pasang |
|---|---|---|
| `rsync` | Salin/sinkron file antarfolder & perangkat Anda | `pkg install rsync` |
| `rclone` | Cadangkan ke cloud **akun Anda sendiri** | `pkg install rclone` |
| `tar` / `zip` | Arsipkan folder | `pkg install tar zip` |
| `fd` | Cari file dengan cepat | `pkg install fd` |
| `ripgrep` (`rg`) | Cari isi file dengan cepat | `pkg install ripgrep` |

### 3) Data pribadi
Mengolah catatan, ekspor data, CSV, dan basis data Anda sendiri.

| Tool | Guna | Pasang |
|---|---|---|
| `jq` | Olah file JSON (mis. ekspor data akun Anda) | `pkg install jq` |
| `sqlite` | Basis data kecil tanpa server | `pkg install sqlite` |
| `python` + `pandas` | Analisis CSV/tabel | `pkg install python && pip install pandas` |
| `visidata` | Lihat & bersihkan tabel di terminal | `pip install visidata` |
| `csvkit` | Perkakas CSV (gabung, saring, ubah) | `pip install csvkit` |

### 4) Diagnostik jaringan **sendiri**
Memeriksa Wi-Fi dan perangkat milik Anda saja (lihat Aturan).

| Tool | Guna | Pasang |
|---|---|---|
| `nmap` | Daftar perangkat **di jaringan Anda sendiri** | `pkg install nmap` |
| `iproute2` | Lihat alamat IP & rute perangkat Anda | `pkg install iproute2` |
| `mtr` | Ping + traceroute gabungan | `pkg install mtr` |
| `httpie` | Uji API/situs **milik Anda** dengan rapi | `pkg install httpie` |
| `speedtest-cli` | Ukur kecepatan internet Anda | `pip install speedtest-cli` |

### 5) Alat pengembang
Menulis dan menjalankan kode langsung dari HP.

| Tool | Guna | Pasang |
|---|---|---|
| `git` | Versi kode & kelola repo | `pkg install git` |
| `python` | Bahasa serbaguna | `pkg install python` |
| `nodejs` | JavaScript/alat web | `pkg install nodejs` |
| `micro` | Editor teks ramah pemula | `pkg install micro` |
| `openssh` | SSH ke server **milik Anda sendiri** | `pkg install openssh` |

### 6) Belajar & eksperimen
Bermain-main dengan aman, menyambung ke mxm-gameboy.

| Tool | Guna | Pasang |
|---|---|---|
| `rust` | Bahasa yang dipakai `gb-core` | `pkg install rust` |
| `clang` + `make` | Kompilasi program C kecil | `pkg install clang make` |
| `figlet` / `toilet` | Buat banner ASCII sendiri | `pkg install figlet toilet` |
| `asciinema` | Rekam sesi terminal untuk catatan belajar | `pip install asciinema` |

---

## 🎨 Gaya visual MXM

Banner dan menu memakai palet MXM yang sama dengan mxm-gameboy:

| Peran | Warna | Hex |
|---|---|---|
| Latar | hitam tinta | `#0e0e0e` |
| Teks utama | cream | `#f5ebd7` |
| Aksen | oranye | `#ff8a3d` |
| Teks sekunder | abu-abu tenang | `#8a857c` |

Di terminal, warna ini dipetakan ke kode ANSI (oranye ≈ `\e[38;5;215m`,
cream ≈ `\e[38;5;223m`). Bagian **MXM** banner berwarna oranye, bagian
**DECK** cream.

### Gaya banner

Pilih lewat menu `g`, atau lihat semuanya dengan `bash deck.sh pratinjau`.

| Gaya | Lebar | Keterangan |
|---|---|---|
| `standar` | 44 | Huruf klasik figlet |
| `bayangan` | 44 | Blok tebal berbayang (MXM) + DECK garis tipis |
| `miring` | 45 | Huruf miring |
| `titik` | 47 | Titik & blok ala elite |
| `kotak` | 45 | Huruf kotak |
| `tipis` | 22 | Paling ringkas, cadangan untuk layar sempit |
| `gameboy` | 40 | Gameboy MXM + info perangkat (ala neofetch) |
| `acak` | – | Gaya berbeda tiap kali dibuka |

Pilihan disimpan di `~/.mxm-deck/gaya`. Untuk sekali jalan:
`MXM_GAYA=bayangan bash deck.sh`.

**Tambah gaya sendiri:** buat `seni/<nama>-mxm.txt` dan `seni/<nama>-deck.txt`
(mis. dengan `figlet -f <font> MXM`; baris di berkas `-mxm` diberi spasi
sampai sama panjang), lalu daftarkan `<nama>|<lebar>|<keterangan>` di
`seni/gaya.txt`.

### Header tetap

Banner dan info selalu diam di bagian atas layar; menu, `pkg install`, dan
keluaran lain hanya menggulir di bawahnya (memakai *scroll region* terminal).
Kalau layar diputar atau ukurannya berubah, header digambar ulang. Kalau
layar terlalu sempit atau pendek untuk gaya pilihan, otomatis turun ke gaya
`tipis`. Matikan dengan `MXM_HEADER=0 bash deck.sh`.

---

## 🗺️ Struktur repo

```
mxm-deck/
├── README.md          ← berkas ini
├── deck.sh            ← menu utama (banner + pilih kategori)
├── tools/
│   ├── 01-dasar.sh    ← satu skrip pemasang per kategori
│   ├── 02-file.sh
│   ├── 03-data.sh
│   ├── 04-jaringan.sh
│   ├── 05-dev.sh
│   └── 06-belajar.sh
├── lib/
│   ├── warna.sh       ← palet MXM (fungsi echo berwarna)
│   ├── banner.sh      ← gaya-gaya banner ASCII
│   ├── layar.sh       ← header tetap di atas layar
│   └── pasang.sh      ← logika pasang bersama (pkg/pip resmi saja)
├── seni/              ← huruf ASCII tiap gaya + daftar gaya.txt
└── docs/
    ├── ATURAN.md      ← versi panjang dari bagian Aturan
    └── jurnal/        ← catatan tiap langkah (gaya mxm-gameboy)
```

Prinsip yang diwarisi dari mxm-gameboy:

1. **Satu langkah per waktu.** Tiap kategori punya skrip sendiri; tidak ada
   "pasang semua 300 alat sekaligus".
2. **Semua tercatat.** Tiap keputusan masuk `docs/jurnal/`.
3. **Transparan.** Skrip hanya memanggil `pkg`/`pip` resmi; tidak ada unduhan
   dari sumber yang tidak jelas, tidak ada `curl | bash` ke skrip asing.
4. **Aman sejak awal.** Alat yang melanggar Aturan tidak masuk, titik.

---

## 🚀 Mulai

```bash
pkg update && pkg install git
git clone https://github.com/Masalikovic/mxm-deck
cd mxm-deck
bash deck.sh
```

Pilihan lain:

```bash
bash deck.sh 2              # langsung ke kategori 2 (File)
bash deck.sh pratinjau      # lihat semua gaya banner
MXM_GAYA=acak bash deck.sh  # gaya banner acak
MXM_COBA=1 bash deck.sh     # mode coba: perintah ditampilkan, tidak dijalankan
NO_COLOR=1 bash deck.sh     # tanpa warna
MXM_HEADER=0 bash deck.sh   # header ikut menggulir
```

Di tiap kategori, pilih `a` (semua), nomor tertentu (mis. `1 3`), atau `q`
(batal). Alat dipasang satu per satu; hasilnya dicatat di
`~/.mxm-deck/pasang.log`.

---

_Dibuat dengan semangat MXM: belajar sambil membangun, satu langkah yang
dipahami pada satu waktu._
