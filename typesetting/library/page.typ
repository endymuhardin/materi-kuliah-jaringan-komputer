// Base page template — A4, margins, body font.
// Dipakai sebagai #show: doc-page.with(meta: ..., institution-key: ...)
//
// meta wajib berisi: title, version, date, institution
// institution-key opsional ("stmik" atau "ut"); kalau tidak di-set, derive dari meta.institution

#import "palette.typ": *
#import "fonts.typ": *

// Throw kalau field meta yang wajib hilang. Sesuai no-fallback policy.
#let _assert-field(meta, field) = {
  if field not in meta {
    panic("meta." + field + " harus di-set di header dokumen")
  }
  meta.at(field)
}

#let _institution-key(meta) = {
  let inst = _assert-field(meta, "institution")
  if "STMIK" in inst { "stmik" } else if "Universitas Tazkia" in inst { "ut" } else {
    panic("Tidak bisa derive logo dari institution: " + inst + ". Set institution_key eksplisit.")
  }
}

#let logo-path(meta) = {
  let key = _institution-key(meta)
  if key == "stmik" {
    "/assets/logo/logo-stmik.png"
  } else {
    "/assets/logo/logo-universitas-tazkia.png"
  }
}

#let watermark-path(meta) = {
  let key = _institution-key(meta)
  if key == "stmik" {
    "/assets/logo/logo-stmik-watermark.png"
  } else {
    "/assets/logo/logo-universitas-tazkia-watermark.png"
  }
}

// Page background: watermark logo di-place center, 70mm width.
// Pakai sebagai #set page(background: watermark-bg(meta))
#let watermark-bg(meta) = place(
  center + horizon,
  image(watermark-path(meta), width: 70mm),
)

// Address book per institusi — dipakai oleh letterhead footer.
#let _address(key) = {
  if key == "stmik" {
    (
      name: "SEKOLAH TINGGI MANAJEMEN INFORMATIKA KOMPUTER TAZKIA (STMIK TAZKIA)",
      address: "Jl. Raya Dramaga Km 7, Bogor 16680",
      phone: "(+62-251) 8421 076",
      fax: "(+62-251) 8421 077",
      email: "info@stmik.tazkia.ac.id",
      web: "stmik.tazkia.ac.id",
    )
  } else {
    (
      name: "UNIVERSITAS TAZKIA",
      address: "Jl. Ir. H. Juanda No. 78, Sentul City, Bogor 16810",
      phone: "(+62-251) 8244 757",
      fax: "(+62-251) 8244 758",
      email: "info@tazkia.ac.id",
      web: "tazkia.ac.id",
    )
  }
}

// Warna tema kop surat (sesuai original SK STMIK).
#let _accent-navy   = rgb("#1E3C8E")   // navy logo + institusi name + alamat header
#let _accent-orange = rgb("#F47B20")   // orange logo + icons + vertical separator

// Header + watermark overlay: logo top-left + center watermark.
// Dipakai per-page via `background: letterhead-bg(...)`.
#let letterhead-bg(meta) = {
  // Watermark (faded logo) di tengah halaman
  place(
    center + horizon,
    image(watermark-path(meta), width: 110mm),
  )
  // Logo header top-left
  place(
    top + left,
    dx: 10mm, dy: 10mm,
    image(logo-path(meta), width: 20mm),
  )
}

// Footer block: nama institusi (navy) + vertical orange separator + alamat (icons).
#let letterhead-footer(meta) = {
  let key = _institution-key(meta)
  let addr = _address(key)
  set text(size: 7pt, fill: gray-strong)
  set par(justify: false, leading: 0.55em)
  line(length: 100%, stroke: 0.5pt + _accent-navy)
  v(1.5mm)
  let icon(sym) = text(fill: _accent-orange, weight: "bold")[#sym]
  grid(
    columns: (50mm, 1pt, 1fr),
    align: (left + top, center + horizon, left + top),
    column-gutter: 4mm,
    text(fill: _accent-navy, weight: "bold", size: 7.5pt)[#addr.name],
    line(angle: 90deg, length: 16mm, stroke: 0.6pt + _accent-orange),
    [
      #text(fill: _accent-navy, weight: "bold")[Alamat Kampus] \
      #icon("◆") #h(1mm) #addr.address \
      #icon("☎") #h(1mm) #addr.phone \
      #icon("✉") #h(1mm) #addr.email \
      #icon("⌂") #h(1mm) #addr.web
    ],
  )
}

#let letterhead-page(meta, body) = {
  let _ = _assert-field(meta, "title")
  let _ = _assert-field(meta, "version")
  let _ = _assert-field(meta, "date")
  let _ = _assert-field(meta, "institution")

  set document(title: meta.title, author: meta.institution)
  // Left margin = 35mm to clear logo (logo spans dx=10 + 20mm width = 30mm right edge,
  // plus 5mm safety gutter). Top margin = 35mm to clear logo height (dy=10 + ~24mm).
  set page(
    paper: "a4",
    margin: (top: 38mm, bottom: 38mm, left: 35mm, right: 18mm),
    numbering: "1",
    number-align: center,
    background: letterhead-bg(meta),
    footer: letterhead-footer(meta),
  )
  set text(font: sans, size: size-body, lang: "id")
  set par(justify: true, leading: 0.7em)

  show heading.where(level: 1): set text(size: size-h1, weight: "bold", fill: blue-dark)
  show heading.where(level: 2): set text(size: size-h2, weight: "bold", fill: blue-dark)
  show heading.where(level: 3): set text(size: size-h3, weight: "bold", fill: blue-dark)
  show link: set text(fill: blue-med)

  body
}

#let doc-page(meta, body) = {
  // Required fields
  let _ = _assert-field(meta, "title")
  let _ = _assert-field(meta, "version")
  let _ = _assert-field(meta, "date")
  let _ = _assert-field(meta, "institution")

  set document(
    title: meta.title,
    author: meta.institution,
  )

  set page(
    paper: "a4",
    margin: (top: 20mm, bottom: 20mm, left: 20mm, right: 20mm),
    numbering: "1",
    number-align: center,
  )

  set text(font: sans, size: size-body, lang: "id")
  set par(justify: true, leading: 0.7em)

  // Heading hierarchy
  show heading.where(level: 1): set text(size: size-h1, weight: "bold", fill: blue-dark)
  show heading.where(level: 2): set text(size: size-h2, weight: "bold", fill: blue-dark)
  show heading.where(level: 3): set text(size: size-h3, weight: "bold", fill: blue-dark)

  // Link styling
  show link: set text(fill: blue-med)

  body
}
