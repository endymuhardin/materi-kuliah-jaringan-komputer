# UTS — Jaringan Komputer Sentul (Sesi 8)

Hands-on network configuration challenge menggunakan VirtualBox + Alpine Linux VMs. Tidak ada soal tertulis.

## Tujuan

Memverifikasi kemampuan mahasiswa membangun dan mengoperasikan jaringan multi-segment menggunakan VM Linux: IP addressing, routing antar network, NAT, DNS, HTTP, dan diagnostik traffic.

## Format

- **Grup**: max 3 orang per kelompok (sama dengan kelompok UAS)
- **Durasi total**: 90 menit per kelompok (60 menit build + 30 menit verifikasi & Q&A)
- **Pengamatan**: dosen mengawasi langsung saat verifikasi, rotasi per kelompok
- **Materials**: laptop kelompok (3 unit), VirtualBox sudah terinstall, baseline Alpine VM snapshot sudah disiapkan

## Persiapan sebelum hari ujian (dilakukan kelompok)

Sebelum hari H, tiap kelompok menyiapkan VM Alpine baseline pada masing-masing laptop:

1. Install Alpine Linux versi current (~150MB ISO, console only)
2. Set root password, enable openssh, set hostname placeholder
3. Install paket dasar:
   ```
   apk add iproute2 iptables iptables-openrc dnsmasq busybox-extras tcpdump bind-tools curl python3
   ```
4. **Snapshot VM dalam state ini, namai `BASELINE`** — saat hari H, semua VM di-revert ke snapshot ini sehingga konfigurasi network kosong (testable state)
5. Total: minimum **6 VM** tersedia di seluruh laptop kelompok (boleh lebih)

Dosen menyediakan: dokumen ini, lembar topologi target, daftar tugas yang harus diverifikasi.

## Topologi target

```
        Internet (host laptop, NAT)
              │
        ┌─────────────┐
        │ Router VM   │  eth0: NAT
        │             │
   ┌────┤eth1     eth2├────┐
   │    └─────────────┘    │
   │                       │
[Switch labA]         [Switch labB]
192.168.10.0/24       192.168.20.0/24
   │   │                 │   │
  A1  A2                B1  B2
 .10 .11                .10 .11

Special roles:
- A1: DNS server (dnsmasq)
- B1: HTTP server (python3 http.server)
- Fake domain: tugas.lab → A record points to B1
```

### Konfigurasi NIC VirtualBox

| VM | Adapter 1 | Adapter 2 | Adapter 3 |
|---|---|---|---|
| Router | NAT (or Bridged) | Internal `labA` | Internal `labB` |
| A1, A2 | Internal `labA` | — | — |
| B1, B2 | Internal `labB` | — | — |

## Tugas yang harus diselesaikan dan didemonstrasikan

Tiap kelompok menyelesaikan **semua** tugas berikut. Urutan bebas. Tiap tugas diverifikasi dosen secara langsung.

### Tugas 1 — Bring up topology (15 menit)
- Revert semua VM ke snapshot `BASELINE`
- Konfigurasi VirtualBox NIC modes dan internal network sesuai tabel
- Boot semua VM
- Verifikasi: `ip link` menampilkan interface yang benar di setiap VM

### Tugas 2 — IP Configuration (10 menit)
- Assign static IP + netmask di setiap VM:
  - Router: eth1 = 192.168.10.1/24, eth2 = 192.168.20.1/24
  - A1 = 192.168.10.10/24, A2 = 192.168.10.11/24
  - B1 = 192.168.20.10/24, B2 = 192.168.20.11/24
- Konfigurasi default gateway di tiap client menuju router
- Verifikasi: `ip addr show`, `ip route show` — output sesuai

### Tugas 3 — Inter-LAN Routing (10 menit)
- Enable IP forwarding di router: `sysctl -w net.ipv4.ip_forward=1`
- Verifikasi: ping dari A1 ke B1 (cross-LAN) berhasil
- Trace path: `traceroute B1` dari A1 menampilkan hop router

### Tugas 4 — NAT to "Internet" (10 menit)
- Konfigurasi iptables MASQUERADE di router untuk traffic keluar eth0:
  ```
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  ```
- Verifikasi: `ping 8.8.8.8` dari A1 berhasil
- `curl -I https://example.com` dari A1 berhasil — outbound HTTP works

### Tugas 5 — DNS Server (10 menit)
- Konfigurasi dnsmasq di A1: tambah entry
  ```
  address=/tugas.lab/192.168.20.10
  ```
- Tunjuk `/etc/resolv.conf` di A2 ke A1 sebagai nameserver
- Verifikasi: `dig @192.168.10.10 tugas.lab` dari A2 menampilkan IP B1

### Tugas 6 — HTTP via telnet (5 menit)
- Jalankan HTTP server di B1: `python3 -m http.server 80` dengan halaman index berisi nama kelompok
- Dari A2: `telnet tugas.lab 80` → ketik manual:
  ```
  GET / HTTP/1.1
  Host: tugas.lab

  ```
- Terima dan tampilkan response

### Tugas 7 — Wireshark/tcpdump NAT capture (10 menit)
- Di router VM, jalankan `tcpdump -i eth0 -w nat.pcap -c 50`
- Trigger traffic dari A1 ke internet: `curl http://example.com`
- Stop capture, buka file `nat.pcap` dengan Wireshark di host laptop
- Tunjukkan dosen: source IP setelah masquerade (= IP eth0 router) vs source IP asli (192.168.10.10) — bukti NAT translation visible di paket

## Pelaksanaan dan verifikasi

- Selama fase build (60 menit pertama): kelompok bekerja bebas, boleh menggunakan AI tools, dokumentasi, internet
- Selama fase verifikasi (30 menit terakhir): dosen rotasi ke tiap kelompok
- Untuk tiap tugas yang ditunjukkan, dosen memilih random satu anggota kelompok untuk mendemonstrasikan atau menjelaskan
  - Contoh tugas 5: "Ahmad, tunjukkan saya isi `/etc/dnsmasq.conf` dan jelaskan baris yang relevan"
  - Anggota lain tidak boleh mengetik atau mengoperasikan keyboard saat anggota terpilih demo
  - Boleh diskusi verbal singkat untuk panduan, tapi penalty diterapkan
- Jika satu tugas gagal, lanjut ke tugas berikut — partial credit
- AI policy: tidak ada larangan AI tools selama persiapan dan build. Tapi dosen mengamati keyboard saat verifikasi → student tidak bisa MITM pertanyaan ke AI real-time

## Penilaian

| Komponen | Bobot |
|---|---|
| Tugas 1: Bring up topology | 5 |
| Tugas 2: IP Configuration | 15 |
| Tugas 3: Inter-LAN Routing | 15 |
| Tugas 4: NAT to internet | 15 |
| Tugas 5: DNS Server | 15 |
| Tugas 6: HTTP via telnet | 10 |
| Tugas 7: tcpdump NAT capture | 10 |
| Individual contribution | 15 |
| **Total** | **100** |

**Lulus minimum: 60**

### Individual contribution scoring

Dosen menilai berdasarkan random calls saat verifikasi:
- Apakah setiap anggota dapat menjawab pertanyaan tentang bagian yang dia kerjakan
- Apakah ada anggota yang jelas "freeloader" (tidak tahu apa-apa)
- Anggota yang gagal menjawab random call: dapat penalty individual (-10 dari total grup score untuk dia sendiri, anggota lain tidak terkena)

## Logistics

- **Jumlah kelompok**: ~9 kelompok (27 mahasiswa / 3)
- **Penjadwalan**: 90 menit per kelompok, paralel max 3 kelompok di ruang yang sama
- **Bisa dijalankan dalam 1 hari** dengan rotasi: 3 kelompok di tiap slot, total 3 slot
- **Backup plan**: jika VM crash atau VirtualBox bermasalah, kelompok dapat extra 15 menit

## Checklist dosen sebelum hari H

- [ ] Print dokumen ini untuk tiap kelompok
- [ ] Verifikasi semua kelompok sudah punya snapshot `BASELINE` (cek di sesi 7 dry-run)
- [ ] Siapkan rubric scoring sheet per kelompok
- [ ] Siapkan jadwal rotasi verifikasi per slot
- [ ] Test sendiri 1 kelompok end-to-end → estimasi waktu real
