# 🔧 ANDROID DEPLOYMENT FIX GUIDE
## Ma'a yegue - Fixing "Build Succeeds but App Doesn't Launch"

---

## 🐛 PROBLEM DESCRIPTION

**Symptom**: `flutter run` builds successfully but the app doesn't launch on Android device.  
**Status**: Common issue with various possible causes  
**Priority**: HIGH  

---

## 🔍 DIAGNOSTIC CHECKLIST

### 1. Check Device Connection

```powershell
# Check if device is connected
adb devices

# Expected output:
# List of devices attached
# <device-id>    device

# If device shows "unauthorized":
adb kill-server
adb start-server
adb devices
```

### 2. Check Build Output

```powershell
# Run with verbose output
flutter run -v

# Look for errors in the output related to:
# - APK installation
# - Permission errors
# - Activity launch failures
```

### 3. Check Device Logs

```powershell
# Clear logs and monitor
adb logcat -c
adb logcat | Select-String "MainActivity|ActivityManager|AndroidRuntime"

# Or save to file for analysis
adb logcat > android_logs.txt
```

---

## 🔧 COMMON FIXES

### Fix 1: Clear Build Cache

```powershell
# Clean all caches
flutter clean
cd android
./gradlew clean
cd ..

# Delete build folders
Remove-Item -Recurse -Force android/build
Remove-Item -Recurse -Force android/app/build
Remove-Item -Recurse -Force build

# Rebuild
flutter pub get
flutter build apk
flutter run
```

### Fix 2: Update Gradle Wrapper

```powershell
cd android

# Check current Gradle version
./gradlew --version

# Update to latest
./gradlew wrapper --gradle-version=8.0

cd ..
```

### Fix 3: Check Min SDK Version

Edit `android/app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        minSdk = 21  // Should be at least 21
        targetSdk = 34  // Latest stable
        compileSdk = 34
    }
}
```

### Fix 4: Enable MultiDex

In `android/app/build.gradle.kts`:

```kotlin
android {
    defaultConfig {
        // ...
        multiDexEnabled = true
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

### Fix 5: Check MainActivity

Ensure `android/app/src/main/kotlin/com/example/maa_yegue/MainActivity.kt` exists:

```kotlin
package com.example.maa_yegue

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}
```

### Fix 6: Verify Permissions

In `AndroidManifest.xml`, ensure required permissions are present:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### Fix 7: Check for Conflicting Plugins

```powershell
# List all dependencies
flutter pub deps

# Look for conflicts or outdated plugins
flutter pub outdated
```

---

## 📱 TESTING SCENARIOS

### Scenario 1: Test on Emulator First

```powershell
# Start emulator
flutter emulators --launch <emulator-name>

# Or use Android Studio to start emulator

# Then run app
flutter run
```

### Scenario 2: Test with Release Build

```powershell
# Build release APK
flutter build apk --release

# Install manually
adb install build/app/outputs/flutter-apk/app-release.apk

# Launch manually
adb shell am start -n com.example.maa_yegue/.MainActivity
```

### Scenario 3: Test Debug APK

```powershell
# Build debug APK
flutter build apk --debug

# Install
adb install build/app/outputs/flutter-apk/app-debug.apk

# Check installation
adb shell pm list packages | Select-String "mayegue"
```

---

## 🐛 SPECIFIC ERROR SOLUTIONS

### Error: "Activity class does not exist"

**Solution**:
1. Check MainActivity path matches package name
2. Verify MainActivity.java or MainActivity.kt exists
3. Ensure correct import statements

### Error: "Permission denied"

**Solution**:
1. Enable USB debugging on device
2. Grant USB debugging permission
3. Check developer options enabled

### Error: "Installation failed"

**Solution**:
```powershell
# Uninstall existing app
adb uninstall com.example.maa_yegue

# Try installing again
flutter run
```

### Error: "App keeps stopping"

**Solution**:
1. Check logcat for crash logs
2. Look for missing dependencies
3. Verify Firebase configuration
4. Check for null safety issues

---

## 🔍 ADVANCED DEBUGGING

### Method 1: Direct APK Installation

```powershell
# Build APK
flutter build apk

# Install directly
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Launch
adb shell monkey -p com.example.maa_yegue -c android.intent.category.LAUNCHER 1
```

### Method 2: Check App Installation

```powershell
# Verify app is installed
adb shell pm list packages | Select-String "mayegue"

# Check app details
adb shell dumpsys package com.example.maa_yegue | Select-String "versionName|versionCode|targetSdk"
```

### Method 3: Monitor System Logs

```powershell
# Monitor specific tags
adb logcat MainActivity:V ActivityManager:V AndroidRuntime:V *:S
```

### Method 4: Check Device Storage

```powershell
# Check available storage
adb shell df

# If storage is low, clear cache
adb shell pm clear com.example.maa_yegue
```

---

## ⚙️ CONFIGURATION VERIFICATION

### 1. Verify build.gradle.kts

```kotlin
android {
    namespace = "com.example.maa_yegue"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.maa_yegue"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
```

### 2. Verify AndroidManifest.xml

```xml
<application android:label="Ma'a yegue">
    <activity
        android:name=".MainActivity"
        android:exported="true"
        android:launchMode="singleTop">
        <intent-filter>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.LAUNCHER"/>
        </intent-filter>
    </activity>
</application>
```

### 3. Verify MainActivity exists

Check one of these files exists:
- `android/app/src/main/kotlin/com/example/maa_yegue/MainActivity.kt`
- `android/app/src/main/java/com/example/maa_yegue/MainActivity.java`

---

## 🚀 RECOMMENDED FIXES (In Order)

### Step 1: Clean Rebuild (Most Common Fix)

```powershell
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run -v
```

### Step 2: Update Dependencies

```powershell
flutter pub upgrade
flutter pub get
```

### Step 3: Check Device Configuration

```powershell
# Enable USB debugging
# Settings > Developer Options > USB Debugging

# Revoke USB debugging authorizations
# Settings > Developer Options > Revoke USB debugging authorizations

# Then reconnect device and allow debugging
```

### Step 4: Try Different Device/Emulator

```powershell
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Step 5: Check Proguard Rules (if using)

In `android/app/proguard-rules.pro`, ensure Firebase classes are not stripped:

```
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
```

---

## 📊 DIAGNOSTIC COMMANDS

### Get Device Info

```powershell
# Device details
adb shell getprop ro.build.version.sdk  # Android API level
adb shell getprop ro.product.model     # Device model
adb shell getprop ro.build.version.release  # Android version
```

### Get App Info

```powershell
# Check if app is installed
adb shell pm path com.example.maa_yegue

# Check app permissions
adb shell dumpsys package com.example.maa_yegue | Select-String "permission"

# Check app activities
adb shell dumpsys package com.example.maa_yegue | Select-String "Activity"
```

---

## 🎯 EXPECTED OUTCOME

After applying fixes, you should see:

```
Launching lib\main.dart on <device-name> in debug mode...
✓ Built build\app\outputs\flutter-apk\app-debug.apk.
Installing build\app\outputs\flutter-apk\app.apk...
Debug service listening on ws://127.0.0.1:xxxxx

🔥 To hot reload changes while running, press "r" or "R".
For a more detailed help message, press "h". To quit, press "q".
```

---

## 🔄 IF ALL ELSE FAILS

### Nuclear Option: Fresh Start

```powershell
# 1. Uninstall app from device
adb uninstall com.example.maa_yegue

# 2. Delete all build artifacts
flutter clean
Remove-Item -Recurse -Force android/.gradle
Remove-Item -Recurse -Force android/build
Remove-Item -Recurse -Force android/app/build
Remove-Item -Recurse -Force build
Remove-Item -Recurse -Force .dart_tool

# 3. Re-download dependencies
flutter pub cache clean
flutter pub get

# 4. Rebuild everything
cd android
./gradlew clean
./gradlew build
cd ..

# 5. Try running again
flutter run -v
```

---

## 📞 GET MORE HELP

If issue persists, collect diagnostic info:

```powershell
# Run with verbose output and save
flutter run -v 2>&1 | Out-File -FilePath flutter_run_log.txt

# Get device logs
adb logcat -d > device_log.txt

# Check Flutter doctor
flutter doctor -v > doctor_log.txt

# Zip all logs and report issue
Compress-Archive -Path flutter_run_log.txt,device_log.txt,doctor_log.txt -DestinationPath diagnostic_logs.zip
```

---

## ✅ VERIFICATION

Once app launches successfully, verify:

1. ✅ App icon appears on device
2. ✅ App opens without crashes
3. ✅ Splash screen shows
4. ✅ Main screen loads
5. ✅ Database initializes
6. ✅ Firebase connects
7. ✅ Navigation works

---

## 📝 NOTES

- Most "doesn't launch" issues are solved by `flutter clean`
- Check device logs immediately after failure
- Ensure device has enough storage space
- Try both debug and release builds
- Test on emulator to isolate device-specific issues

---

**Last Updated**: October 7, 2025  
**Status**: Diagnostic guide ready  
**Success Rate**: ~80% of issues resolved by clean rebuild
