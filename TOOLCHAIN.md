# Android toolchain (latest stable — Sep 2026)

| Component | Version | Notes |
|-----------|---------|--------|
| **AGP** | **9.4.0** | Latest stable; max API 37 |
| **Gradle** | **9.6.0** | Minimum required by AGP 9.4 |
| **Kotlin (KGP)** | **2.4.10** | Latest stable (Flutter verified 2.4.0) |
| **Java** | **17** | Flutter 3.47 minimum |
| **compile/targetSdk** | Flutter defaults (API 36) | `flutter.compileSdkVersion` / `targetSdkVersion` |
| **minSdk** | Flutter default (API 24) | `flutter.minSdkVersion` |
| **builtInKotlin** | **false** | AGP still embeds Kotlin 2.2.10 &lt; Flutter min 2.2.20 |

## Why not pure Built-in Kotlin yet?

Flutter rejects AGP’s embedded Kotlin 2.2.10. Explicit KGP 2.4.10 satisfies
the checker. Re-enable `android.builtInKotlin=true` and drop KGP when AGP
ships embedded Kotlin ≥ 2.2.20.

## Flutter 3.47 official verified matrix (for reference)

- AGP 9.1.0 · KGP 2.4.0 · Gradle 9.3.1 · Java 17

This project tracks **newer stable** AGP/Gradle/Kotlin while keeping the
`builtInKotlin=false` workaround required by current Flutter.
