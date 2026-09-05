# Kotlin version notes (Built-in Kotlin)

## Current state

The app module uses **AGP Built-in Kotlin** (`android.builtInKotlin=true`).
`org.jetbrains.kotlin.android` is **not** applied on `:app`.

## If build fails with Kotlin 2.2.10 < 2.2.20

Flutter’s Gradle plugin may still validate the AGP-embedded Kotlin version
(2.2.10) against Flutter’s minimum (2.2.20). See Flutter
[#192167](https://github.com/flutter/flutter/issues/192167).

Temporary rollback:

1. `android/gradle.properties` → `android.builtInKotlin=false`
2. `settings.gradle.kts` → restore
   `id("org.jetbrains.kotlin.android") version "2.4.10" apply false`
3. `app/build.gradle.kts` → apply `org.jetbrains.kotlin.android` again

You may then see the KGP migration **warning** again; the build should succeed
with an explicit KGP ≥ 2.2.20.
