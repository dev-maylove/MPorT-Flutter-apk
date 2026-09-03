# MPorT v7 — Release Signing Gate

This rebuild addresses the APK installation error caused by an unsigned release APK.

## Release policy

A release APK/AAB is **never allowed to be published unsigned**.

Both Android release workflows require all four GitHub repository/environment secrets:

- `MPORT_KEYSTORE_BASE64`
- `MPORT_KEYSTORE_PASSWORD`
- `MPORT_KEY_ALIAS`
- `MPORT_KEY_PASSWORD`

If any secret is missing or empty, the workflow stops before the release build.

## Verification pipeline

```text
GitHub Secrets
     ↓
Decode PKCS12
     ↓
keytool validates keystore + alias
     ↓
android/key.properties
     ↓
Flutter release build
     ↓
apksigner verify --verbose --print-certs
     ↓
V1 = true + V2 = true + V3 = true
     ↓
Publish artifact/release
```

If any signature check fails, the artifact is not uploaded/published.

## Important

The keystore and passwords are temporary CI files only and are deleted in an `always()` cleanup step. They are not committed to the repository.

The Android app's package ID remains `id.mandalanet.mport`.
