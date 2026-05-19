#import "/typesetting/library/page.typ": letterhead-page
#import "/typesetting/library/palette.typ": *

#let meta = (
  title: "Ujian Tengah Semester — Sistem Operasi + Jaringan Komputer",
  version: "v2.0",
  date: "2026-05-19",
  institution: "STMIK Tazkia",
  output: "../output/uts-sentul.pdf",
)

#show: letterhead-page.with(meta)

#align(center)[
  #text(size: 16pt, weight: "bold", fill: blue-dark)[Ujian Tengah Semester]
  #v(2mm)
  #text(size: 13pt, weight: "bold")[Sistem Operasi + Jaringan Komputer — Kelas Sentul]
  #v(1mm)
  #text(size: 10pt, fill: gray-text)[Sesi 8 · Semester Genap 2025/2026 · Combined Exam]
]

#v(4mm)

#box(
  fill: note-bg,
  stroke: 0.5pt + note-border,
  inset: 3mm,
  width: 100%,
)[
  *Tentang ujian ini.* Satu sesi praktik hands-on yang menghasilkan dua nilai sekaligus: untuk *Sistem Operasi (MITI.202)* dan *Jaringan Komputer (MITI.203)*. Tiap tugas di-tag dengan kompetensi matkul yang diuji. Materi disusun selaras (loosely) dengan objectives *LPIC-1 (LPI Linux Essentials + 101+102)* supaya mahasiswa yang berminat dapat melanjutkan persiapan sertifikasi secara mandiri setelah lulus. Lihat appendix di akhir dokumen untuk pemetaan objective lengkap.
]

#v(2mm)

= Tujuan

Memverifikasi kemampuan mahasiswa: (1) mengelola sistem Linux — filesystem, user/permissions, package management, init/service, shell scripting; (2) membangun dan mengoperasikan jaringan multi-segment — IP addressing, routing, NAT, DNS, HTTP, dan diagnostik. Verifikasi murni hands-on, tidak ada soal tertulis.

= Format

#table(
  columns: (35mm, 1fr),
  stroke: 0.5pt + gray-text,
  inset: 2mm,
  [*Grup*], [Max 3 orang per kelompok (sama dengan kelompok UAS)],
  [*Durasi*], [120 menit per kelompok (90 menit build + 30 menit verifikasi dan Q&A)],
  [*Pengamatan*], [Dosen mengawasi langsung saat verifikasi, rotasi per kelompok],
  [*Output nilai*], [Dua nilai independen: Sistem Operasi (100) + Jaringan (100)],
  [*Materials*], [3 laptop kelompok, VirtualBox terinstall, baseline VM snapshot sudah disiapkan, disk virtual tambahan untuk router VM],
)

= Persiapan Sebelum Hari Ujian

Tiap kelompok menyiapkan VM Alpine baseline pada masing-masing laptop:

+ Install Alpine Linux versi current (~150MB ISO, console only)
+ Set root password, enable openssh, set hostname placeholder
+ Install paket dasar:
  #raw("apk add iproute2 iptables iptables-openrc dnsmasq busybox-extras tcpdump bind-tools curl python3 nginx openrc sudo openssh", lang: "shell", block: true)
+ Attach 1 disk virtual tambahan (1 GB cukup) ke VM yang akan jadi *router* — kosong, belum di-partisi
+ *Snapshot VM dalam state ini, namai `BASELINE`*
+ Total: minimum *6 VM* tersedia, salah satunya punya disk tambahan

Saat hari H, semua VM di-revert ke `BASELINE` → konfigurasi network kosong, disk tambahan masih raw → testable state.

= Topologi Target

#raw(
"        Internet (host laptop, NAT)
              │
        ┌─────────────┐
        │ Router VM   │  eth0: NAT
        │             │  + extra disk → /data (Tugas 1)
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
- B1: HTTP server (nginx via systemd/openrc)
- Fake domain: tugas.lab → A record points to B1",
  block: true,
)

= Tugas — 9 Tugas Inti

Tiap tugas di-tag dengan objective LPIC-1 dan kontribusi nilai ke tiap matkul. Urutan pengerjaan bebas.

== Tugas 1 — Disk Partitioning + Filesystem + Mount (10 menit)

*Tag: LPIC 104.1, 104.3 · Nilai: SO 15, Jaringan 0*

Pada router VM, kelola disk tambahan:
+ Partisi disk kedua dengan `fdisk` atau `parted` (satu partisi primer, full disk)
+ Format dengan ext4: `mkfs.ext4 /dev/sdb1`
+ Mount manual ke `/data`
+ Tambah entry di `/etc/fstab` supaya auto-mount saat boot
+ *Verifikasi*: `reboot` VM, `mount` harus menunjukkan `/data` masih ter-mount

== Tugas 2 — User & Permissions + SSH Hardening (10 menit)

*Tag: LPIC 104.5, 107.1, 110.2 · Nilai: SO 10, Jaringan 5*

Di router VM:
+ Buat user `admin` dengan sudo access (tambah ke `/etc/sudoers` atau group `wheel`)
+ Generate SSH key pair di host laptop, install public key ke `/home/admin/.ssh/authorized_keys`
+ Edit `/etc/ssh/sshd_config`: disable root login (`PermitRootLogin no`)
+ Restart sshd, verifikasi: SSH dengan key sebagai `admin` works, login root via SSH tertolak
+ Pada `/data`, set ownership ke `admin:admin`, permissions 770 (rwx untuk user+group)

== Tugas 3 — Package Install + Service Management (10 menit)

*Tag: LPIC 102.4 (apk), 101.3, 108.2 · Nilai: SO 15, Jaringan 10*

Di B1:
+ Install nginx via `apk add nginx` (sudah ada di baseline, verifikasi)
+ Buat halaman index custom berisi nama kelompok di `/var/www/localhost/htdocs/index.html`
+ Enable & start nginx sebagai service:
  - Alpine pakai OpenRC: `rc-update add nginx default` dan `rc-service nginx start`
  - Atau jika ada systemd: `systemctl enable --now nginx`
+ Verifikasi status service: `rc-service nginx status` atau `systemctl status nginx`
+ View logs: `tail /var/log/nginx/access.log` saat ada request masuk

== Tugas 4 — Network Configuration Persistent (15 menit)

*Tag: LPIC 109.2 · Nilai: SO 0, Jaringan 20*

+ Assign static IP + netmask + gateway di setiap VM, tulis ke `/etc/network/interfaces` supaya persistent
  - Router: eth1 = 192.168.10.1/24, eth2 = 192.168.20.1/24
  - A1 = 192.168.10.10/24 (gateway 192.168.10.1)
  - A2 = 192.168.10.11/24 (gateway 192.168.10.1)
  - B1 = 192.168.20.10/24 (gateway 192.168.20.1)
  - B2 = 192.168.20.11/24 (gateway 192.168.20.1)
+ Enable IP forwarding di router secara persistent: edit `/etc/sysctl.conf` → `net.ipv4.ip_forward=1`, lalu `sysctl -p`
+ Konfigurasi MASQUERADE NAT di router:
  #raw("iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE", lang: "shell", block: true)
  Simpan rule supaya persistent: `rc-service iptables save`
+ Verifikasi: ping cross-LAN works, ping 8.8.8.8 dari client works, semua persist setelah reboot

== Tugas 5 — DNS Server + Client (10 menit)

*Tag: LPIC 108, 109.4 · Nilai: SO 0, Jaringan 15*

+ Konfigurasi dnsmasq di A1:
  - Edit `/etc/dnsmasq.conf` tambah `address=/tugas.lab/192.168.20.10`
  - Enable & start service: `rc-update add dnsmasq default` + `rc-service dnsmasq start`
+ Tunjuk `/etc/resolv.conf` di A2 ke A1: `nameserver 192.168.10.10`
+ Verifikasi: `dig @192.168.10.10 tugas.lab` menampilkan A record ke 192.168.20.10
+ Verifikasi: dari A2, `dig tugas.lab` (tanpa @ explicit) tetap resolve via resolv.conf

== Tugas 6 — Shell Script Automation (15 menit)

*Tag: LPIC 105.2 · Nilai: SO 15, Jaringan 5*

Tulis script `setup-network.sh` yang menerima 4 parameter: interface, IP/CIDR, gateway, DNS server.

#raw(
"#!/bin/sh
# Usage: ./setup-network.sh <iface> <ip/cidr> <gateway> <dns>
# Example: ./setup-network.sh eth0 192.168.10.10/24 192.168.10.1 192.168.10.10",
  lang: "shell", block: true,
)

Script harus:
+ Validate jumlah parameter (exit dengan error message kalau salah)
+ Validate format IP (basic regex match)
+ Bring down interface, flush addresses lama
+ Set new address, default gateway, DNS in resolv.conf
+ Bring up interface
+ Test connectivity: ping gateway 3 kali, output hasilnya

Run script untuk re-configure salah satu client VM (misal A2). Verifikasi: setting baru aktif.

== Tugas 7 — HTTP via Telnet (5 menit)

*Tag: LPIC 109.1 · Nilai: SO 0, Jaringan 10*

+ Dari A2, `telnet tugas.lab 80` (resolve via DNS server kelompok)
+ Ketik manual:
  #raw("GET / HTTP/1.1\nHost: tugas.lab\n\n", block: true)
+ Baca response: status line, headers, body (harus berisi nama kelompok)
+ Jelaskan ke dosen: apa fungsi `Host:` header? Kenapa butuh blank line setelah headers?

== Tugas 8 — Network Troubleshooting + tcpdump Capture (10 menit)

*Tag: LPIC 109.3, 110.1 · Nilai: SO 10, Jaringan 15*

+ Dosen sabotage 1 konfigurasi di salah satu VM kelompok (kelompok tidak tahu apa). Pilihan:
  - Wrong netmask di salah satu client
  - Default gateway di-remove
  - iptables MASQUERADE rule di-flush
  - resolv.conf points ke server yang salah
+ Kelompok diagnose dalam 5 menit pakai tools: `ping`, `traceroute`, `ip addr`, `ip route`, `ss`, `dig`, `journalctl`, `cat /etc/network/interfaces`
+ Fix masalah, verifikasi connectivity restored
+ *Kemudian*: capture HTTP traffic dari A1 ke `tugas.lab` dengan `tcpdump`:
  #raw("tcpdump -i any -w trace.pcap host tugas.lab", lang: "shell", block: true)
+ Buka `trace.pcap` di Wireshark, tunjukkan:
  - DNS resolution query
  - TCP 3-way handshake
  - HTTP GET request
  - Pada router eth0 interface: source IP setelah NAT (= router IP, bukan IP client)

== Tugas 9 — Process Management (5 menit)

*Tag: LPIC 103.5, 103.6 · Nilai: SO 10, Jaringan 0*

Di sembarang VM:
+ Run command yang berjalan lama di background: `sleep 1000 &`
+ Find PID dengan `ps aux | grep sleep` atau `pgrep sleep`
+ Show process tree dengan `pstree` atau `ps -ef --forest`
+ Send signal: `kill -STOP <pid>` (pause), verify dengan `ps -o pid,state,comm <pid>` → state harus T (stopped)
+ Resume: `kill -CONT <pid>`
+ Run command dengan priority lebih rendah: `nice -n 10 yes > /dev/null &`, verifikasi priority dengan `ps -o pid,ni,comm`
+ Kill semua proses test

= Pelaksanaan dan Verifikasi

- *Fase build* (90 menit pertama): kelompok bekerja bebas, boleh menggunakan AI tools, dokumentasi, internet, man pages
- *Fase verifikasi* (30 menit terakhir): dosen rotasi ke tiap kelompok
- Untuk tiap tugas yang ditunjukkan, dosen memilih *random* satu anggota kelompok untuk mendemonstrasikan atau menjelaskan
  - Contoh: "Sari, tunjukkan saya isi `/etc/fstab` dan jelaskan kenapa butuh field options"
  - Anggota lain tidak boleh mengetik atau mengoperasikan keyboard saat anggota terpilih demo
  - Boleh diskusi verbal singkat untuk panduan, tapi *penalty individual* diterapkan jika anggota terpilih kesulitan
- Jika satu tugas gagal, lanjut ke tugas berikut — partial credit tetap diberikan
- *AI policy*: tidak ada larangan AI tools selama fase build. Tapi dosen mengamati keyboard saat verifikasi → student tidak bisa MITM pertanyaan ke AI real-time

= Penilaian

== Bobot per Tugas dan Matkul

#table(
  columns: (auto, 1fr, auto, auto),
  stroke: 0.5pt + gray-text,
  inset: 2mm,
  align: (left, left, right, right),
  fill: (col, row) => if row == 0 { header-bg },
  [*Tugas*], [*Topik*], [*SO*], [*Jar*],
  [1], [Disk + Filesystem + Mount], [15], [0],
  [2], [User + Permissions + SSH], [10], [5],
  [3], [Package + Service], [15], [10],
  [4], [Network Config Persistent], [0], [20],
  [5], [DNS Server + Client], [0], [15],
  [6], [Shell Script Automation], [15], [5],
  [7], [HTTP via Telnet], [0], [10],
  [8], [Troubleshooting + Capture], [10], [15],
  [9], [Process Management], [10], [0],
  [—], [Individual contribution (random call)], [25], [20],
  table.cell(fill: header-bg)[*Total*],
  table.cell(fill: header-bg)[*Skala penuh per matkul*],
  table.cell(fill: header-bg, align: right)[*100*],
  table.cell(fill: header-bg, align: right)[*100*],
)

== Individual Contribution Scoring

Dosen menilai per matkul berdasarkan random calls saat verifikasi:

- Anggota yang gagal menjawab random call untuk task SO-heavy: penalty di nilai SO individu (#sym.minus 10), tidak mempengaruhi anggota lain
- Anggota yang gagal menjawab random call untuk task Jaringan-heavy: penalty di nilai Jaringan individu (#sym.minus 10)
- Anggota yang konsisten kontribusi rendah di kedua matkul: penalty ganda

*Lulus minimum per matkul*: 60. Kelompok dengan satu nilai matkul di bawah 60 harus remedial untuk matkul tersebut saja.

= Logistics

- *Jumlah kelompok*: ~9 kelompok (27 mahasiswa / 3)
- *Penjadwalan*: 120 menit per kelompok, paralel max 3 kelompok di ruang yang sama
- *Bisa dijalankan dalam 1 hari* dengan rotasi: 3 kelompok per slot, total 3 slot
- *Backup plan*: jika VM crash atau VirtualBox bermasalah, kelompok dapat extra 20 menit

= Checklist Dosen Sebelum Hari H

- #box[☐] Print dokumen ini untuk tiap kelompok
- #box[☐] Verifikasi semua kelompok punya snapshot `BASELINE` lengkap dengan disk tambahan
- #box[☐] Siapkan rubric scoring sheet per kelompok per matkul (2 sheet × jumlah kelompok)
- #box[☐] Siapkan daftar sabotage scenario untuk Tugas 8 (variasi per kelompok)
- #box[☐] Siapkan jadwal rotasi verifikasi per slot
- #box[☐] Test sendiri 1 kelompok end-to-end → estimasi waktu real

#pagebreak()

= Appendix — Pemetaan LPIC-1 Objectives

Materi UTS ini menyentuh subset objective LPIC-1 berikut (sumber: #link("https://www.lpi.org/our-certifications/lpic-1-overview")[lpi.org/our-certifications/lpic-1-overview]):

#table(
  columns: (auto, 1fr, auto),
  stroke: 0.5pt + gray-text,
  inset: 2mm,
  align: (left, left, center),
  fill: (col, row) => if row == 0 { header-bg },
  [*Objective*], [*Topik*], [*Tugas*],
  [102.4 / 102.5], [Package management (apk/apt/yum)], [3],
  [101.3], [Boot system, change runlevels (service mgmt)], [3],
  [103.5], [Create, monitor, kill processes], [9],
  [103.6], [Modify process execution priorities], [9],
  [104.1], [Create partitions and filesystems], [1],
  [104.3], [Control mounting and unmounting (fstab)], [1],
  [104.5], [Manage file permissions and ownership], [2],
  [105.2], [Customize or write simple scripts], [6],
  [107.1], [Manage user and group accounts], [2],
  [108.2], [System logging], [3, 8],
  [109.1], [Fundamentals of internet protocols], [7],
  [109.2], [Persistent network configuration], [4],
  [109.3], [Basic network troubleshooting], [8],
  [109.4], [Configure client side DNS], [5],
  [110.1], [Perform security administration tasks], [8],
  [110.2], [Setup host security (SSH hardening)], [2],
)

== Self-Study Lanjutan untuk LPIC-1

Setelah lulus mata kuliah, mahasiswa yang ingin mengejar sertifikasi LPIC-1 dapat melengkapi gap berikut secara mandiri:

- *Objective 102.1, 102.2*: Hard disk layout design, GRUB boot manager
- *Objective 102.3*: Shared libraries (ldd, ldconfig)
- *Objective 103.1–.4, .7, .8*: CLI tools depth, text processing, vi/nano
- *Objective 104.2*: Filesystem integrity (fsck, tune2fs)
- *Objective 104.6, .7*: Hard/symbolic links, find/locate
- *Objective 105.1*: Shell environment customization
- *Objective 107.2*: Cron jobs (akan dibahas di UAS)
- *Objective 107.3*: Localisation (timezone, locale)
- *Objective 108.1, .3*: NTP, MTA basics
- *Objective 110.3*: Encryption (SSH covered, GPG sebagai self-study)

Resources gratis:
- #link("https://learning.lpi.org/")[learning.lpi.org] — official learning materials
- #link("https://wiki.alpinelinux.org/")[wiki.alpinelinux.org] — Alpine docs
- *"Pro Linux System Administration"* by Dennis Matotek et al
- *"How Linux Works"* by Brian Ward
