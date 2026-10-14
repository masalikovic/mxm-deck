#!/usr/bin/env python3
"""tests/uji_layar.py — uji header tetap di terminal sungguhan (pty + pyte).

Menjalankan deck.sh di pseudo-terminal, merender keluarannya dengan emulator
VT (pyte), lalu memeriksa header tetap di baris atas setelah keluaran lain
menggulir, setelah resize, setelah program mereset scroll region, dll.

Butuh: pip install pyte
"""
import os, pty, select, signal, struct, sys, tempfile, time, fcntl, termios
import pyte

AKAR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lulus = gagal = 0


class Sesi:
    def __init__(self, baris, kolom, env=None):
        self.screen = pyte.Screen(kolom, baris)
        self.stream = pyte.ByteStream(self.screen)
        self.home = tempfile.mkdtemp()
        self.status = os.path.join(self.home, 'status')
        open(self.status, 'w').close()
        e = dict(os.environ, TERM='xterm-256color', LANG='C.UTF-8', HOME=self.home,
                 MXM_UJI_STATUS=self.status,
                 PATH=os.path.join(AKAR, 'tests', 'palsu') + ':' + os.environ['PATH'])
        e.pop('NO_COLOR', None)
        e.update(env or {})
        self.pid, self.fd = pty.fork()
        if self.pid == 0:
            os.execvpe('bash', ['bash', os.path.join(AKAR, 'deck.sh')], e)
        self._ukuran(baris, kolom)
        # Jawab pertanyaan posisi kursor (\e[6n) seperti terminal sungguhan.
        self.screen.write_process_input = lambda d: os.write(self.fd, d.encode())
        self.pompa(2.0)

    def _ukuran(self, b, k):
        fcntl.ioctl(self.fd, termios.TIOCSWINSZ, struct.pack('HHHH', b, k, 0, 0))

    def pompa(self, detik=1.0):
        akhir = time.time() + detik
        while time.time() < akhir:
            r, _, _ = select.select([self.fd], [], [], 0.05)
            if r:
                try:
                    self.stream.feed(os.read(self.fd, 65536))
                except OSError:
                    return

    def ketik(self, teks, detik=1.2):
        os.write(self.fd, teks.encode())
        self.pompa(detik)

    def resize(self, b, k):
        self.screen.resize(b, k)
        self._ukuran(b, k)
        os.kill(self.pid, signal.SIGWINCH)
        self.pompa(2.5)

    def baris(self, n):
        return self.screen.display[n - 1].rstrip()

    def layar(self):
        return '\n'.join(f'{i + 1:2}|{l.rstrip()}' for i, l in enumerate(self.screen.display))

    def tutup(self):
        try:
            os.kill(self.pid, signal.SIGKILL)
            os.waitpid(self.pid, 0)
        except OSError:
            pass


def cek(nama, kondisi, sesi=None):
    global lulus, gagal
    if kondisi:
        lulus += 1
        print(f'  ok   {nama}')
    else:
        gagal += 1
        print(f'  GAGAL {nama}')
        if sesi:
            print(sesi.layar())


STANDAR_1 = ' __  ____  ____  __   ____  _____ ____ _  __'
INFO = '+ -- -- =[ MXM Deck · gaya: standar'


def header_standar(s):
    return s.baris(1) == STANDAR_1 and s.baris(6) == INFO


print('== header tetap')
s = Sesi(26, 46, {'MXM_COBA': '1'})
cek('header tampil di atas saat mulai', header_standar(s), s)
cek('menu tampil di bawah header', any('mxm >' in l for l in s.screen.display), s)
s.ketik('2\n'); s.ketik('a\n')
cek('header tetap setelah keluaran panjang menggulir', header_standar(s), s)
cek('hasil pasang tampil di area bawah', any('Selesai: 5 berhasil' in l for l in s.screen.display), s)
s.ketik('4\n'); s.ketik('y\n'); s.ketik('a\n')
cek('header tetap setelah kategori kedua', header_standar(s), s)

print('== resize')
s.resize(40, 60)
cek('header digambar ulang setelah resize', header_standar(s), s)
cek('garis header ikut melebar', s.baris(8) == '+' + '-' * 48 + '+', s)
s.ketik('0\n')
cek('keluar → scroll region dikembalikan',
    s.screen.margins is None or (s.screen.margins.top == 0 and s.screen.margins.bottom == 39), s)
s.tutup()

print('== layar sempit')
s = Sesi(24, 36)
cek('36 kolom → gaya tipis', s.baris(1).startswith('┏┳┓') and 'tipis (sempit)' in s.baris(4), s)
s.tutup()
s = Sesi(16, 46)
cek('16 baris → turun ke tipis', s.baris(1).startswith('┏┳┓'), s)
s.tutup()
s = Sesi(14, 46)
cek('14 baris → turun ke polos', s.baris(1) == '[ MXM DECK ]', s)
s.tutup()

print('== program yang mereset scroll region')
s = Sesi(26, 46, {'MXM_UJI_RESET_REGION': '1'})
s.ketik('2\n'); s.ketik('1\n', 2.0)
cek('header utuh setelah apt mereset region', header_standar(s), s)
cek('menu kembali tampil', any('mxm >' in l for l in s.screen.display), s)
s.tutup()

print('== ganti gaya')
s = Sesi(30, 46)
s.ketik('g\n', 2.0); s.ketik('7\n', 2.0)
cek('gaya gameboy tampil di header', s.baris(1).startswith(' ,-----------.'), s)
with open(os.path.join(s.home, '.mxm-deck', 'gaya')) as f:
    cek('pilihan gaya tersimpan', f.read().strip() == 'gameboy')
s.ketik('2\n'); s.ketik('a\n')
cek('header gameboy tetap setelah menggulir', s.baris(1).startswith(' ,-----------.'), s)
s.tutup()

print('== header dimatikan')
s = Sesi(26, 46, {'MXM_HEADER': '0', 'MXM_COBA': '1'})
s.ketik('2\n'); s.ketik('a\n')
cek('MXM_HEADER=0 → banner ikut tergulir', s.baris(1) != STANDAR_1, s)
s.tutup()

print(f'\nLulus: {lulus}  Gagal: {gagal}')
sys.exit(1 if gagal else 0)
