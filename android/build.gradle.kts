buildscript {
    val kotlinVersion = "2.1.0"
    extra["kotlin_version"] = kotlinVersion
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://maven.aliyun.com/nexus/content/groups/public/") }
        maven { url = uri("https://maven.aliyun.com/nexus/content/repositories/jcenter") }
        maven { url = uri("https://maven.aliyun.com/nexus/content/repositories/google") }
        maven { url = uri("https://maven.aliyun.com/nexus/content/repositories/gradle-plugin") }
        // maven { url = uri("https://mvn.gt.getui.com/nexus/content/repositories/releases/") }
        maven {
            url = uri("https://mvn.getui.com/nexus/content/repositories/releases/")
        }
        maven { url = uri("https://developer.huawei.com/repo/") }    // hms
        maven { url = uri("https://dl.google.com/dl/android/maven2/") }   // fcm
        maven {
            url = uri("https://maven.columbus.heytapmobi.com/repository/releases/")
            credentials {
                username = "nexus"
                password = "c0b08da17e3ec36c3870fed674a0bcb36abc2e23"
            }
        }
    }

    dependencies {
        classpath("com.android.tools:r8:8.3.37")
        classpath("com.android.tools.build:gradle:8.5.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        classpath("com.google.gms:google-services:4.4.2")  // fcm
        classpath("com.huawei.agconnect:agcp:1.5.2.300")    // hms
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://maven.aliyun.com/nexus/content/groups/public/") }
        maven { url = uri("https://maven.aliyun.com/nexus/content/repositories/jcenter") }
        maven { url = uri("https://maven.aliyun.com/nexus/content/repositories/google") }
        maven { url = uri("https://maven.aliyun.com/nexus/content/repositories/gradle-plugin") }
        // maven { url = uri("https://mvn.gt.getui.com/nexus/content/repositories/releases/") }
        maven {
            url = uri("https://mvn.getui.com/nexus/content/repositories/releases/")
        }
        maven { url = uri("https://developer.huawei.com/repo/") }    // hms
        maven { url = uri("https://dl.google.com/dl/android/maven2/") }   // fcm
        maven {
            url = uri("https://maven.columbus.heytapmobi.com/repository/releases/")
            credentials {
                username = "nexus"
                password = "c0b08da17e3ec36c3870fed674a0bcb36abc2e23"
            }
        }
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
