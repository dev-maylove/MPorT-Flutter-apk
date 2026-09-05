# Fix: Hamburger Covering Titles + Centered Titles + Admin Edit

Tanggal: 2026-09-05

## Masalah yang dilaporkan
1. Tombol hamburger menutupi judul halaman (mis. "Dashboard Operasional" tampil "D hboard...").
2. Judul halaman tidak rata tengah.
3. Admin seharusnya bisa mengedit semua halaman.

## Perbaikan

### 1. Judul rata tengah (global + per layar)
- `AppTheme.appBarTheme.centerTitle` diubah dari `false` → `true`.
- Semua AppBar / SliverAppBar di shell routes (admin, tech, user, module) diberi `centerTitle: true` secara eksplisit.
- ModulePlaceholderScreen: title disederhanakan menjadi `Text` (bukan Row kustom dengan titleSpacing:0) agar centering bekerja.

### 2. Hamburger tidak menutupi judul
- `HamburgerButton` diperkecil (40×40), padding IconButton dihilangkan, visualDensity compact.
- Posisi vertikal diselaraskan ke tengah toolbar AppBar (`kToolbarHeight`).
- Dengan judul yang di-center, area kiri kosong untuk hamburger; judul tidak lagi tertutup.

### 3. Admin bisa edit
- **AdminCustomersScreen**: CRUD penuh (FAB tambah, tap/edit, hapus), search, form bottom sheet.
- **ModulePlaceholderScreen** (semua modul via hamburger):
  - FAB "Tambah" untuk role admin.
  - Di dialog detail: tombol Edit & Hapus jika item punya `id`.
  - Memakai `ModuleApi.create/update/delete` generik ke `/api/v1/modules/{module}`.
- ModuleApi ditambah method generik `create`, `update`, `delete`.
- Admin Users sudah punya CRUD sebelumnya.

## File diubah
- `lib/core/theme/app_theme.dart`
- `lib/core/widgets/hamburger_button.dart`
- `lib/core/api/module_api.dart`
- `lib/features/common/module_placeholder_screen.dart`
- `lib/features/admin/customers/admin_customers_screen.dart`
- `lib/features/admin/home/admin_home_screen.dart`
- `lib/features/admin/users/admin_users_screen.dart`
- `lib/features/user/dashboard/user_home_screen.dart`
- `lib/features/user/invoices/invoices_screen.dart`
- `lib/features/user/packages/packages_screen.dart`
- `lib/features/user/profile/profile_screen.dart`
- `lib/features/user/tickets/tickets_screen.dart`
- `lib/features/tech/home/tech_home_screen.dart`
- `lib/features/tech/jobs/tech_jobs_screen.dart`
- `lib/features/tech/map/tech_map_screen.dart`
- `lib/features/tech/materials/tech_materials_screen.dart`

## Catatan
Toolchain Flutter tidak tersedia di environment ini. Jalankan `flutter analyze` dan `flutter build apk` di mesin build Anda.

---

# Responsiveness Audit & Fixes (mobile)

## Temuan
- StatChip (3 kolom Unpaid/Overdue/Paid) memakai Expanded — sudah baik, tapi font/padding tetap besar di layar <360px.
- Beberapa judul/teks panjang belum punya maxLines + ellipsis → risiko overflow visual.
- Dialog detail modul memakai maxHeight tetap 430px → di HP pendek (tinggi kecil / keyboard) bisa terlalu tinggi.
- Drawer sudah clamp lebar (280–390) — OK.
- Form bottom sheet sudah viewInsets — OK.
- List + FAB sudah padding bawah ~88 — OK.
- NavigationBar 4–5 item: Material 3 menangani dengan baik di lebar HP umum.

## Perbaikan responsivitas
1. **StatChip**: padding & font mengecil otomatis jika lebar < 360; value pakai FittedBox; label maxLines 1 + ellipsis.
2. **Module hero & dialog**: judul maxLines + ellipsis; dialog maxHeight = 55% tinggi layar (adaptif).
3. **Admin home greeting**: ellipsis untuk nama panjang.

## Rekomendasi uji
- Emulator/device: 360×640, 390×844, 412×915
- Orientasi portrait (utama); landscape opsional
- Keyboard terbuka di form tambah/edit
- Drawer + hamburger + AppBar back (modul)

---

# App icon size vs border

## Masalah
Foreground launcher hampir memenuhi canvas 108dp → terlihat kebesaran dan terpotong masker adaptive icon (lingkaran/squircle).

## Perbaikan
1. Semua `ic_launcher_foreground.png` (mdpi–xxxhdpi) di-pad: konten dipusatkan di **safe zone ~66%**.
2. Legacy `ic_launcher.png` diberi margin ~22%.
3. Splash `mport_splash_icon.png` & `mport_splash_logo.png` dipadatkan ke ~62%.
4. Adaptive icon XML: `android:inset="8%"` pada foreground.
5. `splash_icon.xml` & `launch_background.xml`: inset dp agar logo tidak menempel edge.

Setelah rebuild APK, icon di launcher & splash akan lebih proporsional di dalam border.

---

# Auth / Login / Session fix

## Bug
- Membuka app langsung ke dashboard admin (sesi lama di SharedPreferences).
- Halaman login "tidak berfungsi": di-redirect paksa karena token usang, atau sukses login tanpa navigasi eksplisit, atau token parsing gagal.

## Akar masalah
1. `_restore()` set `_loading=false` **sebelum** validasi token → redirect ke home role lama.
2. `isLoggedIn` hanya cek token (tanpa user) → sesi setengah jadi dianggap login.
3. Login sukses mengandalkan redirect saja; tidak ada `context.go`.
4. Parsing token/user dari respons Sanctum/Laravel kurang lengkap.

## Perbaikan
1. Validasi `/api/auth/me` **selama** loading; 401/403 → clear session → login.
2. `isLoggedIn` = token + user valid (id > 0).
3. Login & register: navigasi eksplisit ke home sesuai role setelah sukses.
4. Token extractor mendukung `token`, `access_token`, `plainTextToken`, nested Sanctum object.
5. Logout selalu clear local storage.

