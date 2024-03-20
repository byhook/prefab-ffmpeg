import com.google.gson.GsonBuilder
import io.github.byhook.prefab.task.GeneratePrefabTask
import org.apache.commons.io.FileUtils
import org.jetbrains.kotlin.gradle.plugin.mpp.pm20.util.archivesName
import java.nio.file.Paths

plugins {
    alias(libs.plugins.androidLibrary)
    alias(libs.plugins.jetbrainsKotlinAndroid)
    id("io.github.byhook.prefab")
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

generatePrefab {
    val rootBuildDir = rootProject.layout.buildDirectory
    prefabName = "ffmpeg"
    prefabVersion = "6.0.1"
    prefabArtifactDir = rootBuildDir.dir("outputs")
    prefabDir = rootBuildDir.dir("prefab-generate")
    abiList = mutableListOf("arm64-v8a") //, "armeabi-v7a", "x86_64", "x86"
    manifestFile = layout.projectDirectory
        .dir("src")
        .dir("main")
        .file("AndroidManifest.xml")
        .asFile
    module("avcodec.so", false) {
        this.libraryName = "libavcodec"
        this.libraryFileName = "libavcodec.so"
        this.libsDir = rootProject.layout.buildDirectory.dir("libs")
        this.includeDir = rootProject.layout.buildDirectory.dir("include")
    }
    module("avdevice.so", false) {
        this.libraryName = "libavdevice"
        this.libraryFileName = "libavdevice.so"
        this.libsDir = rootProject.layout.buildDirectory.dir("libs")
        this.includeDir = rootProject.layout.buildDirectory.dir("include")
    }
    module("avfilter.so", false) {
        this.libraryName = "libavfilter"
        this.libraryFileName = "libavfilter.so"
        this.libsDir = rootProject.layout.buildDirectory.dir("libs")
        this.includeDir = rootProject.layout.buildDirectory.dir("include")
    }
    module("avformat.so", false) {
        this.libraryName = "libavformat"
        this.libraryFileName = "libavformat.so"
        this.libsDir = rootProject.layout.buildDirectory.dir("libs")
        this.includeDir = rootProject.layout.buildDirectory.dir("include")
    }
    module("avutil.so", false) {
        this.libraryName = "libavutil"
        this.libraryFileName = "libavutil.so"
        this.libsDir = rootProject.layout.buildDirectory.dir("libs")
        this.includeDir = rootProject.layout.buildDirectory.dir("include")
    }
    module("swresample.so", false) {
        this.libraryName = "libswresample"
        this.libraryFileName = "libswresample.so"
        this.libsDir = rootProject.layout.buildDirectory.dir("libs")
        this.includeDir = rootProject.layout.buildDirectory.dir("include")
    }
    module("swscale.so", false) {
        this.libraryName = "libswscale"
        this.libraryFileName = "libswscale.so"
        this.libsDir = rootProject.layout.buildDirectory.dir("libs")
        this.includeDir = rootProject.layout.buildDirectory.dir("include")
    }
}

tasks.register<Zip>("buildArtifact") {
    println("buildArtifact ===========================>")
    dependsOn(tasks.withType(GeneratePrefabTask::class.java))
    archivesName = "ffmpeg"
    archiveExtension = "aar"
    from(rootProject.layout.buildDirectory.dir("prefab-generate"))
    destinationDirectory = rootProject.layout.buildDirectory.dir("outputs")
}

publishing {
    publications {
        register<MavenPublication>("release") {
            groupId = "io.github.byhook"
            artifactId = "prefab-ffmpeg"
            version = "6.0.1.3"
            afterEvaluate {
                artifact(tasks.named("buildArtifact"))
            }
        }
    }
}