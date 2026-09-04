# MPorT Mobile Module API (companion)

Apply these files into the **Laravel backend** (MPorT Hardened) so Flutter
can call `/api/v1/modules/{module}`.

## Files to copy

| Project file | Backend destination |
|---|---|
| `api/routes/api.php` (module section) | `routes/api.php` inside `v1` + `auth:sanctum` group |
| `api/app/Http/Controllers/Api/V1/MobileModuleController.php` | same path in Laravel app |

## Required routes (after `php artisan route:list`)

```
GET  /api/v1/modules/{module}
GET  /api/v1/modules/{module}/{id}
POST /api/v1/modules/notifications/read-all
POST /api/v1/modules/notifications/{id}/read
```

If Flutter shows:

```
The route api/v1/modules/reports could not be found.
```

the backend does **not** have these routes loaded. Copy the controller + routes,
then:

```bash
php artisan route:clear
php artisan config:clear
php artisan route:list | grep modules
```

## Modules used by the Flutter app

- admin: packages, payments, support, network, network-assets, olt, technicians,
  coverage, communications, ops-comms, campaigns, reports, materials, roles,
  security, pages, settings, whatsapp, notifications, ...
- technician: tech-jobs, tech-map, material-requests, notifications,
  announcements, help, reports (scoped)
- user: service, documents, help, payments, notifications, packages

## Auth

All module routes require `Authorization: Bearer {sanctum_token}`.
