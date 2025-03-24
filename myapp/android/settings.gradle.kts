pluginManagement {
    val flutterSdkPath by extra {
        file("local.properties").inputStream().use { 
            val properties = java.util.Properties()
            properties.load(it)
            properties.getProperty("flutter.sdk") ?: error("flutter.sdk not set in local.properties")
        }
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
    id("com.android.application") version "8.2.1" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

include(":app")
