# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Keep Gson / reflection used by some plugins if present
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# OkHttp / HTTP (used transitively)
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# Play Core (optional split installs)
-dontwarn com.google.android.play.core.**
