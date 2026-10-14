# Aturan MXM Deck

MXM Deck adalah perkakas belajar. Aturan di bawah bukan hiasan: alat yang
melanggarnya tidak masuk ke repo ini, dan pemakaian yang melanggarnya bukan
pemakaian MXM Deck.

## 1. Hanya milik sendiri

Pakai MXM Deck **hanya** untuk:

- perangkat Android **milik Anda sendiri**;
- jaringan **milik Anda sendiri** atau yang Anda kelola (Wi-Fi rumah,
  perangkat Anda) — atau jaringan yang pemiliknya memberi Anda **izin
  tertulis** untuk diperiksa;
- data **milik Anda sendiri**, atau data yang pemiliknya izinkan untuk Anda
  olah (mis. ekspor akun Anda dari sebuah layanan).

## 2. Yang tidak akan pernah ada di sini

MXM Deck **tidak** berisi, dan tidak akan menerima kontribusi berupa, alat
untuk:

- menyerang, memindai, atau masuk ke sistem/jaringan milik orang lain;
- menerobos login, memecahkan sandi orang lain, atau menyadap lalu lintas
  orang lain;
- menyamar sebagai orang/organisasi lain, phishing, atau menipu;
- mengumpulkan data orang lain tanpa izin.

## 3. Diagnosis jaringan

`nmap`, `mtr`, `ping`, `httpie` dan sejenisnya **hanya** diarahkan ke
alamat milik Anda: router rumah Anda, HP/laptop Anda, server yang Anda sewa
sendiri. Contoh yang boleh:

```bash
ip addr                       # lihat alamat perangkat Anda sendiri
nmap -sn 192.168.1.0/24       # daftar perangkat di Wi-Fi RUMAH ANDA
mtr 1.1.1.1                   # jalur internet dari perangkat Anda
```

Memindai jaringan atau sistem orang lain tanpa izin dapat melanggar hukum di
banyak negara, termasuk Indonesia (UU ITE, antara lain Pasal 30 tentang akses
tanpa hak). Wi-Fi kafe, kampus, kantor, atau tetangga **bukan** milik Anda.

## 4. Transparansi pemasangan

- Skrip hanya memanggil `pkg` (Termux) dan `pip` (Python) resmi.
- Tidak ada `curl | bash`, tidak ada unduhan dari sumber yang tidak jelas.
- Setiap skrip menampilkan perintah yang akan dijalankan sebelum
  menjalankannya. `MXM_COBA=1 bash deck.sh` menampilkan perintah tanpa
  menjalankannya sama sekali.

## 5. Kalau ragu

Kalau ragu apakah sebuah alat atau pemakaian sesuai aturan ini: jangan
pasang, jangan jalankan. Tanyakan dulu lewat issue.
