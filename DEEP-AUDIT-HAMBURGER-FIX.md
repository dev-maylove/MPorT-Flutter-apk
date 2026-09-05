# Deep Audit & Fix — MPorT Flutter

Tanggal: 2026-09-05

## Temuan utama

1. **Menu hamburger membuka rute generik `ModulePlaceholderScreen`.**
   Hampir seluruh item hamburger `/module/:module` memang diarahkan ke layar placeholder. Akibatnya setelah memilih menu, pengguna melihat layar gelap dengan data/text generik, bukan halaman modul yang terasa seperti bagian dari aplikasi.

2. **Detail item dibuka memakai `showModalBottomSheet` dengan tampilan raw JSON.**
   Ini memperkuat kesan "placeholder hitam + teks" dan bukan UI produk.

3. **Drawer belum mempunyai surface/elevation/interaction yang kuat.**
   Drawer hanya berupa surface gelap dan `ListTile`, sehingga pada tema gelap mudah terlihat seperti panel hitam polos.

4. **Navigasi item drawer dilakukan bersamaan dengan penutupan drawer.**
   Pada perangkat/animasi tertentu, perpindahan route dapat terasa kasar. Navigasi dipindahkan ke post-frame setelah drawer mulai ditutup.

## Perbaikan

- Drawer dibuat sebagai panel premium dengan radius kanan, elevation, shadow, header role/user, accent color per role, active-state, ripple, dan scrolling yang aman.
- Header memakai inisial pengguna bila tersedia; tidak lagi bergantung pada ikon router saja.
- Semua item tetap memakai route yang sama sehingga backend/API tidak rusak.
- `ModulePlaceholderScreen` diubah menjadi **generic real module UI**:
  - hero/header modul,
  - ikon modul,
  - role badge,
  - state loading,
  - state API error/404/403 yang informatif,
  - list data berbentuk cards,
  - object data berbentuk summary rows,
  - detail record dibuka sebagai dialog yang sesuai tema,
  - refresh/retry,
  - notifikasi tetap mendukung "tandai semua dibaca".
- Tidak lagi memakai bottom sheet raw JSON sebagai tampilan utama.
- Perhitungan lebar Drawer dibuat aman untuk layar kecil/besar.

## Catatan

Toolchain Flutter/Dart tidak tersedia di environment audit ini, jadi `flutter analyze`/`flutter build apk` tidak dapat dijalankan di sini. Saya melakukan sanity check struktural pada dua file yang diubah dan memastikan jumlah delimiter utama seimbang.

## File yang diubah

- `lib/core/widgets/role_menu_drawer.dart`
- `lib/features/common/module_placeholder_screen.dart`
