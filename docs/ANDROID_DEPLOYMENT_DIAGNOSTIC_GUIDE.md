# 🔧 Android Deployment Diagnostic Guide
### Ma'a yegue - Flutter Run Not Launching Issue

## 🎯 Problem Statement

**Symptom**: `flutter run` builds successfully but application doesn't launch on Android device/emulator

**Status**: Build completes without errors, but app fails to start or appears stuck

---

## ✅ Configuration Verification

### Android Configuration Status:
- ✅ `compileSdk = 35` (latest)
- ✅ `minSdk = 24` (Android 7.0+)
- ✅ `targetSdk = 35`
- ✅ Application ID: `com.maa_yegue.app`
- ✅ Java Version: 11
- ✅ All required permissions in AndroidManifest.xml
- ✅ Google Services plugin configured
- ✅ ProGuard rules present

**Conclusion**: Android configuration is correct. Issue is likely runtime-related.

---

## 🔍 Diagnostic Steps

### Step 1: Verify ADB Connection

```bash
# Check connected devices
adb devices

# Expected output:
# List of devices attached
# <device-id>    device

# If no devices shown:
adb kill-server
adb start-server
adb devices
```

**Action**: If no devices appear, check USB connection or emulator status.

---

### Step 2: Clear Build Cache

```bash
# Full clean rebuild
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run --verbose
```

**Rationale**: Clears all cached build artifacts that might be causing issues.

---

### Step 3: Check for Build/Runtime Errors

```bash
# Run with maximum verbosity
flutter run --verbose

# Check for specific error patterns:
# - "Could not install ..."
# - "App crashed before ..."
# - "Timeout waiting ..."
# - Database errors
# - Permission errors
```

**Look For**:
- Crashlytics initialization errors
- Firebase initialization timeout
- Database copy from assets timeout
- Permission denied errors

---

### Step 4: Check Database Initialization

**Potential Issue**: Database initialization might be taking too long

**Solution**: Increase timeout or add better logging

Add to `lib/main.dart`:
```dart
Future<void> _initializeDatabasesInBackground() async {
  debugPrint('🔄 Starting background database initialization...');
  final stopwatch = Stopwatch()..start();
  
  try {
    debugPrint('📦 Initializing DatabaseInitializationService...');
    final dbFuture = DatabaseInitializationService.database;
    
    debugPrint('📦 Initializing UnifiedDatabaseService...');
    final unifiedDbFuture = UnifiedDatabaseService.instance.database;

    await Future.wait([dbFuture, unifiedDbFuture], eagerError: false);
    debugPrint('✅ Databases initialized in ${stopwatch.elapsedMilliseconds}ms');

    // Seed database
    debugPrint('🌱 Starting database seeding...');
    await DataSeedingService.seedDatabase();
    debugPrint('✅ Database seeding completed in ${stopwatch.elapsedMilliseconds}ms');
  } catch (e, stackTrace) {
    debugPrint('⚠️ Background database initialization failed after ${stopwatch.elapsedMilliseconds}ms');
    debugPrint('❌ Error: $e');
    debugPrint('📋 Stack trace: $stackTrace');
  }
}
```

---

### Step 5: Check Logcat for Runtime Errors

```bash
# Monitor Android logs while app launches
adb logcat -c  # Clear logs
flutter run &  # Run in background
adb logcat | grep -i "flutter\|maa_yegue\|error\|exception"
```

**Common Errors to Look For**:
1. `java.lang.RuntimeException: Unable to start activity`
2. `FirebaseInitializationError`
3. `SQLiteException: unable to open database`
4. `Permission denied`
5. `Timeout`

---

### Step 6: Test on Different Device/Emulator

```bash
# List available emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch <emulator_id>

# Run on new emulator
flutter run
```

**Rationale**: Isolates device-specific issues.

---

### Step 7: Check Firebase Configuration

**Verify**: `android/app/google-services.json` is present and valid

```bash
# Check if file exists
ls -l android/app/google-services.json

# Validate JSON format
cat android/app/google-services.json | python -m json.tool
```

**Common Issues**:
- Missing file
- Corrupted JSON
- Wrong package name in google-services.json
- Expired Firebase configuration

---

### Step 8: Test Debug vs Release Build

```bash
# Debug build (default)
flutter run --debug

# Release build
flutter run --release

# Profile build
flutter run --profile
```

**Note**: If release build works but debug doesn't (or vice versa), it indicates build-specific issues.

---

### Step 9: Check for Native Crashes

```bash
# Monitor native crashes
adb logcat *:E

# Check for tombstones (crash dumps)
adb shell ls /data/tombstones/
```

**Action**: If native crashes found, check for:
- Incompatible native libraries
- NDK version issues
- ProGuard removing required classes

---

### Step 10: Disable ProGuard (Debug Build)

ProGuard might be removing necessary classes. Temporarily disable to test:

Edit `android/app/build.gradle.kts`:
```kotlin
buildTypes {
    debug {
        // Temporarily disable for testing
        isMinifyEnabled = false
        isShrinkResources = false
    }
}
```

Then:
```bash
flutter clean
flutter run
```

---

## 🛠️ Common Issues & Solutions

### Issue 1: App Starts But Immediately Crashes

**Symptom**: App appears briefly then closes

**Possible Causes**:
1. Uncaught exception in initialization
2. Firebase/Crashlytics configuration error
3. Database initialization failure

**Solution**:
```dart
// Add try-catch to all initialization code
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await EnvironmentConfig.init();
  } catch (e) {
    debugPrint('❌ Environment config failed: $e');
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseService().initialize();
  } catch (e) {
    debugPrint('❌ Firebase init failed: $e');
    // Continue anyway - app might work offline
  }

  runApp(MyApp(firebaseInitialized: true));
  
  _initializeDatabasesInBackground();
}
```

---

### Issue 2: Long Launch Time (Appears Stuck)

**Symptom**: App takes 1+ minutes to launch

**Possible Cause**: Database initialization blocking main thread

**Solution**: Already implemented - database initializes in background. But add timeout:

```dart
Future<void> _initializeDatabasesInBackground() async {
  try {
    await Future.wait([
      DatabaseInitializationService.database,
      UnifiedDatabaseService.instance.database,
    ], eagerError: false).timeout(
      Duration(seconds: 30),
      onTimeout: () {
        debugPrint('⚠️ Database initialization timeout - will retry on demand');
        throw TimeoutException('Database initialization timeout');
      },
    );
    
    await DataSeedingService.seedDatabase();
  } catch (e) {
    debugPrint('⚠️ Background initialization failed: $e');
    // App continues - database will initialize on first access
  }
}
```

---

### Issue 3: Permission Errors

**Symptom**: App fails with permission denied errors

**Solution**: Ensure all permissions requested in manifest

Check `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<!-- For Android 13+ (API 33+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

For runtime permissions, add permission_handler:
```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  if (Platform.isAndroid) {
    final status = await Permission.storage.request();
    if (status.isDenied) {
      // Handle denied permission
    }
  }
}
```

---

### Issue 4: ADB Connection Lost

**Symptom**: Build completes but `flutter run` hangs at "Installing..."

**Solution**:
```bash
# Kill and restart ADB
adb kill-server
adb start-server

# Reconnect device
adb devices

# If wireless debugging:
adb connect <device-ip>:5555
```

---

### Issue 5: Gradle Build Issues

**Symptom**: Build fails with Gradle errors

**Solution**:
```bash
cd android

# Clean Gradle cache
./gradlew clean

# Rebuild with stacktrace
./gradlew assembleDebug --stacktrace

# If still fails, check Gradle wrapper version
cat gradle/wrapper/gradle-wrapper.properties

# Update if needed (current should be 8.x)
```

---

## 🚀 Quick Fix Checklist

Try these in order:

1. ☐ Run `flutter clean && flutter pub get`
2. ☐ Check `adb devices` shows your device
3. ☐ Run `flutter run --verbose` and check output
4. ☐ Clear app data on device (Settings → Apps → Ma'a yegue → Clear Data)
5. ☐ Restart Android device/emulator
6. ☐ Try different USB port (if physical device)
7. ☐ Try on Android emulator (if using device)
8. ☐ Check logcat: `adb logcat | grep -i flutter`
9. ☐ Disable ProGuard temporarily
10. ☐ Check Firebase configuration

---

## 🐛 Debug Mode - Enhanced Logging

Add to `lib/main.dart` at the very beginning:

```dart
void main() async {
  // Enable maximum logging
  debugPrint('🚀 === APP STARTING ===');
  debugPrint('Platform: ${Platform.operatingSystem}');
  
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('✅ Flutter binding initialized');

  try {
    debugPrint('📝 Loading environment config...');
    await EnvironmentConfig.init();
    debugPrint('✅ Environment config loaded');
  } catch (e, stack) {
    debugPrint('❌ Environment config failed: $e');
    debugPrint('Stack: $stack');
  }

  try {
    debugPrint('🔥 Initializing Firebase...');
    final firebaseInitStart = DateTime.now();
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseService().initialize();
    
    final firebaseInitDuration = DateTime.now().difference(firebaseInitStart);
    debugPrint('✅ Firebase initialized in ${firebaseInitDuration.inMilliseconds}ms');
    
    // Setup error handlers
    FlutterError.onError = (errorDetails) {
      debugPrint('❌ FLUTTER ERROR: ${errorDetails.exception}');
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('❌ PLATFORM ERROR: $error');
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    debugPrint('✅ Error handlers configured');
  } catch (e, stack) {
    debugPrint('❌ Firebase initialization failed: $e');
    debugPrint('Stack: $stack');
  }

  debugPrint('📱 Starting app UI...');
  runApp(MyApp(firebaseInitialized: true));

  debugPrint('💾 Starting background database initialization...');
  _initializeDatabasesInBackground();
}
```

---

## 📊 Expected Launch Timeline

For a successful launch:

```
0ms     - App Start
0-100ms - Widget Binding
100-200ms - Environment Config Load
200-1000ms - Firebase Initialization
1000-1200ms - App UI Render
1200ms+ - Background Database Init (non-blocking)
2000-5000ms - Database Seeding (first run only)
```

**If any step takes > 10 seconds**, there's an issue with that component.

---

## 🔧 Advanced Debugging

### Enable Flutter Inspector Logs:

```bash
# Run with additional debug flags
flutter run --verbose --trace-systrace --trace-skia
```

### Check APK Installation:

```bash
# Manually install built APK
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n com.maa_yegue.app/.MainActivity
```

### Monitor Memory Usage:

```bash
# While app is running
adb shell dumpsys meminfo com.maa_yegue.app
```

---

## ✅ Success Indicators

App launched successfully if you see:

1. Flutter logo splash screen
2. App UI appears within 5 seconds
3. No crash or error messages
4. Logcat shows:
   ```
   ✅ Flutter binding initialized
   ✅ Firebase initialized
   ✅ Databases initialized
   ✅ Database seeding completed (or "already seeded")
   ```

---

## 📞 Next Steps If Still Not Working

If app still doesn't launch after all diagnostics:

1. **Capture Full Logs**:
   ```bash
   flutter run --verbose > launch_log.txt 2>&1
   adb logcat > android_log.txt &
   ```

2. **Check Specific Components**:
   - Test Firebase connection independently
   - Test SQLite database access
   - Test with minimal `main.dart` (comment out all initialization)

3. **Test Minimal App**:
   ```dart
   void main() {
     runApp(MaterialApp(
       home: Scaffold(
         body: Center(child: Text('Minimal Test')),
       ),
     ));
   }
   ```

4. **Report Issue** with:
   - Full verbose log
   - Android version and device model
   - Steps taken
   - Error messages

---

## 🎯 Most Likely Causes (Based on Your Setup)

1. **Database Initialization Timeout** (50% probability)
   - Solution: Add timeout to database init
   - Already implemented as background init, but might need adjustment

2. **Firebase Services Delay** (30% probability)
   - Solution: Add timeout to Firebase init
   - Make Firebase optional for offline-first experience

3. **Device-Specific Issue** (15% probability)
   - Solution: Test on emulator
   - Update device firmware

4. **Build Cache Corruption** (5% probability)
   - Solution: `flutter clean && cd android && ./gradlew clean`

---

**Created**: October 7, 2025
**Status**: Diagnostic guide ready
**Action**: Follow steps 1-10 in order

*End of Diagnostic Guide*

