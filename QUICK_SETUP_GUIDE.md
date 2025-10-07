# 🚀 QUICK SETUP GUIDE
## Ma'a yegue - Hybrid Architecture Setup

---

## ⚡ IMMEDIATE NEXT STEPS

### Step 1: Generate SQLite Database

```bash
# Navigate to database scripts
cd docs/database-scripts

# Run Python script to generate database
python create_cameroon_db.py

# Expected output: "OK - Cameroon Languages Database created successfully!"
# This creates: cameroon_languages.db (with 1000+ translations)
```

### Step 2: Copy Database to Assets

```bash
# Copy generated database to Flutter assets
cp cameroon_languages.db ../../assets/databases/

# Verify it's in the right place
ls ../../assets/databases/cameroon_languages.db
```

### Step 3: Clean and Rebuild App

```bash
# Navigate back to project root
cd ../..

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build and run on device
flutter run
```

---

## 📱 TESTING THE HYBRID ARCHITECTURE

### Test 1: Guest User (No Authentication)

1. Open app without logging in
2. Navigate to Dictionary
3. **Expected**: See all dictionary words from SQLite
4. Try accessing lessons (should allow 5 per day)
5. Try accessing quizzes (should allow 5 per day)

### Test 2: User Authentication

1. Click "Sign Up" or "Login"
2. Create account with Firebase Auth
3. **Expected**: User created in Firebase AND SQLite
4. Check user role (should be 'student' by default)

### Test 3: Data Persistence

1. Complete a lesson while logged in
2. Close app completely
3. Reopen app
4. **Expected**: Progress should be saved in SQLite
5. Check statistics dashboard

---

## 🐛 TROUBLESHOOTING

### Issue: Database not found
```
Error: Unable to open database
```
**Solution**:
1. Ensure `cameroon_languages.db` is in `assets/databases/`
2. Check `pubspec.yaml` includes `assets/databases/` in assets
3. Run `flutter clean` and `flutter pub get`

### Issue: App builds but doesn't launch on Android
```
Build succeeds but app doesn't start
```
**Solution** (requires investigation):
1. Check `android/app/src/main/AndroidManifest.xml`
2. Verify permissions are set
3. Check minimum SDK version (should be 21+)
4. Try: `flutter run -v` for verbose output
5. Check device logs: `adb logcat`

### Issue: Firebase not initializing
```
Firebase initialization error
```
**Solution**:
1. Verify `google-services.json` in `android/app/`
2. Check Firebase project configuration
3. Ensure internet connection
4. Check Firebase console for project status

---

## 📊 VERIFY DATABASE CONTENT

### Using SQLite CLI

```bash
# Open the generated database
cd assets/databases
sqlite3 cameroon_languages.db

# Check tables
.tables

# Check language count
SELECT COUNT(*) FROM languages;
# Expected: 7

# Check translations count
SELECT COUNT(*) FROM translations;
# Expected: 1000+

# Check categories
SELECT * FROM categories;
# Expected: 24 categories

# Check lessons
SELECT language_id, title FROM lessons LIMIT 10;

# Check quizzes
SELECT language_id, title FROM quizzes LIMIT 10;

# Exit
.quit
```

---

## 🎯 VERIFICATION CHECKLIST

### Database Generation ✓
- [ ] Python script runs successfully
- [ ] `cameroon_languages.db` file created
- [ ] Database size is reasonable (> 1MB)
- [ ] File copied to `assets/databases/`

### App Build ✓
- [ ] `flutter pub get` runs without errors
- [ ] `flutter analyze` shows 0 errors (only info/warnings OK)
- [ ] App builds successfully
- [ ] App launches on device/emulator

### Guest User Flow ✓
- [ ] Dictionary accessible without login
- [ ] All words visible from SQLite
- [ ] Daily limits enforced (5 lessons, 5 readings, 5 quizzes)
- [ ] Limits reset next day

### Authentication Flow ✓
- [ ] Sign up creates Firebase user
- [ ] User also created in SQLite `users` table
- [ ] Role assigned correctly
- [ ] Login works with existing users
- [ ] Password reset flow functional

### Data Persistence ✓
- [ ] Progress saved after completing lesson
- [ ] Statistics updated correctly
- [ ] Data persists after app restart
- [ ] Favorites saved successfully

---

## 🔍 DEBUGGING COMMANDS

### Flutter Logs
```bash
# Watch all logs
flutter logs

# Filter for database operations
flutter logs | grep "Database"

# Filter for errors only
flutter logs | grep "Error"
```

### Database Inspection (Inside App)
```dart
// Add this to any screen to check database path
final dbPath = await getDatabasesPath();
print('Database path: $dbPath');

// Check database stats
final db = UnifiedDatabaseService.instance;
final stats = await db.getPlatformStatistics();
print('Platform stats: $stats');
```

### Android Device Logs
```bash
# View all logs
adb logcat

# Filter for your app
adb logcat | grep "com.mayegue"

# Clear logs and start fresh
adb logcat -c
adb logcat
```

---

## 📈 EXPECTED RESULTS

### Database Statistics
- **Languages**: 7 (EWO, DUA, FEF, FUL, BAS, BAM, YMB)
- **Categories**: 24
- **Translations**: 1000+
- **Lessons**: 50+ (varies by language)
- **Quizzes**: 20+ (varies by language)

### App Performance
- **Startup Time**: < 3 seconds
- **Database Load**: < 1 second (background)
- **Dictionary Search**: < 100ms
- **Lesson Load**: < 200ms

### User Experience
- Smooth navigation
- No blocking operations
- Responsive UI
- Offline dictionary access
- Progress tracking works

---

## 🚨 KNOWN ISSUES

### 1. Android Deployment Issue ⚠️
**Status**: Needs investigation  
**Symptom**: Build succeeds but app doesn't launch  
**Priority**: High  
**Workaround**: Test on emulator first

### 2. Test File Warnings ℹ️
**Status**: Non-critical  
**Symptom**: 33 info/warnings in test files  
**Priority**: Low  
**Workaround**: Can be addressed later

---

## 📞 QUICK REFERENCE

### Important Files
- **Database Service**: `lib/core/database/unified_database_service.dart`
- **Database Script**: `docs/database-scripts/create_cameroon_db.py`
- **Main Entry**: `lib/main.dart`
- **Router**: `lib/core/router.dart`
- **Guest Service**: `lib/core/services/guest_limit_service.dart`

### Important Commands
```bash
# Regenerate database
python docs/database-scripts/create_cameroon_db.py

# Clean rebuild
flutter clean && flutter pub get && flutter run

# Check for errors
flutter analyze

# Run tests
flutter test

# Build release APK
flutter build apk --release
```

### Database Paths (Runtime)
- **Android**: `/data/data/com.example.maa_yegue/databases/`
- **iOS**: `~/Library/Application Support/databases/`

---

## ✅ SUCCESS CRITERIA

You'll know the setup is successful when:

1. ✅ Database generated without errors
2. ✅ App builds and launches
3. ✅ Dictionary shows 1000+ words
4. ✅ Guest limits work (5 per day)
5. ✅ Authentication creates users
6. ✅ Progress is saved and persists
7. ✅ No critical errors in logs

---

## 🎓 NEXT PHASE

After successful setup, proceed to:

1. **UI Updates** - Student, Teacher, Admin dashboards
2. **Testing** - Comprehensive test suite
3. **Optimization** - Performance tuning
4. **Deployment** - Production release

See `HYBRID_ARCHITECTURE_MIGRATION_REPORT.md` for detailed next steps.

---

**Setup Time**: ~10 minutes  
**Difficulty**: Intermediate  
**Prerequisites**: Python 3.x, Flutter SDK, Android/iOS setup

Good luck! 🚀
