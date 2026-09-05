# Migrate to Built-in Kotlin (AGP 9 / Flutter 3.47)

Removes the warning:

```
WARNING: Your Android app project: app ... applies the Kotlin Gradle Plugin,
which will cause build failures in future versions of Flutter.
```

## Changes applied

1. **android/app/build.gradle.kts**
   - Removed `id("org.jetbrains.kotlin.android")`
   - Kept top-level `kotlin { compilerOptions { jvmTarget = JVM_17 } }`

2. **android/settings.gradle.kts**
   - Removed `id("org.jetbrains.kotlin.android") version "..." apply false`

3. **android/gradle.properties**
   - `android.builtInKotlin=true`
   - `android.newDsl=false` (Flutter plugin ecosystem compatibility)

## Reference

https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers

## Known Flutter issue (as of 2026-09)

Flutter issue [#192167](https://github.com/flutter/flutter/issues/192167):
with some AGP 9.x versions, Built-in Kotlin is reported as **2.2.10** while
Flutter 3.47 requires **≥ 2.2.20**, and the version cannot be raised
independently of AGP.

If `flutter build apk` fails with:

```
Your project's Kotlin version (2.2.10) is lower than Flutter's minimum
supported version of 2.2.20
```

then temporarily set:

```properties
android.builtInKotlin=false
```

and restore `org.jetbrains.kotlin.android` **2.2.20+** (e.g. 2.4.10) until
Flutter or AGP ships a compatible combination. That path may reintroduce the
KGP migration warning.

## Plugins

If a **plugin** still applies KGP, Flutter may still print a plugin-related
warning. That must be fixed upstream by the plugin author. This app module
no longer applies KGP.
