# Branding update — logo & app icon (cleaned)

Tanggal: 2026-09-05

## Masalah
Versi sebelumnya masih menyisakan fill putih/abu di dalam frame rounded-square
(terlihat di login screen dan icon launcher home).

## Perbaikan
- Re-extract dari sumber JPEG dengan mask ketat: hanya stroke biru/cyan + frame navy.
- Semua area terang / low-chroma dihapus → **transparan penuh**.
- Adaptive icon: foreground = logo bersih; background = `#06080F`.
- Legacy `ic_launcher.png` = logo di atas background gelap (tanpa putih).

## Asset
- `assets/images/mport_logo.png` (512×512 RGBA)
- mipmap FG/BG + ic_launcher (mdpi–xxxhdpi)
- `drawable-nodpi/mport_splash_logo.png`, `mport_splash_icon.png`
