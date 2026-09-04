# Migrate to Built-in Kotlin (AGP 9 / Flutter 3.47)

Removes the warning:

```
WARNING: Your Android app project: app ... applies the Kotlin Gradle Plugin,
which will cause build failures in future versions of Flutter.
```

## Changes

1. **android/app/build.gradle.kts**
   - Removed `id("org.jetbrains.kotlin.android")`
   - Moved `kotlin { compilerOptions { jvmTarget = JVM_17 } }` to **top-level**
     (outside `android { }`)

2. **android/settings.gradle.kts**
   - Removed `id("org.jetbrains.kotlin.android") version "..." apply false`

3. **android/gradle.properties**
   - Added `android.builtInKotlin=true`

## Reference

https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers

## Note

If a **plugin** still applies KGP, Flutter may still print a plugin-related
warning. That must be fixed upstream by the plugin author. This app module
no longer applies KGP.
