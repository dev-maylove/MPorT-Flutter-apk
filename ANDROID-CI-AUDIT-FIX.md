# Android / CI Deep Audit Fix

Fixed in this rebuild:

- GitHub Actions now checks `android/settings.gradle.kts` (the project uses Kotlin DSL) instead of the nonexistent `settings.gradle`.
- CI no longer deletes and recreates the Android project when the embedding marker is absent; this protects signing and custom Android configuration.
- Flutter is pinned to 3.47.2 for reproducible builds.
- Flutter Android Embedding V2 marker is present in `android/app/src/main/AndroidManifest.xml`.
- Release signing path is corrected to `storeFile=app/mport-release.p12`, matching the file written by the workflows.
- Gradle wrapper remains pinned to Gradle 9.3.1.
