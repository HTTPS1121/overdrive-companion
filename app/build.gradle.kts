import groovy.json.JsonSlurper
import java.util.Properties

plugins { id("com.android.application") }

val webSource = JsonSlurper().parseText(
    file("src/main/assets/WEB_SOURCE.json").readText(),
) as Map<String, Any>
val shellPatch = rootProject.file("app/shell_patch.txt").readText().trim().toIntOrNull() ?: 0
val upstreamVersionCode = (webSource["versionCode"] as Number).toInt()
val upstreamVersionName = webSource["versionName"].toString()
val derivedVersionCode = upstreamVersionCode * 100 + shellPatch
val derivedVersionName =
    if (shellPatch == 0) upstreamVersionName else "$upstreamVersionName.$shellPatch"

fun releaseSigningProps(): Properties? {
    val fromEnv = listOf(
        "ANDROID_KEYSTORE_PASSWORD",
        "ANDROID_KEY_ALIAS",
        "ANDROID_KEY_PASSWORD",
    ).all { System.getenv(it) != null }
    if (fromEnv) return null
    val local = rootProject.file("signing/local-signing.properties")
    if (!local.exists()) return null
    return Properties().apply { local.inputStream().use { load(it) } }
}

android {
    namespace = "com.https1121.overdrive.companion"
    compileSdk = 36
    defaultConfig {
        applicationId = "com.https1121.overdrive.companion"
        minSdk = 29
        targetSdk = 35
        versionCode = derivedVersionCode
        versionName = derivedVersionName
    }
    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("ANDROID_KEYSTORE_PATH")
                ?: rootProject.file("signing/overdrive-release.keystore")
                    .takeIf { it.exists() }
                    ?.absolutePath
            if (keystorePath != null) {
                storeFile = file(keystorePath)
                val props = releaseSigningProps()
                storePassword =
                    System.getenv("ANDROID_KEYSTORE_PASSWORD") ?: props?.getProperty("storePassword")
                keyAlias = System.getenv("ANDROID_KEY_ALIAS") ?: props?.getProperty("alias")
                keyPassword =
                    System.getenv("ANDROID_KEY_PASSWORD") ?: props?.getProperty("keyPassword")
            }
        }
    }
    buildTypes {
        release {
            isMinifyEnabled = false
            val releaseSigning = signingConfigs.getByName("release")
            signingConfig =
                if (releaseSigning.storeFile?.exists() == true &&
                    releaseSigning.storePassword != null &&
                    releaseSigning.keyAlias != null &&
                    releaseSigning.keyPassword != null
                ) {
                    releaseSigning
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    androidResources { noCompress += listOf("glb", "wasm", "tflite", "ttf") }
}

dependencies {
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.activity:activity:1.9.3")
    implementation("androidx.core:core-splashscreen:1.0.1")
    implementation("androidx.swiperefreshlayout:swiperefreshlayout:1.1.0")
    implementation("androidx.webkit:webkit:1.12.1")
    implementation("androidx.recyclerview:recyclerview:1.3.2")
}