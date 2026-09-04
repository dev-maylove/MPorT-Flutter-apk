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
    // Latest stable AGP (Sep 2026) — requires Gradle >= 9.6.0
    id("com.android.application") version "9.4.0" apply false
    // Latest stable Kotlin — Flutter min is 2.2.20; verified matrix uses 2.4.0
    id("org.jetbrains.kotlin.android") version "2.4.10" apply false
}

include(":app")
