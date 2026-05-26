# Demo Login — Packet Sniffing

Aplikasi login HTTP plaintext untuk demonstrasi packet sniffing. Tujuannya menunjukkan bahwa form login yang dikirim via HTTP (bukan HTTPS) bisa dibaca apa adanya oleh siapa pun yang dapat melihat paket di network path.

## Stack

Vanilla Node.js, tanpa dependency. Hanya butuh Node.js 18+.

## Jalankan server

```sh
node server.js
```

Server listen di `http://0.0.0.0:3000`. Akses dari browser: `http://localhost:3000/login` (atau dari mahasiswa lain di LAN: `http://<ip-laptop-dosen>:3000/login`).

Akun demo:
- `admin` / `rahasia123`
- `mahasiswa` / `network2026`

Login salah/benar sama-sama menampilkan halaman hasil yang juga me-echo body POST — jadi mahasiswa langsung lihat data yang dikirim.

## Demo sniffing

Buka terminal kedua di laptop yang menjalankan server (atau di network gateway).

### Opsi 1 — tcpdump (text dump)

```sh
sudo tcpdump -i any -A -s 0 -nn 'tcp port 3000'
```

Lakukan login dari browser. Cari paket dengan body POST — username & password tampak persis. Filter agar hanya menampilkan paket dengan payload (skip handshake/ACK kosong):

```sh
sudo tcpdump -i any -A -s 0 -nn 'tcp port 3000 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'
```

### Opsi 2 — Wireshark (GUI, lebih jelas untuk demo kelas)

1. Start capture pada interface yang dipakai untuk akses server (loopback `lo` jika di laptop sama, atau interface LAN jika dari laptop lain).
2. Display filter: `tcp.port == 3000 and http.request.method == POST`
3. Pilih paket POST → Right-click → **Follow → HTTP Stream**
4. Stream window akan tampil request lengkap, termasuk body:
   ```
   POST /login HTTP/1.1
   Host: 192.168.1.10:3000
   Content-Type: application/x-www-form-urlencoded
   Content-Length: 38
   
   username=admin&password=rahasia123
   ```

### Opsi 3 — ngrep (one-liner cepat)

```sh
sudo ngrep -d any -W byline 'username|password' port 3000
```

## Skenario demo di kelas

1. **Mahasiswa A** menjalankan server di laptopnya, share IP ke teman.
2. **Mahasiswa B** di laptop lain login ke server A via WiFi yang sama.
3. **Mahasiswa C** menyiapkan Wireshark di interface WiFi-nya sendiri — bisa capture paket plain HTTP jika WiFi unencrypted (open network), atau jika rogue AP / ARP poisoning di-setup.

Variasi yang bisa ditunjukkan:
- **Sniff via loopback**: mahasiswa A jalankan server + browser + Wireshark sekaligus → tcpdump pada `lo`. Paling cepat untuk pembuktian konsep, tidak perlu setup network.
- **Sniff antar laptop di WiFi terbuka**: butuh interface dalam monitor mode (Linux) atau airport sniffing (macOS).
- **Sniff via switch port mirror / hub**: skenario kantor lama (sebagian sudah obsolete tapi historically relevan).

## Pelajaran setelah demo

| Tanpa TLS (HTTP) | Dengan TLS (HTTPS) |
|---|---|
| Username + password tampak plaintext di sniff | Header + body terenkripsi, sniffer hanya melihat TLS handshake metadata (SNI, cipher) |
| Cookie session juga bisa dicuri → session hijacking | Cookie tidak terbaca |
| Form file upload juga vulnerable | Aman selama TLS valid |

Solusi yang sudah mahasiswa lakukan di sesi 6–7: deploy via Netlify dengan Let's Encrypt SSL otomatis. Untuk VPS deploy di sesi 13, gunakan `certbot` atau reverse proxy (Caddy/Traefik) yang handle TLS otomatis.

## Lawan defense

- **Jangan deploy login form lewat HTTP** — selalu HTTPS, redirect 301 dari port 80.
- **HSTS header** (`Strict-Transport-Security: max-age=31536000; includeSubDomains`) — browser refuse fallback ke HTTP.
- **Secure cookie flag** (`Set-Cookie: session=...; Secure; HttpOnly; SameSite=Strict`) — cookie tidak dikirim via HTTP, tidak terbaca JavaScript.
- **Certificate pinning** untuk aplikasi mobile.

## File

- `server.js` — single-file Node.js HTTP server (zero deps)
