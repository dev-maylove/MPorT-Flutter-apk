# Deep Audit & Fix V2 — MPorT Hamburger / Module UI

Tanggal: 2026-09-05

## Temuan lanjutan (setelah V1)

1. **Tombol hamburger tidak SafeArea-aware**  
   Di ketiga shell (`UserShell`, `AdminShell`, `TechShell`) tombol menu diposisikan `Positioned(top: 8, left: 10)`. Pada perangkat dengan notch / status bar, tombol tertutup atau menabrak AppBar layar anak.

2. **Navigasi drawer bergantung pada context drawer**  
   Setelah `Navigator.pop()`, callback `context.go(...)` memakai context drawer yang bisa sudah unmounted. Risiko silent no-op pada beberapa device/animasi.

3. **Detail item modul masih raw JSON**  
   Dialog detail memakai `JsonEncoder` monospace — masih terasa seperti placeholder developer, bukan UI produk.

4. **Nested Map/List di ringkasan tidak interaktif**  
   Tile hanya menampilkan jumlah item tanpa cara membuka isinya.

## Perbaikan V2

- Widget baru `lib/core/widgets/hamburger_button.dart`: posisi di bawah status bar (`MediaQuery.paddingOf`), shadow, dan `Scaffold.maybeOf` aman.
- Ketiga shell memakai `HamburgerButton` (kode Stack rapi, tidak inline panjang).
- `RoleMenuDrawer`: capture `GoRouter.of(context)` sebelum `pop`, navigasi lewat router yang di-capture (tidak bergantung pada context drawer).
- Logout juga memakai router yang di-capture.
- `ModulePlaceholderScreen`:
  - Detail dialog → baris key/value bertema (bukan JSON mentah).
  - Nested Map/List → tappable; Map buka detail, List buka dialog daftar lalu drill-down.
- Import `dart:convert` dihapus karena tidak lagi dipakai.

## File diubah / ditambah

- `lib/core/widgets/hamburger_button.dart` **(baru)**
- `lib/core/widgets/role_menu_drawer.dart`
- `lib/features/user/dashboard/user_shell.dart`
- `lib/features/admin/home/admin_shell.dart`
- `lib/features/tech/home/tech_shell.dart`
- `lib/features/common/module_placeholder_screen.dart`

## Catatan

Toolchain Flutter tidak tersedia di environment audit ini; verifikasi struktural (delimiter seimbang, import konsisten) sudah dilakukan. Jalankan `flutter analyze` & `flutter build apk` di mesin build Anda.
