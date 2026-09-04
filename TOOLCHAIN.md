# Android toolchain — Flutter 3.47 verified

CI uses **Flutter stable 3.47.2**. Official verified matrix:

| Component | Version | Why |
|-----------|---------|-----|
| **AGP** | **9.1.0** | Newest verified with Flutter 3.47 |
| **Gradle** | **9.3.1** | Required minimum for AGP 9.1 |
| **Kotlin (KGP)** | **2.4.10** | Verified 2.4.0 + patch |
| **Java** | **17** | Flutter minimum |
| **builtInKotlin** | **false** | AGP embeds Kotlin 2.2.10 &lt; Flutter min 2.2.20 |

## Do not use AGP 9.4.0 yet on this CI

AGP 9.4 requires **Gradle ≥ 9.6.0**. If the wrapper stays at 9.3.1 you get:

```
Minimum supported Gradle version is 9.6.0. Current version is 9.3.1.
```

After upgrading **both** AGP → 9.4.0 **and** `distributionUrl` → `gradle-9.6.0-*.zip` in the same commit, newer AGP is fine.

## Files that must be committed

- `android/settings.gradle.kts`
- `android/gradle/wrapper/gradle-wrapper.properties`
- `android/gradle.properties`
- `android/app/build.gradle.kts`
