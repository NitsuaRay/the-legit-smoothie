import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")

    // The Flutter Gradle Plugin must be applied after
    // the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ================================================================
// RELEASE SIGNING PROPERTIES
// ================================================================

val keystoreProperties = Properties()

val keystorePropertiesFile =
    rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(
        FileInputStream(keystorePropertiesFile)
    )
}

android {
    namespace = "com.thelegitsmoothie.the_legit_smoothie"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // ============================================================
    // JAVA / KOTLIN
    // ============================================================

    compileOptions {
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // ============================================================
    // DEFAULT CONFIG
    // ============================================================

    defaultConfig {
        applicationId =
            "com.thelegitsmoothie.the_legit_smoothie"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ============================================================
    // RELEASE SIGNING
    // ============================================================

    signingConfigs {
        create("release") {
            keyAlias =
                keystoreProperties["keyAlias"] as String?

            keyPassword =
                keystoreProperties["keyPassword"] as String?

            storeFile =
                keystoreProperties["storeFile"]
                    ?.let { file(it) }

            storePassword =
                keystoreProperties["storePassword"] as String?
        }
    }

    // ============================================================
    // BUILD TYPES
    // ============================================================

    buildTypes {
        release {
            signingConfig =
                signingConfigs.getByName("release")
        }
    }
}

dependencies {
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.5"
    )
}

flutter {
    source = "../.."
}