# CI Signing Fix

The previous GitHub Actions failure happened before the Android build because all four release-signing secrets were empty in the runner environment:

- `MPORT_KEYSTORE_BASE64`
- `MPORT_KEYSTORE_PASSWORD`
- `MPORT_KEY_ALIAS`
- `MPORT_KEY_PASSWORD`

The workflow now treats signing as optional for diagnostic/CI builds. If all four secrets are present, the APK/AAB is signed and signature verification runs. If they are absent, a release artifact is built **unsigned** and signature verification is skipped with a warning.

For a production-signed release, configure all four repository/environment secrets. The keystore is never committed to the repository.
