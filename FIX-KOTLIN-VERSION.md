# Kotlin + AGP notes

## Current
- AGP **9.4.0** / Gradle **9.6.0**
- Built-in Kotlin ON (`android.builtInKotlin=true`)
- `kotlin_version=2.4.10` in `gradle.properties` (Flutter DependencyVersionChecker)
- App module does **not** apply `org.jetbrains.kotlin.android`

## Why kotlin_version is set
Flutter 3.47 requires KGP ≥ 2.2.20. AGP still embeds 2.2.10 for Built-in
Kotlin; the project property is what the checker reads first.
