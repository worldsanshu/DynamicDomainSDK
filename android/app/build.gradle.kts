import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.Properties
import java.util.TimeZone

// Read local properties
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")

if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val flutterRoot: String =
        localProperties.getProperty("flutter.sdk")
                ?: throw GradleException(
                        "Flutter SDK not found. Define location with flutter.sdk in the local.properties file."
                )

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.huawei.agconnect")
    // id("com.google.gms.google-services")
}

android {
    namespace = "com.cnl.chat.v2"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }

    defaultConfig {
        // TODO: Specify your own unique Application ID
        // (https://developer.android.com/studio/build/application-id.html).
        // applicationId = "com.tingjunge.cnl"
        applicationId = "com.cnl.chat.v2"
        // You can update the following values to match your application needs.
        // For more information, see:
        // https://docs.flutter.dev/deployment/android#reviewing-the-gradle-build-configuration.
        minSdk = 24
        targetSdk = 34
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName

        multiDexEnabled = true

        ndk {
            // abiFilters += listOf("arm64-v8a") // "armeabi-v7a", "armeabi", "x86", "x86_64",
            // "mips", "mips64"
        }

        lint {
            disable += listOf("InvalidPackage", "Instantiatable")
            checkReleaseBuilds = false
            abortOnError = false
        }

        manifestPlaceholders +=
                mapOf(
                        "GETUI_APPID" to "",
                        // 下面是多厂商配置，如需要开通使用请联系技术支持

                        // 小米
                        "XIAOMI_APP_ID" to "",
                        "XIAOMI_APP_KEY" to "",

                        // 魅族
                        "MEIZU_APP_ID" to "",
                        "MEIZU_APP_KEY" to "",

                        // 华为
                        "HUAWEI_APP_ID" to "",

                        // OPPO
                        "OPPO_APP_KEY" to "",
                        "OPPO_APP_SECRET" to "",

                        // VIVO
                        "VIVO_APP_ID" to "",
                        "VIVO_APP_KEY" to "",

                        // 荣耀
                        "HONOR_APP_ID" to ""
                )
    }

    signingConfigs {
        create("release") {
            keyAlias = "cnl"
            keyPassword = "12022025"
            storeFile = file("./android.keystore")
            storePassword = "12022025"
        }
    }

    buildTypes {
        debug { signingConfig = signingConfigs.getByName("release") }
        release {
            // Temporarily disable shrinking/obfuscation to avoid R8 OOM
            isMinifyEnabled = false
            isShrinkResources = false
            // useProguard false
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                    getDefaultProguardFile("proguard-android-optimize.txt"),
                    "proguard-rules.pro"
            )
        }
    }

    // applicationVariants.all {
    //     outputs.all {
    //         val output = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
    //         val abi =
    //                 output.filters
    //                         .find { it.filterType == com.android.build.OutputFile.ABI }
    //                         ?.identifier
    //         val abiSuffix = if (abi != null) "_$abi" else ""
    //         output.outputFileName =
    //                 "CNL_${versionName}_${versionCode}_${buildType.name}_${buildTime()}.apk"
    //     }
    // }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
            excludes += "go/Seq.class"
            excludes += "go/Seq\$GoObject.class"
            excludes += "go/Seq\$GoRef.class"
            excludes += "go/Seq\$GoRefQueue.class"
            excludes += "go/Seq\$GoRefQueue$1.class"
            excludes += "go/Seq\$Proxy.class"
            excludes += "go/Seq\$Ref.class"
            excludes += "go/Seq\$RefMap.class"
            excludes += "go/Seq\$RefTracker.class"
            excludes += "go/Universe.class"
            excludes += "go/Universe\$proxyerror.class"
            excludes += "go/error.class"
        }
        jniLibs {
            // Fix for ffmpeg-kit-react-native and TRTC conflicts
            pickFirsts +=
                    listOf(
                            "lib/arm64-v8a/libgojni.so",
                            "lib/armeabi-v7a/libgojni.so",
                            "lib/x86/libgojni.so",
                            "lib/x86_64/libgojni.so",
                            "lib/armeabi-v7a/libc++_shared.so",
                            "lib/x86/libc++_shared.so",
                            "lib/x86_64/libc++_shared.so",
                            "lib/arm64-v8a/libc++_shared.so",
                            "lib/arm64-v8a/libavcodec.so",
                            "lib/arm64-v8a/libavformat.so",
                            "lib/arm64-v8a/libavutil.so",
                            "lib/arm64-v8a/libswscale.so",
                            "lib/arm64-v8a/libavdevice.so",
                            "lib/arm64-v8a/libavfilter.so",
                            "lib/arm64-v8a/libffmpegkit.so",
                            "lib/arm64-v8a/libffmpegkit_abidetect.so",
                            "lib/arm64-v8a/libswresample.so",
                            "lib/arm64-v8a/libswscale.so",
                            "lib/x86/libavcodec.so",
                            "lib/x86/libavformat.so",
                            "lib/x86/libavutil.so",
                            "lib/x86/libswscale.so",
                            "lib/x86/libavdevice.so",
                            "lib/x86/libavfilter.so",
                            "lib/x86/libffmpegkit.so",
                            "lib/x86/libffmpegkit_abidetect.so",
                            "lib/x86/libswresample.so",
                            "lib/x86/libswscale.so",
                            "lib/x86_64/libavcodec.so",
                            "lib/x86_64/libavformat.so",
                            "lib/x86_64/libavutil.so",
                            "lib/x86_64/libswscale.so",
                            "lib/x86_64/libavdevice.so",
                            "lib/x86_64/libavfilter.so",
                            "lib/x86_64/libffmpegkit.so",
                            "lib/x86_64/libffmpegkit_abidetect.so",
                            "lib/x86_64/libswresample.so",
                            "lib/x86_64/libswscale.so",
                            "lib/arm64-v8a/libliteavsdk.so",
                            "lib/armeabi-v7a/libliteavsdk.so",
                            "lib/x86/libliteavsdk.so",
                            "lib/x86_64/libliteavsdk.so"
                    )
        }
    }
}

flutter { source = "../.." }

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.jar", "*.aar"))))

    // 个推
    implementation("com.getui:gtsdk:3.3.12.0") // 个推SDK
    implementation("com.getui:gtc:3.2.18.0") // 个推核心组件

    // 华为
    implementation("com.huawei.hms:push:6.12.0.300")
    implementation("com.getui.opt:hwp:3.1.0")

    // 小米
    implementation("com.getui.opt:xmp:3.2.0")

    // oppo
    implementation("com.assist-v3:oppo:3.1.0") { exclude(group = "commons-codec") }
    implementation("com.google.code.gson:gson:2.6.2")
    implementation("commons-codec:commons-codec:1.6")
    implementation("com.android.support:support-annotations:28.0.0")

    // vivo
    implementation("com.assist-v3:vivo:3.1.0")

    // 荣耀
    implementation("com.getui.opt:honor:3.2.0")

    // 魅族
    implementation("com.getui.opt:mzp:3.2.0")

    // ups，ups目前支持坚果，索尼，海信手机
    implementation("com.getui.opt:ups:3.0.3")

    implementation("com.android.support:multidex:1.0.3")
}

// Fix for datastore dependency issues
configurations.all {
    resolutionStrategy { force("androidx.datastore:datastore-preferences:1.0.0") }
}

fun buildTime(): String {
    return SimpleDateFormat("MMddHHmm", Locale.getDefault())
            .apply { timeZone = TimeZone.getTimeZone("GMT+08:00") }
            .format(Date())
}
