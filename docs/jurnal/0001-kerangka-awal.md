# 0001 · Kerangka awal

**Tanggal:** 2026-10-14

## Apa yang dibuat

- `deck.sh` — menu utama: banner MXM, enam kategori, baca Aturan, keluar.
  Bisa juga langsung `bash deck.sh 3` untuk masuk ke kategori 3.
- `tools/01..06-*.sh` — satu skrip per kategori, isinya persis tabel di
  README.
- `lib/warna.sh` — palet MXM (oranye 215, cream 223, abu 245) dan fungsi
  `mxm_info/ok/warn/galat`.
- `lib/pasang.sh` — logika pasang bersama, supaya skrip kategori cukup
  berisi daftar alat.
- `docs/ATURAN.md` — versi panjang Aturan.

## Keputusan

1. **Pasang satu per satu.** Tiap alat dipasang dengan perintah terpisah,
   jadi satu paket yang gagal (mis. nama paket berubah di repo Termux) tidak
   menggagalkan yang lain. Ringkasan berhasil/gagal ditampilkan di akhir.
2. **Pilih, bukan pasang semua.** Tiap kategori menampilkan daftar dan
   bertanya: semua (`a`), nomor tertentu (`1 3`), atau batal (`q`).
3. **Kategori jaringan minta persetujuan.** `04-jaringan.sh` menampilkan
   ringkasan Aturan dan butuh jawaban `y` sebelum memasang apa pun.
4. **Mode coba.** `MXM_COBA=1` menampilkan perintah tanpa menjalankannya —
   berguna untuk belajar dan untuk mengetes di luar Termux.
5. **Semua tercatat.** Hasil pemasangan ditulis ke `~/.mxm-deck/pasang.log`.
6. **Warna sopan.** Warna mati otomatis bila keluaran bukan terminal atau
   `NO_COLOR` diset.

## Langkah berikutnya

- Uji di Termux sungguhan; catat paket yang namanya beda/gagal.
- Pertimbangkan pilihan "hapus" per kategori.
