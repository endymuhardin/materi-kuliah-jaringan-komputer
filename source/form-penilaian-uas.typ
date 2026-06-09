#import "/typesetting/library/page.typ": letterhead-page
#import "/typesetting/library/palette.typ": *

#let meta = (
  title: "Form Penilaian UAS — Sistem Operasi + Jaringan Komputer",
  version: "v1.0",
  date: "2026-06-09",
  institution: "STMIK Tazkia",
  output: "../output/form-penilaian-uas.pdf",
)

#show: letterhead-page.with(meta)

// ── Helpers ───────────────────────────────────────────────────────────────

#let blank(w: 14mm) = box(width: w, stroke: (bottom: 0.6pt + gray-strong), inset: (bottom: 1mm))[ ]
#let chk = box(width: 4mm, height: 4mm, stroke: 0.6pt + gray-strong)

// Checklist checkpoint biner (untuk komponen yang verifiable)
#let checklist(items) = table(
  columns: (8mm, 1fr, 11mm, 11mm),
  stroke: 0.5pt + gray-text,
  inset: 2mm,
  align: (center + horizon, left, center + horizon, center + horizon),
  fill: (col, row) => if row == 0 { header-bg },
  [*✓*], [*Kriteria observable — centang hanya bila diverifikasi langsung*], [*SO*], [*Jar*],
  ..items.map(it => ([#chk], it.k, [#it.so], [#it.j])).flatten(),
)

// Band rubric berbasis level (untuk komponen judgment-based)
#let bands(rows) = table(
  columns: (auto, 1fr, 14mm, 14mm),
  stroke: 0.5pt + gray-text,
  inset: 2mm,
  align: (left + horizon, left, center + horizon, center + horizon),
  fill: (col, row) => if row == 0 { header-bg },
  [*Level*], [*Kriteria*], [*SO*], [*Jar*],
  ..rows.map(r => (r.lv, r.k, [#r.so], [#r.j])).flatten(),
)

#let subtotal(maxso, maxj) = {
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
  #text(size: 16pt, weight: "bold", fill: blue-dark)[Form Penilaian UAS]
  #v(2mm)
  #text(size: 13pt, weight: "bold")[Sistem Operasi + Jaringan Komputer — Kelas Sentul]
  #v(1mm)
  #text(size: 10pt, fill: gray-text)[Sesi 16 · Semester Genap 2025/2026 · Combined Exam]
]

#v(3mm)

#table(
  columns: (30mm, 1fr, 22mm, 1fr),
  stroke: 0.5pt + gray-text,
  inset: 2mm,
  [*Kelompok*], [], [*Slot/Jam*], [],
  [*Anggota 1*], [], [*Anggota 2*], [],
  [*Anggota 3*], [], [*Tanggal*], [],
  [*Domain*], [], [*Skenario fault (\#)*], [],
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
  - Komponen *verifiable* (demo working, CI/CD live) memakai checkpoint *binary*: tercapai = poin penuh, tidak = 0.
  - Komponen *judgment-based* (presentasi, failure recovery, narasi, Q&A) memakai *band level*: pilih satu level, lalu tetapkan angka di dalam range band tersebut. Tulis alasan di catatan bila memilih ujung bawah/atas.
  - *Failure recovery — adjustment tier* (difficulty diundi, jadi standar disesuaikan): tier *Mudah* → standar lebih ketat, harus selesai rapi tanpa exception, condong ke ujung bawah band bila ada cacat. Tier *Sulit* → lebih lenient, partial credit lebih besar, dosen boleh nge-guide. Bobot tetap 35 (15+15+5) untuk semua tier.
  - *Komponen kelompok* dinilai sekali; *kontribusi individual* dinilai per anggota.
  - *Nilai akhir per anggota* = komponen kelompok (shared) + kontribusi individual anggota tersebut.
  - *Multi-penilai*: (1) tiap penilai memegang kelompok berbeda dengan form identik; atau (2) dua penilai menilai kelompok sama lalu dirata-rata — selisih total per matkul > 10 poin direkonsiliasi sebelum final.
  - *Lulus minimum: 60 per matkul.*
]

#v(2mm)

= Fase 1 — Presentasi & Demo Working System

== Komponen 1 — Presentasi + Arsitektur (band)

#bands((
  (lv: [Sangat baik], k: [Arsitektur lengkap & akurat (HTTPS, reverse proxy, DNS, CI/CD path, monitoring), diagram alur benar, peran jelas, lessons learned konkret], so: [9–10], j: [14–15]),
  (lv: [Baik], k: [Arsitektur benar dengan minor gap, diagram sebagian besar tepat], so: [7–8], j: [11–13]),
  (lv: [Cukup], k: [Konsep ada tapi diagram/penjelasan parsial atau kurang akurat], so: [5–6], j: [7–10]),
  (lv: [Kurang], k: [Arsitektur tidak akurat / tidak bisa dijelaskan], so: [0–4], j: [0–6]),
))
#subtotal(10, 15)

== Komponen 2 — Demo Working System (checkpoint)

#checklist((
  (k: [`https://<domain>` load dengan cert valid (tanpa warning browser)], so: 0, j: 5),
  (k: [Aplikasi disajikan via reverse proxy (app custom, bukan default page)], so: 2, j: 4),
  (k: [Monitoring dashboard menampilkan uptime status], so: 3, j: 4),
  (k: [Struktur GitHub repo ditunjukkan], so: 2, j: 2),
  (k: [Log aplikasi accessible & terbaca (`journalctl` / `docker logs`)], so: 3, j: 0),
))
#subtotal(10, 15)

= Fase 2 — Demo CI/CD Live

== Komponen 3 — Demo CI/CD Live (checkpoint)

Random member: edit → commit → push → Actions → deploy → verify.

#checklist((
  (k: [Commit + push ke `main` dari laptop anggota sendiri], so: 3, j: 2),
  (k: [GitHub Actions workflow ter-trigger & berjalan], so: 4, j: 3),
  (k: [Deploy selesai (`docker compose pull && up -d` di VPS)], so: 4, j: 3),
  (k: [Perubahan terlihat di production setelah refresh browser], so: 2, j: 2),
  (k: [Anggota menjelaskan alur pipeline (high-level)], so: 2, j: 0),
))
#subtotal(15, 10)

#pagebreak()

= Fase 3 — Failure Recovery Live

Skenario diundi (lottery). Catat nomor skenario & tier di header. Terapkan adjustment tier (lihat panduan).

== Komponen 4 — Diagnosis Root Cause (band)

#bands((
  (lv: [Sangat baik], k: [Identifikasi root cause mandiri dalam ~5 menit, pakai tools tepat sebagai bukti (logs, `df`, `dig`, `ufw status`, `docker ps`, dll)], so: [13–15], j: [13–15]),
  (lv: [Baik], k: [Root cause ditemukan dengan hint kecil / sedikit lebih lama], so: [10–12], j: [10–12]),
  (lv: [Cukup], k: [Ditemukan dengan guidance signifikan dari dosen], so: [6–9], j: [6–9]),
  (lv: [Kurang], k: [Hanya mengenali gejala, tidak sampai root cause], so: [1–5], j: [1–5]),
  (lv: [Gagal], k: [Tidak ada diagnosis bermakna], so: [0], j: [0]),
))
#subtotal(15, 15)

== Komponen 5 — Fix / Recovery (band)

#bands((
  (lv: [Sangat baik], k: [Sistem pulih penuh & rapi, diverifikasi (browse + monitoring), dalam 15 menit, mandiri], so: [13–15], j: [13–15]),
  (lv: [Baik], k: [Pulih dengan hint kecil, sedikit melewati target waktu], so: [10–12], j: [10–12]),
  (lv: [Cukup], k: [Pulih dengan guidance signifikan / fix parsial], so: [6–9], j: [6–9]),
  (lv: [Kurang], k: [Tidak pulih dalam timeout, hanya langkah parsial], so: [1–5], j: [1–5]),
  (lv: [Gagal], k: [Tidak ada upaya fix yang relevan], so: [0], j: [0]),
))
#subtotal(15, 15)

== Komponen 6 — Narasi / Komunikasi saat Recovery (band)

#bands((
  (lv: [Baik], k: [Komentar jalan yang jelas — apa yang dicek & kenapa selama recovery], so: [4–5], j: [4–5]),
  (lv: [Cukup], k: [Sebagian dijelaskan, sebagian senyap], so: [2–3], j: [2–3]),
  (lv: [Kurang], k: [Bekerja senyap / penjelasan tidak jelas], so: [0–1], j: [0–1]),
))
#subtotal(5, 5)

= Fase 4 — Q&A Grounded

== Komponen 7 — Q&A Grounded (band)

Pertanyaan berbasis artifact kelompok, dirotasi ke setiap anggota.

#bands((
  (lv: [Sangat baik], k: [Semua anggota menjawab benar, grounded di artifact masing-masing (nginx conf, workflow, log, runbook, `.env`)], so: [13–15], j: [13–15]),
  (lv: [Baik], k: [Mayoritas anggota menjawab benar dengan referensi artifact], so: [10–12], j: [10–12]),
  (lv: [Cukup], k: [Sebagian anggota menjawab; sebagian gagal menemukan/menjelaskan artifact], so: [6–9], j: [6–9]),
  (lv: [Kurang], k: [Jawaban abstrak / tidak grounded / sebagian besar gagal], so: [0–5], j: [0–5]),
))
#subtotal(15, 15)

= Komponen 8 — Kontribusi Individual (per anggota)

#bands((
  (lv: [Mandiri penuh], k: [Aktif di demo & recovery, menjawab Q&A bagiannya mandiri], so: [13–15], j: [9–10]),
  (lv: [Kompeten], k: [Berkontribusi nyata, penjelasan parsial], so: [10–12], j: [7–8]),
  (lv: [Cukup], k: [Kontribusi terbatas, perlu bantuan kelompok], so: [6–9], j: [4–6]),
  (lv: [Lemah / pasif], k: [Hampir tidak berkontribusi / tidak bisa menjelaskan bagiannya], so: [0–5], j: [0–3]),
))

#v(2mm)

#table(
  columns: (8mm, 1fr, 18mm, 18mm, 1fr),
  stroke: 0.5pt + gray-text,
  inset: 2mm,
  align: (center + horizon, left, center + horizon, center + horizon, left),
  fill: (col, row) => if row == 0 { header-bg },
  [*\#*], [*Nama anggota*], [*SO ind \/15*], [*Jar ind \/10*], [*Catatan*],
  [1], [], [], [], [],
  [2], [], [], [], [],
  [3], [], [], [], [],
)

#pagebreak()

= Rekap Nilai Akhir

Komponen kelompok (1–7) shared untuk semua anggota; kontribusi individual (8) per anggota.

#table(
  columns: (1fr, auto, auto),
  stroke: 0.5pt + gray-text,
  inset: 2mm,
  align: (left + horizon, center + horizon, center + horizon),
  fill: (col, row) => if row == 0 { header-bg },
  [*Komponen kelompok*], [*SO*], [*Jar*],
  [1 — Presentasi + arsitektur], blank(w: 12mm), blank(w: 12mm),
  [2 — Demo working system], blank(w: 12mm), blank(w: 12mm),
  [3 — Demo CI/CD live], blank(w: 12mm), blank(w: 12mm),
  [4 — Failure recovery: diagnosis], blank(w: 12mm), blank(w: 12mm),
  [5 — Failure recovery: fix], blank(w: 12mm), blank(w: 12mm),
  [6 — Failure recovery: narasi], blank(w: 12mm), blank(w: 12mm),
  [7 — Q&A grounded], blank(w: 12mm), blank(w: 12mm),
  table.cell(fill: header-bg)[*Subtotal kelompok*],
  table.cell(fill: header-bg)[*\/85*],
  table.cell(fill: header-bg)[*\/90*],
)

#v(3mm)

Nilai akhir per anggota = subtotal kelompok + kontribusi individual.

#set text(size: 8pt)
#table(
  columns: (1fr, 15mm, 15mm, 17mm, 15mm, 15mm, 17mm, 13mm),
  stroke: 0.5pt + gray-text,
  inset: 1.5mm,
  align: (left + horizon, center + horizon, center + horizon, center + horizon, center + horizon, center + horizon, center + horizon, center + horizon),
  fill: (col, row) => if row == 0 { header-bg },
  [*Nama anggota*],
  [*SO klp \/85*], [*SO ind \/15*], [*SO total \/100*],
  [*Jar klp \/90*], [*Jar ind \/10*], [*Jar total \/100*],
  [*Lulus?*],
  [], [], [], [], [], [], [], [],
  [], [], [], [], [], [], [], [],
  [], [], [], [], [], [], [], [],
)
#set text(size: 9pt)

#v(1mm)
#text(size: 8pt, fill: gray-text)[*Lulus* bila kedua matkul ≥ 60. Prerequisite kosong → max 40 (Jaringan). Backup plan (demo lokal) → max 70 per matkul. Kolom "klp" sama untuk semua anggota.]

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
