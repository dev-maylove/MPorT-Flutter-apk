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
    // AGP 9.4.0 (latest stable) requires Gradle ≥ 9.6.0
    id("com.android.application") version "9.4.0" apply false
    // Version pin only (apply false). App does NOT apply this plugin.
    // Built-in Kotlin stays enabled; pin ≥2.2.20 for Flutter checker + BOM.
    id("org.jetbrains.kotlin.android") version "2.4.10" apply false
}

include(":app")
