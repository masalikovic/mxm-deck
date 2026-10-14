# 0003 · Menu hapus & CI

**Tanggal:** 2026-10-14

## Apa yang dibuat

- Pilihan `h` di tiap kategori untuk menghapus alat, dan tanda `✓`/`~` di
  daftar untuk alat yang sudah terpasang penuh/sebagian.
- Uji otomatis (`tests/`) dan GitHub Actions (`.github/workflows/uji.yml`)
  yang menjalankannya di tiap PR dan push ke `main`.

## Keputusan

1. **Hapus tanpa `-y`.** `pkg uninstall` (apt) dan `pip uninstall`
   dijalankan tanpa `-y`, jadi keduanya tetap menampilkan apa saja yang ikut
   terhapus (mis. menghapus `python` ikut menghapus paket yang bergantung
   padanya) dan bertanya lagi. MXM Deck juga bertanya lebih dulu.
2. **Paket inti dilindungi.** `termux-tools` (berisi perintah `pkg` itu
   sendiri) dan `tar` (dibutuhkan dpkg) tidak pernah dihapus lewat menu. Pada
   baris `tar / zip`, hanya `zip` yang dihapus.
3. **`MXM_YA=1` tidak berlaku untuk hapus.** Pemasangan boleh otomatis,
   penghapusan selalu ditanyakan.
4. **pkg/dpkg/pip palsu untuk uji.** Status paket disimpan di sebuah berkas,
   jadi alur pasang/hapus sungguhan (bukan hanya mode coba) bisa diuji di
   mesin mana pun tanpa memasang apa pun. `MXM_UJI_GAGAL` meniru paket yang
   gagal; `MXM_UJI_RESET_REGION` meniru apt yang mereset scroll region.
5. **Uji layar memakai emulator terminal.** `tests/uji_layar.py` menjalankan
   deck.sh di pty dan merender keluarannya dengan pyte, lalu memeriksa isi
   layar baris per baris: header tetap, resize, layar sempit/pendek, reset
   region, ganti gaya, keluar.
6. **Uji dicek bisa gagal.** Sebelum dipercaya, kode sengaja dirusak
   (perlindungan paket dan tanda ✓ dihapus) dan uji yang tepat memang gagal.

## Catatan

- Mengecek status `pip` (`pip show`) agak lambat di HP, jadi kategori
  "Data pribadi" mungkin butuh satu-dua detik sebelum daftarnya tampil.

## Perbaikan dari uji di HP (screenshot Termux, Android 13)

1. **Header tergeser ke tengah saat keyboard muncul/hilang.** Saat ukuran
   layar berubah, Termux mereset scroll region dan memunculkan riwayat gulir
   di atas header. Termux memang memasukkan baris yang tergulir dari dalam
   region ke riwayat. Bash baru menjalankan trap SIGWINCH setelah `read`
   selesai, jadi di prompt selain menu utama (pilih gaya, kategori, hapus,
   konfirmasi) layar tidak digambar ulang sampai Enter ditekan.
   Perbaikan: semua prompt memakai `mxm_baca` (`read -t 1` berulang). Saat
   ukuran berubah, layar dibersihkan, header digambar ulang, lalu isi layar
   saat itu (daftar + prompt) ditampilkan lagi. Ketikan yang belum di-Enter
   tetap aman di buffer terminal. Uji baru di `tests/uji_layar.py` gagal
   pada versi lama dan lulus pada versi baru.
2. **Uptime "?".** Android 10+ memblokir `/proc/uptime` untuk aplikasi.
   Bila tak terbaca, baris itu diganti versi Termux (`TERMUX_VERSION`), atau
   ukuran layar bila di luar Termux.
