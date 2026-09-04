# Fix: APK verify failed on V1 scheme

## What happened

```
✓ Built build/app/outputs/flutter-apk/app-release.apk (56.7MB)
Verified using v1 scheme (JAR signing): false
Verified using v2 scheme ...: true
Verified using v3 scheme ...: true
Number of signers: 1
##[error] Process completed with exit code 1
```

Build **succeeded**. CI failed because the workflow required:

```bash
grep -q 'Verified using v1 scheme: true'
```

With **minSdk ≥ 24**, AGP 9 often does **not** emit V1 (JAR) signatures.
V2 + V3 are enough for all modern Android devices.

## Fix

Workflows now require **only V2 + V3 + Number of signers ≥ 1**.

Files:

- `.github/workflows/release.yml`
- `.github/workflows/build-apk.yml`

`enableV1Signing = true` remains in `build.gradle.kts` (best-effort); CI no longer fails if V1 is absent.
