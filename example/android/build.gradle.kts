allprojects {
    repositories {
        google()
        mavenCentral()
        flatDir {
            // 指向插件内部的 libs 目录
            // 使用 rootProject.projectDir 确保路径始终相对于 android 根目录
            // 在 example/android 下，插件的 libs 目录位于 ../../android/libs
            dirs(rootProject.projectDir.resolve("../../android/libs"))
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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
