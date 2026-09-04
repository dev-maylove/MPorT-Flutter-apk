# CI Signature Verify Fix (v3)

## Why the last build failed

APK **was built and signed successfully**:

```
✓ Built build/app/outputs/flutter-apk/app-release.apk (60.1MB)
Verified using v2 scheme (APK Signature Scheme v2): true
Verified using v3 scheme (APK Signature Scheme v3): true
Verified using v1 scheme (JAR signing): false
```

Two problems in the workflow step **Verify release APK signature BEFORE publishing**:

1. **Wrong grep patterns**  
   Workflow searched for:
   ```
   Verified using v1 scheme: true
   ```
   But apksigner actually prints:
   ```
   Verified using v1 scheme (JAR signing): false
   Verified using v2 scheme (APK Signature Scheme v2): true
   ```
   So the string never matches, even when a scheme is true.

2. **Requiring V1 is incorrect for modern Flutter apps**  
   Flutter default `minSdk` is typically 24+.  
   On API 24+, Android only needs APK Signature Scheme v2/v3.  
   `apksigner verify` intentionally reports `v1: false` when minSdk >= 24
   (see Google issue 134858541). Requiring V1 + META-INF/MANIFEST.MF will
   keep failing forever on current Flutter targets.

## Correct verification (drop-in)

Replace the verify step body with:

```yaml
      - name: Verify release APK signature BEFORE publishing
        run: |
          set -euo pipefail

          APK=$(find build/app/outputs/flutter-apk -type f -name "*.apk" | head -1)
          test -n "$APK"
          test -s "$APK"

          APKSIGNER=$(find "$ANDROID_HOME/build-tools" -type f -name apksigner | sort -V | tail -1)
          test -n "$APKSIGNER"
          test -x "$APKSIGNER"

          VERIFY_OUTPUT=$(mktemp)
          "$APKSIGNER" verify --verbose --print-certs "$APK" | tee "$VERIFY_OUTPUT"

          # Match real apksigner output. Require v2 + v3 only.
          # v1 is optional when minSdk >= 24.
          grep -Eq 'Verified using v2 scheme \(APK Signature Scheme v2\): true' "$VERIFY_OUTPUT"
          grep -Eq 'Verified using v3 scheme \(APK Signature Scheme v3\): true' "$VERIFY_OUTPUT"

          CERT_COUNT=$(
            "$APKSIGNER" verify --print-certs "$APK" 2>&1 \
              | grep -c "Signer #" || true
          )
          test "$CERT_COUNT" -ge 1

          echo "Release APK is signed and verified (v2 + v3)."
```

## build.gradle.kts (already fixed in this package)

- `storeFile` resolved via `rootProject.file(...)` (path relative to `android/`)
- `enableV1Signing = true`, `enableV2Signing = true`, `enableV3Signing = true`

Works with both:
- `storeFile=app/mport-release.p12`
- `storeFile=app/key/mport-app-keystore.p12`
