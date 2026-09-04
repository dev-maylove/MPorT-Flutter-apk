# Plugin compatibility (v6 / v7)

## Toolchain

| Item | Version |
|------|---------|
| AGP | 9.4.0 |
| Gradle | 9.6.0 |
| Kotlin (KGP) | 2.4.10 |
| builtInKotlin | false |
| Java | 17 |

## Direct dependencies (pubspec)

| Package | Constraint | AGP 9 / notes |
|---------|------------|----------------|
| shared_preferences | ^2.5.5 | Android impl ≥2.4.24 = Built-in Kotlin |
| url_launcher | ^6.3.2 | Android impl ≥6.3.31 = Built-in Kotlin |
| http | ^1.6.0 | Pure Dart |
| provider | ^6.1.5 | Pure Dart |
| go_router | ^14.8.1 | Pure Dart (major 14 kept for API stability) |
| flutter_map | ^7.0.2 | Mostly Dart |
| cached_network_image | ^3.4.1 | Pulls path_provider / sqflite |
| google_fonts / flutter_svg / intl / latlong2 | current | OK |

## After clone / CI

```bash
flutter pub get
# or
flutter pub upgrade
```

Lockfile is refreshed on the next `flutter pub get` in CI.
