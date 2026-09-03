# MPorT Flutter — Hardened Module API

`lib/core/api/module_api.dart` is the Flutter facade for the modules found in
`MPorT.v2.0.1-hardened`.

## Usage

```dart
final api = context.read<AuthService>().modules;
final res = await api.customers(search: 'andi', status: 'active');
if (res.isOk) {
  final data = res.json?['data'];
}
```

## Modules

Dashboard, customers, packages, invoices, payments, tickets, users, roles,
materials, material requests/usages, network assets, network, coverage,
subscriptions, notifications, announcements, communications, campaigns,
WhatsApp numbers/activity, security events, audit logs, delivery logs,
reports, settings, technician jobs/map, and OLT overview/signals/detail.

## Backend requirement

The companion `api/` directory contains the Laravel API
controller and `routes/api.php` changes required for the new module endpoints.
Apply these two files to the MPorT Hardened backend before using the new
module API. Existing V1/legacy APIs remain compatible.
