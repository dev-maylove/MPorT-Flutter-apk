buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Raise Built-in Kotlin / KGP above AGP's embedded 2.2.10
        // (Flutter 3.47 requires ≥ 2.2.20). App module still does not apply
        // org.jetbrains.kotlin.android — only version override.
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.4.10")
    }
}

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
