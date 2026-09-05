# Built-in Kotlin (AGP 9 / Flutter 3.47)

## Constraints
- Keep **Built-in Kotlin** (`android.builtInKotlin=true`)
- **Do not** apply `org.jetbrains.kotlin.android` on `:app`
- **Do not** skip dependency validation

## Problem
AGP’s embedded Kotlin is **2.2.10**. Flutter 3.47 requires **≥ 2.2.20** and
fails in `DependencyVersionChecker.checkKGPVersion` (Flutter #192167).

## Solution
Flutter’s checker resolves KGP version in this order:

1. Project property **`kotlin_version`**
2. Applied `KotlinAndroidPluginWrapper` version

So we set in `android/gradle.properties`:

```properties
kotlin_version=2.4.10
android.builtInKotlin=true
android.newDsl=false
```

Plus version override for the actual toolchain (without applying the plugin on `:app`):

- `settings.gradle.kts`: `id("org.jetbrains.kotlin.android") version "2.4.10" apply false`
- Root `build.gradle.kts` buildscript classpath: `kotlin-gradle-plugin:2.4.10`

## App module plugins
```kotlin
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}
```

## CI
No `--android-skip-build-dependency-validation`. Validation stays enabled.
