import groovy.json.JsonOutput
import org.jetbrains.kotlin.gradle.plugin.mpp.pm20.util.archivesName
import org.jetbrains.kotlin.ir.types.IdSignatureValues.result
import java.nio.file.Paths

plugins {
    alias(libs.plugins.androidLibrary)
    alias(libs.plugins.jetbrainsKotlinAndroid)
    id("maven-publish")
}

android {
    namespace = "io.github.byhook.prefab.ffmpeg"
    compileSdk = 34

    defaultConfig {
        minSdk = 21

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        consumerProguardFiles("consumer-rules.pro")
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
}

val targetPrefabDir = rootProject.layout.buildDirectory.dir("prefab-ffmpeg")

tasks.register<Exec>("buildPrefab") {
    val targetFile = File(project.projectDir, "build_prefab_v2.sh")
    println("buildPrefab ===========================>${targetFile.exists()}")
    commandLine = mutableListOf("bash", targetFile.absolutePath)
}


tasks.register("generateModules") {
    println("generateModules")
    //重新创建一次
    val prefabDir = targetPrefabDir.get().dir("prefab")
    mkdir(prefabDir)
    mkdir(prefabDir.dir("modules"))



}

inner class Prefab {
    var schema_version: Int = 2
    var name: String = ""
    var version: String = ""
    var dependencies: List<String> = mutableListOf()
}

tasks.register<Copy>("generateAndroidManifest") {
    println("generateAndroidManifest")
    //拷贝清单文件
    val filePath = Paths.get("src", "main", "AndroidManifest.xml").toFile()
    from(filePath)
    destinationDir = targetPrefabDir.get().asFile
}

tasks.register<Copy>("combinePrefab") {
    println("combinePrefab ===========================>")
    val prefab = Prefab()
    val result = JsonOutput.toJson(prefab)
    println("combinePrefab ===========================>$result")
}


tasks.register<Zip>("packagePrefab") {
    //先删除原目录
    delete(targetPrefabDir)
    //重新创建一次
    mkdir(targetPrefabDir)
    //开始进行
    println("packagePrefab ===========================>")
    dependsOn(tasks.getByName("generateModules"))
    dependsOn(tasks.getByName("generateAndroidManifest"))
    /*
    archivesName = "hello"
    from(rootProject.layout.buildDirectory.dir("prefab-ffmpeg"))
    destinationDirectory = rootProject.layout.buildDirectory.dir("world")
     */
}











tasks.register("buildArtifact") {
    dependsOn(tasks.getByName("packagePrefab"))
    println("buildArtifact ===========================>")
    val targetFile = File(rootDir, "build/outputs/ffmpeg-6.0.1.aar")
    outputs.file(targetFile.absolutePath)
}

publishing {
    publications {
        register<MavenPublication>("release") {
            groupId = "io.github.byhook"
            artifactId = "prefab-ffmpeg"
            version = "6.0.1.1"
            afterEvaluate {
                artifact(tasks.named("buildArtifact"))
            }
        }
    }
}