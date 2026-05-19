# UAS — Jaringan Komputer Sentul (Sesi 16)

Demonstrasi sistem deployment production dengan failure recovery live. Tidak ada soal tertulis.

## Tujuan

Memverifikasi mahasiswa berhasil mendeploy aplikasi sederhana ke production (VPS) dengan domain HTTPS + CI/CD + monitoring, dan dapat melakukan diagnosis serta recovery ketika sistem mengalami gangguan operasional.

## Format

- **Grup**: kelompok yang sama dengan UTS (max 3 orang)
- **Durasi per kelompok**: 35 menit
- **Pengamatan**: dosen utama + 1 panel observer (opsional)
- **Materials**: laptop kelompok dengan akses SSH ke VPS, GitHub repo, browser untuk demo

## Prerequisite (dibangun selama sesi 13–15)

Sebelum UAS, tiap kelompok harus memiliki:

1. **Domain aktif** dari ke 5 (still active, paid through end of semester)
2. **Aplikasi sederhana** (single-file ExpressJS atau static HTML, AI-generated OK) di GitHub repo public
3. **VPS deployment**: aplikasi running di VPS dengan domain → HTTPS via Caddy/Let's Encrypt
4. **CI/CD pipeline**: push ke main branch → GitHub Actions → auto-deploy ke VPS
5. **Monitoring**: Uptime Kuma atau setara, dashboard accessible untuk demo
6. **Dokumentasi**: README di GitHub dengan:
   - Arsitektur diagram
   - Runbook: restart procedure, rollback procedure, restore from backup

### Prerequisite enforcement

- Sesi 15 (dry-run): dosen review semua prerequisite per kelompok
- Kelompok dengan prerequisite **lengkap**: ikut UAS full (35 menit, semua fase)
- Kelompok dengan prerequisite **parsial**: ikut UAS dengan demo hanya bagian yang siap, failure recovery tetap dijalankan kalau system di-deploy (skip kalau tidak)
- Kelompok dengan prerequisite **kosong** (tidak ada VPS deployment): gagal UAS, hanya bisa presentasi konsep saja, max score 40

## Pelaksanaan per kelompok (35 menit)

### Fase 1 — Presentasi dan demo working system (15 menit)

**Presentasi (10 menit)**:
- Slide singkat: aplikasi apa, arsitektur, tech stack, lessons learned
- Diagram alur: GitHub → CI/CD → VPS → Domain (HTTPS) → User
- Pembagian peran dalam kelompok

**Demo working system (5 menit)**:
- Browse ke `https://<domain>` dari browser → site loads correctly dengan HTTPS valid
- Tunjukkan monitoring dashboard → uptime status
- Tunjukkan struktur GitHub repo

### Fase 2 — Demo CI/CD live (5 menit)

- Dosen pilih random satu anggota kelompok untuk demo
- Anggota tersebut: edit sesuatu kecil di aplikasi (misal teks di halaman atau response API)
- Commit + push ke main branch dari laptop sendiri
- Buka tab GitHub Actions → tunggu workflow berjalan
- Setelah deploy selesai: refresh browser → perubahan terlihat di production
- Jelaskan apa yang baru saja terjadi (high-level pipeline flow)

### Fase 3 — Failure recovery (10 menit) ← inti UAS

- Dosen menarik 1 amplop dari 8 pre-prepared scenario (lottery di depan kelompok)
- Dosen jalankan skenario fault: SSH ke VPS, eksekusi command, atau ubah config (lihat katalog di bawah)
- Setelah fault diintroduce, dosen catat waktu mulai
- Kelompok harus:
  1. Diagnose root cause (target: dalam 5 menit pertama)
  2. Recovery — kembalikan sistem ke working state (target: dalam 10 menit total)
  3. Verify sistem normal kembali (browse ke domain, cek monitoring)
- Anggota kelompok bisa kerja bersama, tapi dosen catat siapa yang berkontribusi (untuk komponen Q&A)
- Hard timeout 10 menit; jika belum recover, dosen jelaskan apa yang salah → kelompok dapat partial credit untuk diagnosis saja

### Fase 4 — Q&A grounded (10 menit)

Pertanyaan **harus berbasis artifact** kelompok, tidak abstrak. Dosen rotasi pertanyaan ke setiap anggota.

Contoh pertanyaan grounded:
- "Buka Caddyfile, tunjukkan baris yang handle reverse proxy ke aplikasi. Apa yang terjadi kalau baris itu dihapus?"
- "Buka workflow file di `.github/workflows/`. Jelaskan apa yang dilakukan step `deploy`."
- "Tunjukkan log aplikasi pada saat kemarin pukul 14:00. Jelaskan request pattern yang terlihat."
- "Kalau VPS hilang sekarang, langkah apa yang dilakukan? Tunjukkan runbook di README."
- "Buka file `.env` di VPS, jelaskan setiap variable. Mana yang sensitif dan kenapa?"

**Pertanyaan terlarang** (mendorong AI MITM):
- "Apa itu CI/CD?" (definisi abstrak)
- "Jelaskan perbedaan SNAT dan DNAT" (memori konsep)
- "Best practices untuk monitoring adalah..." (textbook answer)

## Katalog skenario failure recovery

Dosen menyiapkan 8 amplop berisi instruksi fault. Tier difficulty dicampur supaya random draw fair.

| # | Tier | Fault | Dosen action | Expected recovery |
|---|---|---|---|---|
| 1 | Mudah | Container app down | SSH VPS, `docker compose stop app` | `docker ps -a` → restart container, verify site up |
| 2 | Mudah | Reverse proxy salah port | Edit Caddyfile upstream ke port salah (misal 9999), reload Caddy | Tail Caddy log → fix Caddyfile → reload |
| 3 | Sedang | Bad deploy via CI | Dosen push commit dengan syntax error di app code | Lihat CI failure log → `git revert` di main atau fix-forward |
| 4 | Sedang | Firewall block | `ufw deny 443` di VPS | Coba browse → unreachable → `ufw status` → `ufw allow 443` |
| 5 | Sedang | Disk full | `dd if=/dev/zero of=/var/log/junk bs=1M count=5000` | `df -h` → identify junk → delete → restart affected services |
| 6 | Sulit | DNS pointing wrong | Ubah A record di registrar ke IP garbage | `dig <domain>` → recognize DNS issue → fix di registrar dashboard → wait propagation |
| 7 | Sulit | Cert renewal broken | `mv /etc/letsencrypt/live/<domain> /tmp/` di VPS, reload Caddy | Caddy log shows missing cert → re-issue via certbot atau Caddy auto |
| 8 | Sulit | App env var corrupted | Edit `.env` di VPS, ubah variable penting (misal DB connection string atau API key dummy) | App log shows error → identify env var → fix `.env` → restart container |

### Pre-prepared resources untuk dosen

- Backup snapshot VPS sebelum mulai UAS day (revert kalau kelompok benar-benar stuck atau ada damage permanen)
- Script one-liner untuk introduce setiap fault (supaya dosen tidak butuh waktu lama)
- Cheatsheet expected recovery commands per skenario (untuk grading + ngajarin kalau timeout)
- Lembar amplop berlabel skenario 1-8, untuk lottery draw publik

## Penilaian

| Komponen | Bobot |
|---|---|
| Presentasi + arsitektur | 15 |
| Demo working system | 15 |
| Demo CI/CD live | 15 |
| Failure recovery — diagnosis | 15 |
| Failure recovery — fix | 15 |
| Failure recovery — narasi | 5 |
| Q&A grounded | 20 |
| **Total** | **100** |

**Lulus minimum: 60**

### Adjustment fairness untuk failure recovery

Karena difficulty tier acak, scoring perlu disesuaikan:

- **Bobot tetap 35** (15+15+5) untuk semua tier
- **Tier mudah**: standar diagnosis dan fix lebih ketat — kelompok harus selesai dengan rapi, tidak ada exception
- **Tier sulit**: standar lebih lenient — partial credit lebih besar, dosen lebih banyak nge-guide kalau benar-benar stuck

Alternatif (tidak dipakai): sliding cap di mana tier mudah max 30, tier sulit max 35. Lebih complex grading, ditolak demi simplicity.

## Practice / dry-run di Sesi 15

- Tiap kelompok dapat 1 practice fault dari katalog (random, berbeda untuk tiap kelompok)
- Practice fault didokumentasikan dan dibahas di kelas setelah semua kelompok selesai
- Real exam fault adalah skenario yang **tidak pernah dibahas** di kelas — fresh untuk semua kelompok
- Tujuan dry-run: kelompok familiar dengan format dan tools, bukan menghapal skenario specific

## Logistics

- **Jumlah kelompok**: ~9 kelompok
- **Penjadwalan**: 35 menit per kelompok, sequential (dosen perlu fokus penuh per kelompok)
- **Total durasi**: 9 × 35 = ~5 jam → butuh 1-2 hari, atau parallel session dengan multiple dosen
- **Backup plan**: jika VPS provider down atau internet bermasalah, demo dari local docker-compose dengan disclosure → max score 70

## Checklist dosen sebelum hari H

- [ ] Print dokumen ini untuk tiap kelompok
- [ ] Print katalog failure scenario (1 set untuk dosen)
- [ ] Siapkan amplop berisi skenario 1-8 untuk lottery
- [ ] Backup snapshot VPS untuk setiap kelompok (kalau perlu rollback)
- [ ] Verifikasi semua kelompok sudah punya prerequisite di sesi 15
- [ ] Siapkan rubric scoring sheet per kelompok
- [ ] Tentukan jadwal slot per kelompok
- [ ] Test sendiri 1 fault scenario end-to-end → estimasi waktu real

## Pasca UAS

- Compile lessons learned dari semua kelompok → bahan refleksi semester depan
- Skenario yang paling sering gagal → indikasi materi yang perlu diperkuat di iterasi berikutnya
- Skenario yang terlalu mudah → ganti dengan yang lebih relevan
- Domain dan VPS milik mahasiswa: ingatkan untuk dipertahankan atau di-decommission dengan benar
