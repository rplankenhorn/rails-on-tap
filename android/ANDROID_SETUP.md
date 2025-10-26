# Android Project Setup for Rails on Tap

This guide explains the correct way to open and configure the Rails on Tap Android project in Android Studio.

## Project Structure

The Android project is located at `rails-on-tap/android/` within the monorepo:

```
rails-on-tap/
├── app/                          # Rails backend
├── android/                       # Android app (this is what you open)
│   ├── app/                      # Main app module
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/com/railsontap/
│   │   │       │   └── MainActivity.kt
│   │   │       ├── res/
│   │   │       │   ├── layout/
│   │   │       │   │   └── activity_main.xml
│   │   │       │   └── nav_graph.xml
│   │   │       └── AndroidManifest.xml
│   │   └── build.gradle
│   ├── build.gradle              # Root gradle build file
│   ├── settings.gradle           # Gradle project settings
│   ├── gradle.properties         # Gradle configuration
│   ├── README.md
│   └── local.properties          # Local development settings (auto-generated)
├── config/
├── db/
└── [other Rails files...]
```

## Opening in Android Studio

### Method 1: Open the Android Directory (RECOMMENDED)

1. **In Android Studio**, go to `File → Open`
2. **Navigate** to `/Users/rplankenhorn/rails-on-tap/android`
3. **Click "Open"**
4. Wait for Gradle to sync
5. Click "Trust Project" if prompted

### Method 2: Import as a Gradle Project

1. **In Android Studio**, go to `File → New → Import Project`
2. Navigate to `/Users/rplankenhorn/rails-on-tap/android`
3. Click "OK"
4. Android Studio will detect it as a Gradle project

### Method 3: Command Line

```bash
cd /Users/rplankenhorn/rails-on-tap/android
open .
# Then open with Android Studio, or:
# open -a "Android Studio" .
```

## Gradle Sync Troubleshooting

### Problem: "Plugin [id: 'com.android.application'] was not found"

**Solution**: This error occurs if you try to open `rails-on-tap/` (the Rails root) instead of `rails-on-tap/android/`.

- ❌ **Wrong**: Open `/Users/rplankenhorn/rails-on-tap`
- ✅ **Correct**: Open `/Users/rplankenhorn/rails-on-tap/android`

### Problem: Gradle Sync Failed

**Solution 1**: Invalidate caches and restart
- `File → Invalidate Caches → Invalidate and Restart`

**Solution 2**: Update Gradle
- `Android Studio → Preferences → Build, Execution, Deployment → Gradle`
- Check "Use Gradle from 'gradle-wrapper.properties'"

**Solution 3**: Check Java version
```bash
java -version  # Should be Java 11 or higher
```

### Problem: "Gradle wrapper not found"

**Solution**: The Gradle wrapper will be downloaded automatically on first sync. If it doesn't:

```bash
cd /Users/rplankenhorn/rails-on-tap/android
./gradlew wrapper --gradle-version=8.2
```

## Configuration Files Explained

### `settings.gradle`
Defines the project name and module structure:
```gradle
rootProject.name = "Rails on Tap"
include ":app"
project(":app").projectDir = file("app")
```

### `build.gradle` (root)
Defines build plugins available to all modules:
```gradle
plugins {
    id 'com.android.application' version '8.2.0' apply false
    id 'org.jetbrains.kotlin.android' version '1.9.22' apply false
}
```

### `app/build.gradle`
Defines build configuration and dependencies for the app module:
```gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
}
// ... Android configuration and dependencies
```

### `gradle.properties`
Global Gradle settings:
- `org.gradle.jvmargs` - JVM memory settings
- `android.useAndroidX=true` - Use AndroidX libraries
- `kotlin.incremental=true` - Enable incremental compilation

### `local.properties` (auto-generated)
Contains local development settings like SDK path:
```
sdk.dir=/Users/rplankenhorn/Library/Android/sdk
```

## Building and Running

### Command Line

```bash
cd /Users/rplankenhorn/rails-on-tap/android

# Build
./gradlew build

# Run on emulator
./gradlew installDebug

# Debug build
./gradlew assembleDebug

# Release build
./gradlew assembleRelease

# Clean
./gradlew clean
```

### Android Studio

1. **Build**: `Build → Make Project`
2. **Run**: `Run → Run 'app'`
3. **Debug**: `Run → Debug 'app'`

## Android Studio Run Configuration

Once opened correctly, Android Studio should automatically create a run configuration for the `app` module. You should see:

- A run button (green play icon) in the toolbar
- A dropdown showing `app` as the module to run
- An emulator or connected device selector

If the run button is greyed out:
1. Make sure you have an Android emulator running or device connected
2. Rebuild the project: `Build → Rebuild Project`
3. Invalidate caches: `File → Invalidate Caches → Invalidate and Restart`

## Testing

### Unit Tests
```bash
./gradlew test
```

### Instrumented Tests (on emulator/device)
```bash
./gradlew connectedAndroidTest
```

## Emulator Setup

### Start Emulator from Command Line
```bash
# List available emulators
$ANDROID_HOME/emulator/emulator -list-avds

# Start an emulator
$ANDROID_HOME/emulator/emulator -avd <emulator_name>
```

### Create New Emulator
1. In Android Studio: `Tools → Device Manager`
2. Click "Create Device"
3. Select device model and API level (at least API 24)
4. Click "Finish"

### Connect to Rails Backend

When running the app on the emulator:
- **Local Backend**: Use `http://10.0.2.2:3000` in the app
- **Remote Backend**: Use the actual server URL

In `MainActivity.kt`:
```kotlin
override val startLocation: URL
    get() = URL("http://10.0.2.2:3000")  // Emulator
    // OR
    get() = URL("http://192.168.1.100:3000")  // Physical device (replace IP)
```

## Next Steps

1. ✅ Open `/Users/rplankenhorn/rails-on-tap/android` in Android Studio
2. ✅ Wait for Gradle to sync
3. ✅ Select a device or start the emulator
4. ✅ Click Run (green play button)
5. ✅ The Hotwire Native app will load and navigate to your Rails backend

## Useful Links

- [Android Studio Documentation](https://developer.android.com/studio/intro)
- [Gradle Build System](https://developer.android.com/build)
- [Hotwire Native Android](https://github.com/hotwired/hotwire-android)
- [Kotlin for Android](https://kotlinlang.org/docs/android-overview.html)

## Still Having Issues?

1. Check the [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
2. Review the [main README](../README.md)
3. Check Gradle sync output in the "Build" panel
4. Try `File → Invalidate Caches → Invalidate and Restart`
