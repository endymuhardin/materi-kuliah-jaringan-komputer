# CLAUDE.md

Konteks untuk Claude Code saat bekerja di repo ini.

## Tujuan repo

Materi ujian formal (UTS, UAS) dan dokumen pendukung untuk mata kuliah Jaringan Komputer kelas Sentul. Output adalah PDF berkop surat STMIK Tazkia untuk distribusi ke mahasiswa.

## Konteks mata kuliah

- **Semester**: Genap 2025/2026
- **Kelas**: Merged TIK.25 + SIF.25 Sentul (27 mahasiswa total — 14 TI + 13 SI)
- **Pengampu**: Endy Muhardin (kedua jadwal, dengan id_dosen override di MISI.203 yang nominal Kus)
- **Jadwal di SMILE (aplikasi-akademik)**:
  - MITI.203 Jaringan Komputer dan Komputasi Awan (TIK.25 Sentul): `4fef1c9f-3120-4b41-9b6e-178177aa4832`
  - MISI.203 Integrasi dan Deployment Sistem (SIF.25 Sentul): `16da50e5-3f4c-474e-9042-cf8345cf6390`

## Pendekatan kurikulum

Karena kelas gabungan TI + SI, kurikulum di-compress dan re-balance:
- **Sesi 1–8 (sebelum UTS)**: networking fundamentals — TCP/IP, IP addressing, routing+NAT, DNS+HTTP, troubleshooting+security, UTS prep, UTS
- **Sesi 9–16 (sebelum UAS)**: application + deployment — Git/CI, Docker, testing, UAT, VPS deploy, CD pipeline + monitoring, docs/backup, UAS

Topik yang **sengaja didrop** (irrelevan untuk dev/DevOps di 2026):
- Switching/VLAN (Cisco-centric, dev tidak akan touch ini)
- SMTP/IMAP deep dive (diganti HTTP via telnet)
- TLS protocol internals (left for cryptography course)
- BGP/MPLS detail

Sample app untuk deployment = single-file ExpressJS atau static HTML, AI-generated OK. Domain dibeli mahasiswa di sesi 5 (~$10/tahun) dan dipakai sampai sesi 16.

## Filosofi UTS dan UAS

**Hands-on saja, tidak ada soal tertulis.** Alasan: AI tools sudah memudahkan soal tertulis sampai cheating jadi trivial. Verifikasi competence lewat:
- Pengamatan langsung saat student mengetik di keyboard (AI MITM tidak workable real-time)
- Pertanyaan grounded di artifact mereka, bukan textbook knowledge
- Random call ke anggota kelompok individual untuk demo bagian tertentu

**Combined exam (1 ujian → 2 nilai).** UTS dan UAS dirancang sebagai single hands-on session yang menghasilkan dua nilai sekaligus: untuk Sistem Operasi (MITI.202 / MISI.202) dan Jaringan Komputer (MITI.203 / MISI.203). Tiap tugas/komponen di-tag dengan weight per matkul. Mengurangi beban student tanpa mengurangi rigor.

**Kelompok**: max 3 orang per kelompok, sama antar UTS dan UAS untuk konsistensi.

**UTS** = Linux sysadmin + network configuration challenge dengan VirtualBox VM (Alpine Linux). 9 tugas: disk/filesystem, user/permissions, package+service, network config, DNS, shell script, HTTP via telnet, troubleshooting, process management. Selaras dengan LPIC-1 objectives (101+102+109+110).

**UAS** = production deployment demo + failure recovery live. Dosen introduce fault dari katalog 8 skenario via lottery → kelompok diagnose + fix dalam 15 menit. Selaras dengan LPI DevOps Tools Engineer objectives (701–705).

## LPI Certification Alignment

Kurikulum disusun (loosely) supaya mahasiswa dapat melanjutkan ke sertifikasi LPI vendor-neutral secara mandiri setelah lulus:

| Cert | Exam | Selaras dengan |
|---|---|---|
| LPIC-1 (Linux Sysadmin) | LPI 101 + 102 | Materi sesi 2–7 + UTS |
| LPI DevOps Tools Engineer | 010-160 | Materi sesi 9–15 + UAS |

Setiap dokumen UTS/UAS memiliki appendix yang memetakan tugas ke LPI objective dan menunjukkan gap untuk self-study. Resources: learning.lpi.org, books, dan free practice exams online.

## Format dokumen

- Source: Typst (`.typ`)
- Output: PDF dengan kop surat STMIK Tazkia
- Template letterhead: dicopy dari `~/workspace/stmik/kelembagaan-tazkia/typesetting/library/` ke `typesetting/library/`
- Logo: dicopy dari `~/workspace/stmik/kelembagaan-tazkia/assets/logo/`
- Build: `./typesetting/build.sh` atau `typst compile --root . source/*.typ output/*.pdf`

## Konvensi

- Bahasa: Indonesia
- Istilah teknis: pertahankan istilah Inggris (Router, VLAN, NAT, DNS, dll) tidak diterjemahkan
- Heading hierarchy: max 3 level (h1 = section utama, h2 = sub-section, h3 = sub-sub-section)
- Tabel: gunakan typst `table()` atau `grid()`, hindari raw HTML
- Code blocks: gunakan ``` dengan language tag jika ada

## Related repos

- `~/workspace/stmik/kelembagaan-tazkia/` — sumber letterhead template, kurikulum source JSON
- `~/workspace/tazkia/aplikasi-akademik/` — SMILE (database mahasiswa, presensi, dll). Tools/runbook untuk recording sesi ada di sana.

## Future additions (potential)

- RPS (Rencana Pembelajaran Semester) versi formal untuk semester ini
- Lab manual per sesi
- Rubric scoring sheet (Excel/PDF)
- Lembar amplop failure scenario untuk UAS (siap print)
