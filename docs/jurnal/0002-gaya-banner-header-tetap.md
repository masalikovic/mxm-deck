# 0002 · Gaya banner & header tetap

**Tanggal:** 2026-10-14

## Apa yang dibuat

- Tujuh gaya banner: `standar`, `bayangan`, `miring`, `titik`, `kotak`,
  `tipis`, `gameboy` (+ `acak`). Pilih lewat menu `g`; pratinjau semua
  dengan `bash deck.sh pratinjau`.
- Header (banner + info) tetap di atas layar; keluaran lain menggulir di
  bawahnya.

## Keputusan

1. **Huruf disimpan sebagai berkas teks di `seni/`, bukan dibuat saat
   jalan.** Hurufnya dibuat sekali dengan figlet, jadi Termux tidak perlu
   memasang figlet. Gaya baru cukup ditambah sebagai berkas.
2. **MXM dan DECK dipisah per berkas.** Supaya bisa diwarnai dua nada
   (oranye/cream) tanpa memotong string berdasarkan kolom, yang rawan salah
   untuk karakter UTF-8. Berkas `-mxm` sudah diberi spasi sampai rata.
3. **Header tetap memakai scroll region (DECSTBM, `\e[atas;bawahr`).**
   Tidak butuh tmux/ncurses dan didukung Termux. Saat keluar, region
   dikembalikan ke normal (`\e[r`) lewat `trap EXIT`.
4. **Pulihkan setelah program lain.** apt dan less bisa mengatur ulang
   scroll region, jadi header digambar ulang setelah tiap paket dipasang dan
   setelah membaca Aturan. Posisi kursor ditanyakan ke terminal (`\e[6n`)
   supaya tidak tertinggal di dalam header.
5. **Ukuran layar berubah → gambar ulang.** Menu membaca input dengan
   `read -t 1` agar bisa bereaksi pada SIGWINCH (HP diputar, keyboard
   muncul) tanpa menunggu Enter.
6. **Layar sempit → turun gaya.** Bila gaya pilihan lebih lebar dari layar,
   atau sisa baris di bawah header kurang dari 10, dipakai `tipis`, lalu
   `polos`. Header tidak pernah boleh terbungkus (wrap), karena tingginya
   jadi salah.

## Pengujian

Diuji dengan emulator terminal (pyte) lewat pty: ukuran 46×26, 36×24, dan
resize ke 60×40; ganti gaya; pasang semua (mode coba); program palsu yang
mereset scroll region; keluar; dan input dari pipe (header tetap mati,
banner dicetak biasa).

## Langkah berikutnya

- Cek di Termux sungguhan, terutama saat keyboard layar muncul/hilang.
