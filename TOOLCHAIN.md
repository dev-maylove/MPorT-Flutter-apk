# Android toolchain — Flutter 3.47

| Component | Version | Notes |
|-----------|---------|-------|
| **AGP** | **9.4.0** | Latest stable (Sept 2026) |
| **Gradle** | **9.6.0** | Minimum required by AGP 9.4 |
| **Kotlin** | Built-in + pin **2.4.10** | `kotlin_version=2.4.10`; app does not apply KGP |
| **builtInKotlin** | **true** | |
| **Java** | **17** | |
| **Dependency validation** | enabled | No skip flag |

## Local build
```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=http://192.168.1.102:8000
```

## Files
- `android/settings.gradle.kts`
- `android/gradle/wrapper/gradle-wrapper.properties`
- `android/gradle.properties`
- `android/app/build.gradle.kts`
- `android/build.gradle.kts`
