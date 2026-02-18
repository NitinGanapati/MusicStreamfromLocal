////allprojects {
////    repositories {
////        google()
////        mavenCentral()
////    }
////}
////
////val newBuildDir: Directory =
////    rootProject.layout.buildDirectory
////        .dir("../../build")
////        .get()
////rootProject.layout.buildDirectory.value(newBuildDir)
////
////subprojects {
////    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
////    project.layout.buildDirectory.value(newSubprojectBuildDir)
////}
////subprojects {
////    project.evaluationDependsOn(":app")
////}
////
////tasks.register<Delete>("clean") {
////    delete(rootProject.layout.buildDirectory)
////}
//
//
//import org.gradle.jvm.toolchain.JavaLanguageVersion
//
//allprojects {
//    repositories {
//        google()
//        mavenCentral()
//    }
//}
//
//// 🔒 Pin JVM toolchain for ALL modules (including plugins)
//gradle.beforeProject {
//    plugins.withId("org.jetbrains.kotlin.android") {
//        the<org.jetbrains.kotlin.gradle.dsl.KotlinJvmProjectExtension>()
//            .jvmToolchain(17)
//    }
//    plugins.withId("org.jetbrains.kotlin.jvm") {
//        the<org.jetbrains.kotlin.gradle.dsl.KotlinJvmProjectExtension>()
//            .jvmToolchain(17)
//    }
//    plugins.withId("java") {
//        the<org.gradle.api.plugins.JavaPluginExtension>().toolchain {
//            languageVersion.set(JavaLanguageVersion.of(17))
//        }
//    }
//}
//
//val newBuildDir: Directory =
//    rootProject.layout.buildDirectory
//        .dir("../../build")
//        .get()
//rootProject.layout.buildDirectory.value(newBuildDir)
//
//subprojects {
//    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
//    project.layout.buildDirectory.value(newSubprojectBuildDir)
//}
//
//subprojects {
//    project.evaluationDependsOn(":app")
//}
//
//tasks.register<Delete>("clean") {
//    delete(rootProject.layout.buildDirectory)
//}


allprojects {
    repositories {
        google()
        mavenCentral()
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
