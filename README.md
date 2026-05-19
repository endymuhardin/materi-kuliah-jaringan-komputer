# Materi Kuliah — Jaringan Komputer (Sentul)

Materi ujian formal untuk kelas gabungan Sentul, mencakup dua mata kuliah secara terintegrasi:
- **MITI.202** Sistem Operasi (Teknik Informatika)
- **MITI.203** Jaringan Komputer dan Komputasi Awan (Teknik Informatika)

Plus paralel SI:
- **MISI.202** Sistem Operasi dan Drone GIS (Sistem Informasi)
- **MISI.203** Integrasi dan Deployment Sistem (Sistem Informasi)

Kelas merged di kampus Sentul. UTS dan UAS dirancang sebagai **combined exam** — satu sesi praktik menghasilkan dua nilai (Sistem Operasi + Jaringan), selaras dengan objectives LPIC-1 dan LPI DevOps Tools Engineer. Lihat [CLAUDE.md](CLAUDE.md) untuk konteks pendekatan kurikulum.

## Struktur repo

```
.
├── README.md                          # file ini
├── CLAUDE.md                          # context untuk AI assistant
├── source/                            # typst source files
│   ├── uts-sentul.typ                 # UTS combined (SO + Jaringan)
│   └── uas-sentul.typ                 # UAS combined (SO + Jaringan)
├── typesetting/
│   ├── library/                       # letterhead template & palette (from kelembagaan-tazkia)
│   │   ├── page.typ
│   │   ├── fonts.typ
│   │   └── palette.typ
│   └── build.sh                       # build script
├── assets/
│   └── logo/                          # STMIK logos
├── output/                            # generated PDFs (gitignored except for releases)
└── *.md                               # original markdown drafts (historical)
```

## Build PDF

Prerequisite: [typst](https://github.com/typst/typst) 0.14+ terinstall.

```bash
./typesetting/build.sh
```

Atau manual per file:

```bash
typst compile --root . source/uts-sentul.typ output/uts-sentul.pdf
typst compile --root . source/uas-sentul.typ output/uas-sentul.pdf
```

## Fonts

Templates pakai Noto Sans + JetBrains Mono. Install:

```bash
# macOS
brew install font-noto-sans font-jetbrains-mono

# Linux (Debian/Ubuntu)
apt install fonts-noto-core fonts-jetbrains-mono
```

## Dokumen

| File | Deskripsi |
|---|---|
| `source/uts-sentul.typ` | UTS sesi 8 — combined hands-on (Linux sysadmin + network config) untuk SO + Jaringan, selaras LPIC-1 objectives |
| `source/uas-sentul.typ` | UAS sesi 16 — combined deployment demo + failure recovery untuk SO + Jaringan, selaras LPI DevOps Tools Engineer |
| `uts-jaringan-sentul.md`, `uas-jaringan-sentul.md` | Original markdown drafts (historical, kept for reference) |

## Lisensi

Internal STMIK Tazkia. Tidak untuk distribusi publik.
