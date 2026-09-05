# Deep bugfix — MPorT GRADLE-PERF (2026-09-05)

## Scope
Deep structural review of Flutter app + Android Gradle toolchain after prior audits (hamburger, splash, modules, signing, Kotlin built-in).

## Bugs fixed

### 1. Signing config created empty (Gradle)
**File:** `android/app/build.gradle.kts`  
Previously `signingConfigs { create("release") { if (file.exists()) ... } }` still registered an empty `release` config when `key.properties` was absent.  
**Fix:** only `create("release")` when the properties file exists. Also treat optional `storeType` safely.

### 2. Fragile `local.properties` load
**File:** `android/settings.gradle.kts`  
`file("local.properties").inputStream()` threw a low-level I/O error on fresh clones.  
**Fix:** explicit `exists()` check with actionable message (`flutter pub get` / copy example).

### 3. ModuleApi `securityEvents` wrong query key
**File:** `lib/core/api/module_api.dart`  
Severity was sent as `status` (and briefly as both `status`+`type`). Backend Hardened API expects `severity`.  
**Fix:** dedicated map with `severity` key only.

### 4. Role guard logic for `/app`
**File:** `lib/core/router/app_router.dart`  
Nested `if (technician)` inside a condition that already excluded user/admin was redundant and left unknown roles without a redirect.  
**Fix:** single clear rule — non-user, non-admin roles (including technician) are bounced from `/app*`.

### 5. `fetchMe` force-unwrap on nullable token
**File:** `lib/core/auth/auth_service.dart`  
`_persist(_token!, user)` could throw if token was cleared between the 401 check and persist.  
**Fix:** local non-null check before persist.

### 6. Invoice number fallback used raw JSON id
**File:** `lib/core/models/invoice_model.dart`  
Fallback `'#${json['id']}'` could produce odd strings for non-int ids.  
**Fix:** use `_asInt(json['id'])`.

### 7. Missing `.gitignore` (security)
**New file:** `.gitignore`  
Keystore (`android/app/key/*.p12`), `key.properties`, `local.properties`, and build outputs were not ignored. The PKCS12 in the archive must not be committed to a real remote.  
**Action for maintainers:** rotate the keystore if this tree was ever pushed publicly; keep CI secrets only.

## Verified OK (no change)
- Built-in Kotlin + `kotlin_version=2.4.10` + AGP 9.4.0 / Gradle 9.6.0 pin
- `kotlin { compilerOptions { jvmTarget JVM_17 } }` (Flutter 3.47 migration style)
- Configuration cache with `problems=warn`
- Hamburger / drawer capture-router pattern
- ApiResponse message handling for non-string / Laravel errors
- Safe `_asInt` / `_asDouble` in models

## Recommended local verify
```bash
flutter pub get
flutter analyze
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.102:8000
```
