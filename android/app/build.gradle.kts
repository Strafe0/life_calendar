import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.vgol.life_calendar"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.vgol.life_calendar"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storePassword = keystoreProperties["storePassword"] as String?

            val storeFileKey = keystoreProperties["storeFile"] as String?
            storeFile = if (storeFileKey != null) file(storeFileKey) else null
        }
    }

    flavorDimensions += "app"
    productFlavors {
        create("lifeCalendar") {
            dimension = "app"

            signingConfig = signingConfigs.getByName("release")
        }

        create("lifeCalendarTest") {
            dimension = "app"
            applicationIdSuffix = ".test"
            versionNameSuffix = "-test"

            signingConfig = signingConfigs.getByName("debug")
        }

        create("lifeCalendarTest2") {
            dimension = "app"
            applicationIdSuffix = ".test2"
            versionNameSuffix = "-test2"
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Signing is declared per flavor: the production flavor uses the release
    // key, the test flavors stay on the debug key so test builds can be
    // installed over each other. Setting it on the release build type instead
    // would override the flavors.
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
