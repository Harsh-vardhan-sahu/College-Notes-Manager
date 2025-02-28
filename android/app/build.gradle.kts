plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.notez"
    compileSdk = 34 // Updated to latest stable version
    ndkVersion = "27.0.12077973" // Ensure latest NDK is used (if needed)

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17 // Updated from Java 11 to 17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17" // Updated to match Java 17
    }

    defaultConfig {
        applicationId = "com.example.notez"
        minSdk = 23 // Firebase requires at least 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // Use a proper signing configuration
            signingConfig = signingConfigs.getByName("debug")

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM (always get the latest stable version)
    implementation(platform("com.google.firebase:firebase-bom:32.7.4")) // Latest stable version

    // Firebase dependencies
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth") // If using Firebase Auth
    implementation("com.google.firebase:firebase-firestore") // If using Firestore
    implementation("com.google.firebase:firebase-storage") // If using Firebase Storage

    // Other useful dependencies (optional)
    implementation("androidx.core:core-ktx:1.12.0") // Latest Core KTX
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.2") // Lifecycle components
}
