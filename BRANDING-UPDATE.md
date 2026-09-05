# Branding update — logo & app icon

Tanggal: 2026-09-05

## Sumber
Gambar monogram **M** biru neon + motif circuit, frame rounded-square, background transparan
(`534350.jpg` → diproses ke PNG RGBA).

## Yang diganti
- `assets/images/mport_logo.png` (512×512, RGBA, luar transparan) — dipakai login & splash Flutter
- Adaptive icon FG/BG semua densitas (`mipmap-mdpi` … `mipmap-xxxhdpi`)
- Legacy `ic_launcher.png` semua densitas
- Native splash: `drawable-nodpi/mport_splash_logo.png`, `mport_splash_icon.png`
- Background adaptive / launcher: `#06080F` (selaras AppColors.bg)

## Catatan teknis
Sumber JPEG menampilkan checkerboard (simulasi transparan). Skrip mengekstrak ikon,
membuang area terang/abu di luar frame, dan menghasilkan PNG transparan sejati.
