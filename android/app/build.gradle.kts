import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")

fun loadKeystoreProperties(): Properties {
    val props = Properties()
    keystorePropertiesFile.inputStream().use { props.load(it) }
    listOf("storePassword", "keyAlias", "storeFile").forEach { key ->
        if (props.getProperty(key)?.trim().isNullOrEmpty()) {
            throw GradleException("android/key.properties is missing required property: $key")
        }
    }
    return props
}

android {
    namespace = "com.https1121.overdrive.companion"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        if (keystorePropertiesFile.isFile) {
            val props = loadKeystoreProperties()
            create("release") {
                keyAlias = props.getProperty("keyAlias")
                storePassword = props.getProperty("storePassword")
                val storePass = props.getProperty("storePassword")
                val keyPass = props.getProperty("keyPassword")?.trim().orEmpty()
                keyPassword = if (keyPass.isEmpty()) storePass else keyPass
                storeFile = rootProject.file(props.getProperty("storeFile"))
            }
        }
    }

    defaultConfig {
        applicationId = "com.https1121.overdrive.companion"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            val releaseConfig = signingConfigs.findByName("release")
            if (releaseConfig != null) {
                signingConfig = releaseConfig
            }
        }
    }
}

gradle.taskGraph.whenReady {
    val assemblesRelease = allTasks.any { task ->
        val n = task.name
        n.contains("assembleRelease", ignoreCase = true) ||
            n.contains("bundleRelease", ignoreCase = true) ||
            n.contains("assembleAndroid", ignoreCase = true) && n.contains("Release")
    }
    if (!assemblesRelease) return@whenReady

    if (!keystorePropertiesFile.isFile) {
        throw GradleException(
            """
            Release APK requires android/key.properties (no debug fallback).
            Copy android/key.properties.example and install the release keystore under android/signing/.
            """.trimIndent(),
        )
    }
    val props = loadKeystoreProperties()
    val store = rootProject.file(props.getProperty("storeFile"))
    if (!store.isFile) {
        throw GradleException(
            "Release keystore missing at ${store.path}. Restore artifacts/signing/release/overdrive-release.keystore.",
        )
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.2.1")
    androidTestImplementation("androidx.test:runner:1.6.2")
}
