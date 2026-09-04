# Splash screen fix v2

## Issues addressed

1. **Logo 2.2 MB / 1533×1328** — too heavy for cold start (memory + decode lag)
2. **Android 12+ icon** — full large bitmap was cropped in the system splash circle
3. **Flutter splash** — static, abrupt; no transition from native theme
4. **Possible white flash** — themes already dark; reinforced status/nav bar colors

## Changes

| Area | Fix |
|------|-----|
| `drawable-nodpi/mport_splash_logo.png` | Resized to 480×480 (~282 KB) |
| `drawable-nodpi/mport_splash_icon.png` | New 288×288 padded icon for API 31+ |
| `drawable/splash_icon.xml` | Points at padded icon |
| `values` / `values-v31` styles | Dark bars, consistent Launch/Normal theme |
| `lib/features/splash/splash_screen.dart` | Fade + scale animation, SafeArea |
| `assets/images/mport_logo.png` | Capped ~512 px for Flutter UI |

Background remains `#06080F` (`@color/splash_background`) matching `AppColors.bg`.
