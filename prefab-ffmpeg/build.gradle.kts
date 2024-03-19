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

tasks.register<Exec>("buildPrefab") {
    val targetFile = File(project.projectDir, "build_prefab_v2.sh")
    println("buildPrefab ===========================>${targetFile.exists()}")
    commandLine = mutableListOf("bash", targetFile.absolutePath)
}

tasks.register("buildArtifact") {
    //dependsOn(tasks.getByName("buildPrefab"))
    println("buildArtifact ===========================>")
    val targetFile = File(rootDir, "build/outputs/ffmpeg-6.0.1.aar")
    outputs.file(targetFile.absolutePath)
}

publishing {
    publications {
        register<MavenPublication>("release") {
            groupId = "io.github.byhook"
            artifactId = "prefab-ffmpeg"
            version = "6.0.1.0"
            afterEvaluate {
                artifact(tasks.named("buildArtifact"))
            }
        }
    }
}