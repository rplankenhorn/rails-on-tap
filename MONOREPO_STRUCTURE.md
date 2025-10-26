# Android Project Structure - CORRECTED

## What Was Fixed

All Gradle files have been moved to the **correct location inside the `android/` directory**:

### ✅ CORRECT Structure (Current)

```
rails-on-tap/
├── android/                      ← THIS IS WHAT YOU OPEN IN ANDROID STUDIO
│   ├── build.gradle              ← Root Gradle build (defines plugins)
│   ├── settings.gradle           ← Project settings
│   ├── gradle.properties         ← Gradle configuration
│   ├── local.properties          ← Auto-generated, SDK path
│   ├── app/                      ← Main app module
│   │   ├── build.gradle          ← App-specific Gradle config
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/com/railsontap/
│   │   │       │   └── MainActivity.kt
│   │   │       ├── res/
│   │   │       │   ├── layout/activity_main.xml
│   │   │       │   └── nav_graph.xml
│   │   │       └── AndroidManifest.xml
│   │   └── proguard-rules.pro
│   └── README.md
├── app/                          ← Rails backend (separate from android/)
├── config/
├── db/
└── [other Rails files...]
```

### ❌ WRONG Structure (What Happened Earlier)

Gradle files were incorrectly placed at:
```
rails-on-tap/
├── build.gradle.kts          ← ❌ WRONG LOCATION (deleted)
├── settings.gradle.kts       ← ❌ WRONG LOCATION (deleted)
├── gradle.properties         ← ❌ WRONG LOCATION (deleted)
├── gradlew                   ← ❌ WRONG LOCATION (deleted)
├── gradlew.bat               ← ❌ WRONG LOCATION (deleted)
└── gradle/                   ← ❌ WRONG LOCATION (deleted)
```

## Why This Matters

1. **Gradle Configuration Hierarchy**:
   - Root `build.gradle` defines global plugins and dependency versions
   - App-level `build.gradle` applies plugins and configures Android build settings
   - Version numbers should ONLY be in root, not duplicated in modules

2. **Android Studio Discovery**:
   - When you open `rails-on-tap/android/`, Android Studio sees it as an Android project
   - It looks for `settings.gradle` to find modules (`app/`)
   - It looks for module-level `build.gradle` files

3. **Gradle Wrapper**:
   - Should be in `android/` (where Gradle projects live)
   - Not at monorepo root (which is a Rails project)

## How to Open in Android Studio

### ✅ CORRECT WAY:
1. `File → Open`
2. Navigate to `/Users/rplankenhorn/rails-on-tap/android`
3. Click "Open"

### ❌ WRONG WAY:
1. `File → Open`
2. Navigate to `/Users/rplankenhorn/rails-on-tap`  (Rails root)
3. This will fail because it's not an Android project!

## Files Moved

```
Before:
app/build.gradle              → After: android/app/build.gradle
AndroidManifest.xml           → After: android/app/src/main/AndroidManifest.xml
MainActivity.kt               → After: android/app/src/main/java/com/railsontap/MainActivity.kt
activity_main.xml             → After: android/app/src/main/res/layout/activity_main.xml
nav_graph.xml                 → After: android/app/src/main/res/nav_graph.xml
```

## Key Configuration Details

### `android/build.gradle` (Root)
```gradle
plugins {
    id 'com.android.application' version '8.2.0' apply false
    id 'com.android.library' version '8.2.0' apply false
    id 'org.jetbrains.kotlin.android' version '1.9.22' apply false
}
```

### `android/app/build.gradle` (Module)
```gradle
plugins {
    id 'com.android.application'      // ← No version here!
    id 'kotlin-android'               // ← No version here!
}
```

### `android/settings.gradle`
```gradle
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "Rails on Tap"
include ":app"
project(":app").projectDir = file("app")  // ← Points to app/ subdirectory
```

## Next Steps

1. Open `/Users/rplankenhorn/rails-on-tap/android` in Android Studio (NOT the root `rails-on-tap`)
2. Let Gradle sync
3. If you see errors, check `ANDROID_SETUP.md` in the android directory
4. Build and run!

## Monorepo Organization

The key insight for a monorepo:
- **Rails backend** = `rails-on-tap/` (root, with Gemfile, config/routes.rb, etc.)
- **Android app** = `rails-on-tap/android/` (Gradle project, NOT opened at root level)
- **Each has its own build system**: Rails (Bundler), Android (Gradle)
