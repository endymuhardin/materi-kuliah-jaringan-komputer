#import "/typesetting/library/page.typ": letterhead-page
#import "/typesetting/library/palette.typ": *

#let meta = (
  title: "Form Penilaian UTS — Sistem Operasi + Jaringan Komputer",
  version: "v1.0",
  date: "2026-06-09",
  institution: "STMIK Tazkia",
  output: "../output/form-penilaian-uts.pdf",
)

#show: letterhead-page.with(meta)

// ── Helpers ───────────────────────────────────────────────────────────────

// Kotak isian (fill-in blank) untuk angka skor
#let blank(w: 14mm) = box(width: w, stroke: (bottom: 0.6pt + gray-strong), inset: (bottom: 1mm))[ ]

// Kotak centang
#let chk = box(width: 4mm, height: 4mm, stroke: 0.6pt + gray-strong)

// Checklist checkpoint: items = array of (k: <kriteria>, so: <int>, j: <int>)
#let checklist(items) = table(
  columns: (8mm, 1fr, 11mm, 11mm),
  stroke: 0.5pt + gray-text,
  inset: 2mm,
  align: (center + horizon, left, center + horizon, center + horizon),
  fill: (col, row) => if row == 0 { header-bg },
  [*✓*], [*Kriteria observable — centang hanya bila diverifikasi langsung*], [*SO*], [*Jar*],
  ..items.map(it => ([#chk], it.k, [#it.so], [#it.j])).flatten(),
)

// Render satu tugas lengkap: heading + tag + checklist + baris subtotal
#let task(num, title, tag, items) = {
  let maxso = items.fold(0, (a, it) => a + it.so)
  let maxj = items.fold(0, (a, it) => a + it.j)
  heading(level: 2)[Tugas #num — #title]
  text(size: 8pt, fill: gray-text, weight: "bold")[#tag]
  v(1mm)
  checklist(items)
  v(1mm)
  grid(
    columns: (1fr, auto),
    align: (left + horizon, right + horizon),
    text(size: 8pt, fill: gray-text)[Catatan penilai: #blank(w: 70mm)],
    text(size: 9pt)[*Subtotal:* SO #blank(w: 10mm)\/#maxso #h(3mm) Jar #blank(w: 10mm)\/#maxj],
  )
  v(2mm)
}

// ── Header dokumen ──────────────────────────────────────────────────────────

#align(center)[
  #text(size: 16pt, weight: "bold", fill: blue-dark)[Form Penilaian UTS]
  #v(2mm)
  #text(size: 13pt, weight: "bold")[Sistem Operasi + Jaringan Komputer — Kelas Sentul]
  #v(1mm)
  #text(size: 10pt, fill: gray-text)[Sesi 8 · Semester Genap 2025/2026 · Combined Exam]
]

#v(3mm)

#table(
  columns: (30mm, 1fr, 22mm, 1fr),
  stroke: 0.5pt + gray-text,
  inset: 2mm,
  [*Kelompok*], [], [*Slot/Jam*], [],
  [*Anggota 1*], [], [*Anggota 2*], [],
  [*Anggota 3*], [], [*Tanggal*], [],
  [*Penilai*], [], [*Tanda tangan*], [],
)

#v(2mm)

#box(
  fill: note-bg,
  stroke: 0.5pt + note-border,
  inset: 3mm,
  width: 100%,
)[
  *Panduan penilai (baca sebelum mulai).*
  - Checkpoint bersifat *binary*: tercapai = poin penuh, tidak tercapai = 0. Bila genuinely separuh, tulis nilai parsial di kolom dan beri catatan alasan. Default tetap binary supaya antar-penilai konsisten.
  - Centang hanya bila *diverifikasi langsung* di layar (output command, hasil reboot, capture Wireshark), bukan klaim lisan kelompok.
  - *Bagian A (Tugas 1–9)* dinilai *per kelompok* — satu skor untuk semua anggota.
  - *Bagian B (Kontribusi Individual)* dinilai *per anggota* dari random call saat verifikasi. Penalti satu anggota tidak menurunkan anggota lain.
  - *Nilai akhir per anggota per matkul* = subtotal tugas (shared) + kontribusi individual anggota tersebut.
  - *Multi-penilai* (untuk mempercepat): (1) tiap penilai memegang kelompok berbeda secara paralel dengan form identik ini; atau (2) dua penilai menilai kelompok yang sama lalu dirata-rata — jika selisih total per matkul > 10 poin, rekonsiliasi dulu sebelum final.
  - *Lulus minimum: 60 per matkul.*
]

#v(2mm)

= Bagian A — Penilaian Tugas (per kelompok)

#task(1, "Disk Partitioning + Filesystem + Mount", "LPIC 104.1, 104.3", (
  (k: [Partisi disk kedua dibuat (`fdisk`/`parted`, satu primer full disk)], so: 3, j: 0),
  (k: [Format ext4 berhasil (`mkfs.ext4 /dev/sdb1`)], so: 3, j: 0),
  (k: [Mount manual ke `/data` berhasil], so: 3, j: 0),
  (k: [Entry `/etc/fstab` benar (device, mountpoint, fs, options)], so: 3, j: 0),
  (k: [Verifikasi `reboot`: `/data` tetap ter-mount otomatis], so: 3, j: 0),
))

#task(2, "User & Permissions + SSH Hardening", "LPIC 104.5, 107.1, 110.2", (
  (k: [User `admin` dibuat dengan sudo access (`wheel` / sudoers)], so: 4, j: 0),
  (k: [`/data` di-set ownership `admin:admin`, permission 770], so: 4, j: 0),
  (k: [`PermitRootLogin no` di `sshd_config`, sshd di-restart], so: 2, j: 0),
  (k: [Login SSH sebagai `admin` dengan key berhasil], so: 0, j: 2),
  (k: [Login root via SSH ditolak (diverifikasi)], so: 0, j: 3),
))

#task(3, "Package Install + Service Management", "LPIC 102.4, 101.3, 108.2", (
  (k: [nginx ter-install & terverifikasi (`apk` / `which nginx`)], so: 3, j: 0),
  (k: [Halaman index custom berisi nama kelompok], so: 2, j: 2),
  (k: [nginx di-enable saat boot (`rc-update add` / `systemctl enable`)], so: 4, j: 0),
  (k: [Service running + status dicek (`rc-service status`)], so: 4, j: 2),
  (k: [`access.log` menampilkan request masuk saat di-akses], so: 2, j: 6),
))

#task(4, "Network Configuration Persistent", "LPIC 109.2", (
  (k: [Static IP benar di 5 VM (router eth1/eth2, A1, A2, B1, B2)], so: 0, j: 6),
  (k: [Konfigurasi persistent di `/etc/network/interfaces`], so: 0, j: 4),
  (k: [IP forwarding persistent (`sysctl.conf` + `sysctl -p`)], so: 0, j: 3),
  (k: [MASQUERADE NAT rule terpasang + di-save persistent], so: 0, j: 3),
  (k: [Verifikasi ping cross-LAN (A ↔ B) berhasil], so: 0, j: 2),
  (k: [Verifikasi ping 8.8.8.8 dari client (NAT bekerja)], so: 0, j: 2),
))

#task(5, "DNS Server + Client", "LPIC 108, 109.4", (
  (k: [dnsmasq di A1: `address=/tugas.lab/192.168.20.10`], so: 0, j: 4),
  (k: [dnsmasq di-enable + start sebagai service], so: 0, j: 3),
  (k: [`resolv.conf` A2 menunjuk ke A1 (`nameserver 192.168.10.10`)], so: 0, j: 2),
  (k: [`dig @192.168.10.10 tugas.lab` resolve ke IP benar], so: 0, j: 3),
  (k: [Dari A2 `dig tugas.lab` (via resolv.conf) tetap resolve], so: 0, j: 3),
))

#task(6, "Shell Script Automation", "LPIC 105.2", (
  (k: [Validasi jumlah parameter (exit + error message bila salah)], so: 3, j: 0),
  (k: [Validasi format IP (regex match dasar)], so: 3, j: 0),
  (k: [Flush address lama + set address & default gateway], so: 3, j: 2),
  (k: [Set DNS di `/etc/resolv.conf`], so: 2, j: 0),
  (k: [Interface di-up + tes ping gateway 3× ditampilkan], so: 2, j: 1),
  (k: [Script dijalankan ulang di client, setting baru aktif], so: 2, j: 2),
))

#task(7, "HTTP via Telnet", "LPIC 109.1", (
  (k: [`telnet tugas.lab 80` connect (resolve via DNS kelompok)], so: 0, j: 2),
  (k: [Request manual benar dengan header `Host:` yang tepat], so: 0, j: 3),
  (k: [Baca response: status line, headers, body (nama kelompok)], so: 0, j: 3),
  (k: [Jelaskan fungsi `Host:` header + alasan blank line], so: 0, j: 2),
))

#task(8, "Network Troubleshooting + tcpdump Capture", "LPIC 109.3, 110.1", (
  (k: [Diagnosis sabotase dosen dalam target 5 menit], so: 3, j: 4),
  (k: [Perbaikan benar, konektivitas pulih (diverifikasi)], so: 2, j: 3),
  (k: [Capture `trace.pcap` dengan `tcpdump`], so: 2, j: 1),
  (k: [Wireshark: DNS resolution query ditunjukkan], so: 0, j: 2),
  (k: [Wireshark: TCP 3-way handshake ditunjukkan], so: 1, j: 1),
  (k: [Wireshark: HTTP GET request ditunjukkan], so: 0, j: 2),
  (k: [Wireshark: source IP setelah NAT = IP router (di eth0)], so: 2, j: 2),
))

#task(9, "Process Management", "LPIC 103.5, 103.6", (
  (k: [Jalankan job background + temukan PID (`ps`/`pgrep`)], so: 2, j: 0),
  (k: [Tampilkan process tree (`pstree` / `ps -ef --forest`)], so: 2, j: 0),
  (k: [`kill -STOP` → state `T` diverifikasi (`ps -o state`)], so: 2, j: 0),
  (k: [`kill -CONT` melanjutkan proses], so: 1, j: 0),
  (k: [`nice -n 10` + verifikasi priority (`ps -o ni`)], so: 2, j: 0),
  (k: [Hentikan semua proses test (cleanup)], so: 1, j: 0),
))

#pagebreak()

= Bagian B — Kontribusi Individual (per anggota)

Dinilai dari *random call* saat fase verifikasi: dosen menunjuk satu anggota untuk demo/menjelaskan bagian tertentu, anggota lain tidak boleh menyentuh keyboard. Gunakan band berikut untuk konsistensi antar-penilai.

#table(
  columns: (auto, 1fr, 16mm, 16mm),
  stroke: 0.5pt + gray-text,
  inset: 2mm,
  align: (left + horizon, left, center + horizon, center + horizon),
  fill: (col, row) => if row == 0 { header-bg },
  [*Level*], [*Deskripsi (apa yang diamati saat random call)*], [*SO*], [*Jar*],
  [Mandiri penuh], [Demo benar + jelaskan *alasan* untuk semua random call, tanpa bantuan], [22–25], [18–20],
  [Kompeten], [Demo benar, penjelasan parsial / sedikit ragu], [17–21], [14–17],
  [Cukup], [Demo benar tapi perlu bantuan verbal kelompok], [12–16], [10–13],
  [Lemah], [Gagal sebagian besar random call], [5–11], [4–9],
  [Tidak berkontribusi], [Tidak dapat mendemonstrasikan / menjelaskan apa pun], [0–4], [0–3],
)

#v(1mm)
#text(size: 8pt, fill: gray-text)[Catatan: random call task SO-heavy menilai kolom SO; task Jaringan-heavy menilai kolom Jar. Beri penalti pada kolom yang relevan saja.]

#v(3mm)

#table(
  columns: (8mm, 1fr, 18mm, 18mm, 1fr),
  stroke: 0.5pt + gray-text,
  inset: 2mm,
  align: (center + horizon, left, center + horizon, center + horizon, left),
  fill: (col, row) => if row == 0 { header-bg },
  [*\#*], [*Nama anggota*], [*SO ind \/25*], [*Jar ind \/20*], [*Catatan random call*],
  [1], [], [], [], [],
  [2], [], [], [], [],
  [3], [], [], [], [],
)

#v(4mm)

= Rekap Nilai Akhir

Nilai akhir per anggota = subtotal tugas kelompok (Bagian A) + kontribusi individual (Bagian B).

#set text(size: 8pt)
#table(
  columns: (1fr, 18mm, 18mm, 18mm, 18mm, 18mm, 18mm, 14mm),
  stroke: 0.5pt + gray-text,
  inset: 1.5mm,
  align: (left + horizon, center + horizon, center + horizon, center + horizon, center + horizon, center + horizon, center + horizon, center + horizon),
  fill: (col, row) => if row == 0 { header-bg },
  [*Nama anggota*],
  [*SO klp \/75*], [*SO ind \/25*], [*SO tot \/100*],
  [*Jar klp \/80*], [*Jar ind \/20*], [*Jar tot \/100*],
  [*Lulus?*],
  [], [], [], [], [], [], [], [],
  [], [], [], [], [], [], [], [],
  [], [], [], [], [], [], [], [],
)
#set text(size: 9pt)

#v(1mm)
#text(size: 8pt, fill: gray-text)[*Lulus* bila kedua matkul ≥ 60. Kelompok/anggota dengan satu nilai matkul < 60 remedial untuk matkul tersebut saja. Kolom "klp" = subtotal tugas kelompok (Bagian A), sama untuk semua anggota.]

#v(4mm)

#grid(
  columns: (1fr, 1fr),
  gutter: 10mm,
  [
    Penilai 1 \
    #v(10mm)
    #line(length: 50mm, stroke: 0.5pt + gray-strong) \
    Nama & tanda tangan
  ],
  [
    Penilai 2 (bila ada) \
    #v(10mm)
    #line(length: 50mm, stroke: 0.5pt + gray-strong) \
    Nama & tanda tangan
  ],
)
