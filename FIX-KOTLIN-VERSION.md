# Fix: Kotlin 2.2.10 < Flutter minimum 2.2.20

## Error

```
Failed to apply plugin 'dev.flutter.flutter-gradle-plugin'.
Error: Your project's Kotlin version (2.2.10) is lower than Flutter's
minimum supported version of 2.2.20.
```

## Cause

With `android.builtInKotlin=true`, AGP 9.1 uses its **bundled** Kotlin
**2.2.10**. Flutter 3.47 requires **≥ 2.2.20**.

## Fix (compatible with current Flutter)

1. `android/gradle.properties` → `android.builtInKotlin=false`
2. `settings.gradle.kts` → restore
   `id("org.jetbrains.kotlin.android") version "2.2.20" apply false`
3. `app/build.gradle.kts` → apply `org.jetbrains.kotlin.android` again

You may still see a **warning** about KGP on the app module; that is expected
until AGP ships Kotlin ≥ 2.2.20 for built-in mode. The build will succeed.

## Later migration

When AGP embeds Kotlin ≥ 2.2.20, switch back to:

```properties
android.builtInKotlin=true
```

and remove the `org.jetbrains.kotlin.android` plugin again.
