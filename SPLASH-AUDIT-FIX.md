# Splash Audit Fix

- Native Android launch background changed from white to MPorT dark background (#06080F).
- MPorT logo is now bundled as a native drawable so it can render before Flutter starts.
- Android 12+ uses the platform splash icon/background configuration.
- Flutter splash remains the post-native initialization screen and routes through AuthService/GoRouter.
- No external splash dependency was added.
