# CI Signing Fix — v7

The previous release workflow could continue when the four signing secrets were missing, producing an unsigned APK that was still uploaded as a release artifact.

This version is **fail-closed** for release builds.

Required GitHub Secrets:

- `MPORT_KEYSTORE_BASE64`
- `MPORT_KEYSTORE_PASSWORD`
- `MPORT_KEY_ALIAS`
- `MPORT_KEY_PASSWORD`

For release builds the workflow now:

1. Fails immediately if any required secret is missing or empty.
2. Decodes the PKCS12 keystore into a temporary file outside git.
3. Validates the keystore and alias with `keytool`.
4. Generates `android/key.properties` with the exact `storeFile=app/mport-release.p12` path.
5. Builds the release APK.
6. Runs `apksigner verify --verbose --print-certs` before any release upload.
7. Requires V1, V2 and V3 verification to report `true`.
8. Requires V1 `META-INF/MANIFEST.MF` metadata to be present.
9. Refuses to upload/publish the release if signature verification fails.
10. Deletes the temporary keystore and properties file in an `always()` cleanup step.

Debug builds remain available from `build-apk.yml` and do not require release signing secrets.

The project never commits the keystore or signing passwords.
