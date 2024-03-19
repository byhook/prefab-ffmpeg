import com.google.gson.GsonBuilder
import org.apache.commons.io.FileUtils
import org.jetbrains.kotlin.gradle.plugin.mpp.pm20.util.archivesName
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

val abiList = mutableListOf(
    "arm64-v8a",
    //"armeabi-v7a"
)

val libraryList = mutableListOf(
    "avcodec",
    "avdevice",
    "avfilter",
    "avformat",
    "avutil",
    "swresample",
    "swscale",
)

class ModuleJson {
    var export_libraries: List<String> = mutableListOf()
    var android: AndroidData = AndroidData()

    class AndroidData {
        var library_name: String = ""
        var export_libraries: List<String> = mutableListOf()
    }

}

class AbiJson {
    var abi: String = "arm64-v8a"
    var api: Int = 21
    var ndk: Int = 25
    var stl: String = "c++_shared"
    var static: Boolean = false
}

fun jsonFormat(target: Any): String {
    return GsonBuilder().setPrettyPrinting().create().toJson(target)
}

tasks.register("generateModules") {
    println("generateModules")
    //重新创建一次
    val prefabDir = targetPrefabDir.get().dir("prefab")
    mkdir(prefabDir)
    val modulesDir = prefabDir.dir("modules")
    mkdir(modulesDir)
    //遍历ABI列表
    abiList.forEach { abiName ->
        libraryList.forEach { libName ->
            //例如：modules/lame
            val libNameDir = modulesDir.dir(libName)
            mkdir(libNameDir)
            val libsDir = libNameDir.dir("libs")
            val incsDir = libNameDir.dir("include")
            mkdir(libsDir)
            mkdir(incsDir)
            //拷贝头文件目录
            val targetIncludeFile =
                rootProject.layout.buildDirectory.dir("include").get().dir("lib$libName")
            FileUtils.copyDirectory(targetIncludeFile.asFile, incsDir.dir("lib$libName").asFile)
            //拷贝库目录
            val targetLibraryFile = libsDir.dir("android.$abiName")
            val sourceLibraryFile = rootProject.layout.buildDirectory.dir("libs").get().dir(abiName)
            file(sourceLibraryFile.file("lib$libName.so").asFile)
                .copyTo(targetLibraryFile.file("lib$libName.so").asFile)

            //生成abi.json文件
            var abiJson = AbiJson().apply {
                this.abi = abiName
                /*
                this.stl
                this.static
                 */
            }
            val abiFormatResult = jsonFormat(abiJson)
            file(targetLibraryFile.file("abi.json")).writeText(abiFormatResult)
            //生成module.json文件
            val moduleJson = ModuleJson().apply {
                this.android.library_name = libName
            }
            val moduleFormatResult = jsonFormat(moduleJson)
            file(libNameDir.file("module.json")).writeText(moduleFormatResult)
        }
    }
    //生成prefab.json文件
    val prefab = Prefab()
    val result = jsonFormat(prefab)
    println("generate prefab.json: $result")
    file(prefabDir.file("prefab.json")).writeText(result)
}

class Prefab {
    var schema_version: Int = 2
    var name: String = "ffmpeg"
    var version: String = "6.0.1"
    var dependencies: List<String> = mutableListOf()
}

tasks.register<Copy>("generateAndroidManifest") {
    println("generateAndroidManifest")
    //拷贝清单文件
    val filePath = Paths.get("src", "main", "AndroidManifest.xml").toFile()
    from(filePath)
    destinationDir = targetPrefabDir.get().asFile
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
    archivesName = "ffmpeg-6.0.1"
    archiveExtension = "aar"
    from(targetPrefabDir)
    destinationDirectory = rootProject.layout.buildDirectory.dir("outputs")
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