# Plugin compatibility

## Toolchain

| Item | Version |
|------|---------|
| AGP | 9.1.0 |
| Gradle | 9.3.1 |
| Kotlin | Built-in (AGP) |
| builtInKotlin | true |
| Java | 17 |

## Direct dependencies (pubspec)

| Package | Constraint | Notes |
|---------|------------|-------|
| shared_preferences | ^2.5.5 | Prefer Android impl with Built-in Kotlin |
| url_launcher | ^6.3.2 | Prefer Android impl with Built-in Kotlin |
| http | ^1.6.0 | Pure Dart |
| provider | ^6.1.5 | Pure Dart |
| go_router | ^14.8.1 | Pure Dart |
| flutter_map | ^7.0.2 | Mostly Dart |
| cached_network_image | ^3.4.1 | Pulls path_provider / sqflite |
| google_fonts / flutter_svg / intl / latlong2 | current | OK |

## After clone / CI

```bash
flutter pub get
```

If a plugin still applies KGP, upgrade that plugin or report upstream.
