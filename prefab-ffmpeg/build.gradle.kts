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

tasks.register<Exec>("crossCompile") {
    val targetFile = File(project.projectDir, "build_ffmpeg.sh")
    commandLine = mutableListOf("bash", targetFile.absolutePath)
}

generatePrefab {
    //前置依赖交叉构建完成
    dependsOn("crossCompile")
    //配置基础信息
    val rootBuildDir = rootProject.layout.buildDirectory
    //交叉编译生成的库目录
    sourceLibsDir = rootBuildDir.dir("libs").get()
    //交叉编译生成的头文件目录
    sourceIncsDir = rootBuildDir.dir("include").get()
    //生成预构建库的临时目录
    prefabBuildDir = rootBuildDir.dir("prefab-build").get()
    //最终打包完整的aar文件的产物目录
    prefabArtifactDir = rootBuildDir.dir("prefab-artifact").get()
    //指定预构建库的名字
    prefabName = "ffmpeg"
    //指定预构建库的版本号
    prefabVersion = "6.0.1"
    //预构建库支持abi的列表
    abiList = mutableListOf("arm64-v8a", "armeabi-v7a", "x86_64", "x86")
    //生成的aar文件里包含的清单文件
    manifestFile = layout.projectDirectory
        .dir("src")
        .dir("main")
        .file("AndroidManifest.xml")
        .asFile
    module("avcodec.so", false) {
        this.libraryName = "libavcodec"
        this.libraryFileName = "libavcodec.so"
    }
    module("avdevice.so", false) {
        this.libraryName = "libavdevice"
        this.libraryFileName = "libavdevice.so"
    }
    module("avfilter.so", false) {
        this.libraryName = "libavfilter"
        this.libraryFileName = "libavfilter.so"
    }
    module("avformat.so", false) {
        this.libraryName = "libavformat"
        this.libraryFileName = "libavformat.so"
    }
    module("avutil.so", false) {
        this.libraryName = "libavutil"
        this.libraryFileName = "libavutil.so"
    }
    module("swresample.so", false) {
        this.libraryName = "libswresample"
        this.libraryFileName = "libswresample.so"
    }
    module("swscale.so", false) {
        this.libraryName = "libswscale"
        this.libraryFileName = "libswscale.so"
    }
}

publishing {
    publications {
        register<MavenPublication>("release") {
            groupId = "io.github.byhook"
            artifactId = "prefab-ffmpeg"
            version = "6.0.1.3"
            afterEvaluate {
                artifact(tasks.named("generatePrefabTask"))
            }
        }
    }
}