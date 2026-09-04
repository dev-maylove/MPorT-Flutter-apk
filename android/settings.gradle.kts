pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Flutter 3.47 verified: AGP 9.1.0 (compatible with Gradle 9.3.1)
    id("com.android.application") version "9.1.0" apply false
    // Flutter verified KGP 2.4.0 — use 2.4.10 patch
    id("org.jetbrains.kotlin.android") version "2.4.10" apply false
}

include(":app")
