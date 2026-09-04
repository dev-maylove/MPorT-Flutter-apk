# Fix: Gagal memuat modul (route not found)

## Symptoms
- Screen title Notifications / Settings / Reports
- Message: `The route api/v1/modules/reports could not be found.`
- Same for `settings`, and stale errors when switching menu items

## Causes found

1. **State reuse bug (Flutter)**  
   `ModulePlaceholderScreen` is a `StatefulWidget`. Navigating from
   `/tech/module/reports` → `/tech/module/settings` reused the same State,
   so the UI kept showing the previous module's error.

2. **Technician menu pointed at admin-only modules**  
   Tech drawer linked to `reports` and `settings` (ADMIN_ONLY). Even with
   routes present, that yields 403. Menu now uses tech-safe modules.

3. **Backend routes may not be deployed**  
   The `api/` folder is a companion. Production must register:
   `GET /api/v1/modules/{module}`.

## Fixes in this package

- `didUpdateWidget` + `ValueKey('role-module')` on module screens
- Friendlier 404/403 messages
- Tech menu: tech-jobs, notifications, announcements, help (no admin settings)
- API: reports allowed for technician (scoped); routes ordered correctly
- `api/README.md` deploy checklist
