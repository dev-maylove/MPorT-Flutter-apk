# Gradle build performance

## Enabled

| Setting | Effect |
|---------|--------|
| `org.gradle.parallel=true` | Parallel project execution |
| `org.gradle.caching=true` | Build cache (local) |
| `org.gradle.configuration-cache=true` | Reuse configuration phase |
| `org.gradle.vfs.watch=true` | Faster file change detection |
| `org.gradle.daemon=true` | Persistent JVM |
| G1 GC + 4G heap | Stable daemon memory |
| `android.enableJetifier=false` | Skip support-lib rewrite (big win) |
| `android.nonTransitiveRClass=true` | Smaller R classes |
| `kotlin.incremental*` | Incremental Kotlin compile |
| Release `minifyEnabled` + `shrinkResources` | R8 shrink (smaller APK) |

## Not enabled

- `org.gradle.configureondemand` — conflicts with Flutter `evaluationDependsOn(":app")`.

## Local tips

```bash
# Warm daemon + config cache
cd android && ./gradlew help

# Flutter release (uses optimized Gradle)
flutter build apk --release --dart-define=API_BASE_URL=...
```

## CI

GitHub Actions already uses a clean workspace; local build cache does not
carry over. Parallel + R8 + no Jetifier still reduce wall time on runners.
