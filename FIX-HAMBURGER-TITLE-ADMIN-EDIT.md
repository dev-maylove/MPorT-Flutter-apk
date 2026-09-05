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
