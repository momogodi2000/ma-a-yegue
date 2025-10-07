# 🧪 Hybrid Architecture Testing Guide
### Ma'a yegue - Comprehensive Testing Strategy

## 📋 Overview

This guide provides a complete testing strategy for the Ma'a yegue hybrid architecture (SQLite + Firebase). It covers unit tests, integration tests, widget tests, and end-to-end tests.

---

## 🎯 Testing Philosophy

### Hybrid Architecture Testing Principles:

1. **SQLite Data Layer**: Test all database operations (CRUD, queries, migrations)
2. **Firebase Services Layer**: Test service integrations (auth, analytics, crashlytics)
3. **Hybrid Interactions**: Test the coordination between SQLite and Firebase
4. **User Flows**: Test complete user journeys across all 4 user types

---

## 📁 Test Structure

```
test/
├── core/
│   ├── database/
│   │   ├── unified_database_service_test.dart
│   │   ├── data_seeding_service_test.dart
│   │   └── database_initialization_service_test.dart
│   ├── services/
│   │   ├── hybrid_auth_service_test.dart
│   │   ├── firebase_service_test.dart
│   │   ├── admin_setup_service_test.dart
│   │   ├── two_factor_auth_service_test.dart
│   │   └── user_role_service_test.dart
│   └── utils/
│       ├── security_utils_test.dart
│       └── validators_test.dart
├── features/
│   ├── guest/
│   │   ├── guest_dictionary_service_test.dart
│   │   ├── guest_limit_service_test.dart
│   │   └── guest_dashboard_viewmodel_test.dart
│   ├── learner/
│   │   ├── student_service_test.dart
│   │   └── learner_viewmodel_test.dart
│   ├── teacher/
│   │   ├── teacher_service_test.dart
│   │   └── teacher_viewmodel_test.dart
│   └── admin/
│       ├── admin_service_test.dart
│       └── admin_dashboard_viewmodel_test.dart
├── integration/
│   ├── auth_flow_test.dart
│   ├── guest_to_student_flow_test.dart
│   ├── teacher_content_creation_test.dart
│   └── admin_management_test.dart
└── widget/
    ├── login_view_test.dart
    ├── guest_dashboard_test.dart
    └── student_dashboard_test.dart
```

---

## 🔧 Test Setup

### 1. Dependencies

Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  sqflite_common_ffi: ^2.3.0  # For SQLite testing
  firebase_core_platform_interface: ^5.0.0
  fake_cloud_firestore: ^2.5.0  # For Firebase testing
  integration_test:
    sdk: flutter
```

### 2. Test Configuration

Create `test/test_config.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Initialize test environment
void initializeTestEnvironment() {
  // Initialize SQLite for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Set test mode
  TestWidgetsFlutterBinding.ensureInitialized();
}

/// Clean up after tests
Future<void> cleanupTestEnvironment() async {
  // Delete test databases
  await deleteTestDatabases();
}

Future<void> deleteTestDatabases() async {
  // Implementation to delete test databases
}
```

---

## 🧪 Unit Tests

### 1. UnifiedDatabaseService Tests

Create `test/core/database/unified_database_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mayegue/core/database/unified_database_service.dart';
import '../../test_config.dart';

void main() {
  setUpAll(() {
    initializeTestEnvironment();
  });

  tearDownAll(() async {
    await cleanupTestEnvironment();
  });

  group('UnifiedDatabaseService', () {
    late UnifiedDatabaseService dbService;

    setUp(() {
      dbService = UnifiedDatabaseService.instance;
    });

    test('should create database with all tables', () async {
      final db = await dbService.database;
      
      // Verify tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      
      final tableNames = tables.map((t) => t['name']).toList();
      
      expect(tableNames, contains('users'));
      expect(tableNames, contains('daily_limits'));
      expect(tableNames, contains('user_progress'));
      expect(tableNames, contains('user_statistics'));
      expect(tableNames, contains('quizzes'));
      expect(tableNames, contains('quiz_questions'));
      expect(tableNames, contains('user_created_content'));
      expect(tableNames, contains('favorites'));
      expect(tableNames, contains('otp_codes'));
      expect(tableNames, contains('admin_logs'));
      expect(tableNames, contains('app_metadata'));
    });

    test('should create user successfully', () async {
      final userId = await dbService.upsertUser({
        'user_id': 'test_user_1',
        'firebase_uid': 'firebase_test_1',
        'email': 'test@example.com',
        'display_name': 'Test User',
        'role': 'student',
      });

      expect(userId, equals('test_user_1'));

      // Verify user created
      final user = await dbService.getUserById('test_user_1');
      expect(user, isNotNull);
      expect(user?['email'], equals('test@example.com'));
      expect(user?['role'], equals('student'));
    });

    test('should get user by Firebase UID', () async {
      await dbService.upsertUser({
        'user_id': 'test_user_2',
        'firebase_uid': 'firebase_test_2',
        'email': 'test2@example.com',
        'display_name': 'Test User 2',
        'role': 'teacher',
      });

      final user = await dbService.getUserByFirebaseUid('firebase_test_2');
      expect(user, isNotNull);
      expect(user?['role'], equals('teacher'));
    });

    test('should track daily limits for guest users', () async {
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      await dbService.incrementDailyLimit(
        limitType: 'lessons',
        deviceId: 'test_device_1',
      );

      final limits = await dbService.getTodayLimits(deviceId: 'test_device_1');
      expect(limits, isNotNull);
      expect(limits?['lessons_count'], equals(1));
      expect(limits?['limit_date'], equals(today));
    });

    test('should check if user reached daily limit', () async {
      // Insert 5 lessons
      for (int i = 0; i < 5; i++) {
        await dbService.incrementDailyLimit(
          limitType: 'lessons',
          deviceId: 'test_device_2',
        );
      }

      final hasReached = await dbService.hasReachedDailyLimit(
        limitType: 'lessons',
        maxLimit: 5,
        deviceId: 'test_device_2',
      );

      expect(hasReached, isTrue);
    });

    test('should save and retrieve user progress', () async {
      await dbService.saveProgress(
        userId: 'test_user_1',
        contentType: 'lesson',
        contentId: 1,
        status: 'completed',
        score: 85.5,
        timeSpent: 300,
      );

      final progress = await dbService.getProgress(
        userId: 'test_user_1',
        contentType: 'lesson',
        contentId: 1,
      );

      expect(progress, isNotNull);
      expect(progress?['status'], equals('completed'));
      expect(progress?['score'], equals(85.5));
    });

    test('should update user statistics', () async {
      await dbService.upsertUserStatistics('test_user_1', {
        'total_lessons_completed': 10,
        'total_quizzes_completed': 5,
        'total_words_learned': 50,
        'current_streak': 3,
      });

      final stats = await dbService.getUserStatistics('test_user_1');
      expect(stats?['total_lessons_completed'], equals(10));
      expect(stats?['current_streak'], equals(3));
    });

    test('should add and remove favorites', () async {
      await dbService.addFavorite(
        userId: 'test_user_1',
        contentType: 'lesson',
        contentId: 5,
      );

      var isFav = await dbService.isFavorite(
        userId: 'test_user_1',
        contentType: 'lesson',
        contentId: 5,
      );
      expect(isFav, isTrue);

      await dbService.removeFavorite(
        userId: 'test_user_1',
        contentType: 'lesson',
        contentId: 5,
      );

      isFav = await dbService.isFavorite(
        userId: 'test_user_1',
        contentType: 'lesson',
        contentId: 5,
      );
      expect(isFav, isFalse);
    });
  });
}
```

### 2. GuestLimitService Tests

Create `test/features/guest/guest_limit_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mayegue/core/services/guest_limit_service.dart';
import '../../test_config.dart';

void main() {
  setUpAll(() {
    initializeTestEnvironment();
  });

  group('GuestLimitService', () {
    late GuestLimitService guestLimitService;

    setUp(() {
      guestLimitService = GuestLimitService();
    });

    test('should allow guest to access lesson when under limit', () async {
      final canAccess = await guestLimitService.canAccessLesson();
      expect(canAccess, isTrue);
    });

    test('should block guest when daily lesson limit reached', () async {
      // Increment to max (5)
      for (int i = 0; i < 5; i++) {
        await guestLimitService.incrementLessonCount();
      }

      final canAccess = await guestLimitService.canAccessLesson();
      expect(canAccess, isFalse);
    });

    test('should get remaining counts correctly', () async {
      await guestLimitService.incrementLessonCount();
      await guestLimitService.incrementQuizCount();
      await guestLimitService.incrementQuizCount();

      final remaining = await guestLimitService.getRemainingCounts();
      
      expect(remaining['lessons'], equals(4)); // 5 - 1
      expect(remaining['quizzes'], equals(3)); // 5 - 2
      expect(remaining['readings'], equals(5)); // 5 - 0
    });

    test('should check if any limit reached', () async {
      // Use up all lessons
      for (int i = 0; i < 5; i++) {
        await guestLimitService.incrementLessonCount();
      }

      final hasReached = await guestLimitService.hasReachedAnyLimit();
      expect(hasReached, isTrue);
    });
  });
}
```

### 3. SecurityUtils Tests

Create `test/core/utils/security_utils_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mayegue/core/utils/security_utils.dart';

void main() {
  group('SecurityUtils', () {
    test('should validate strong password', () {
      final result = SecurityUtils.validatePasswordStrength('Test@1234');
      expect(result['isStrong'], isTrue);
      expect(result['strength'], equals('strong'));
      expect(result['errors'], isEmpty);
    });

    test('should reject weak password', () {
      final result = SecurityUtils.validatePasswordStrength('weak');
      expect(result['isStrong'], isFalse);
      expect(result['strength'], equals('weak'));
      expect(result['errors'], isNotEmpty);
    });

    test('should sanitize XSS input', () {
      final malicious = '<script>alert("xss")</script>';
      final sanitized = SecurityUtils.sanitizeInput(malicious);
      expect(sanitized, isNot(contains('<script>')));
      expect(sanitized, contains('&lt;script&gt;'));
    });

    test('should detect SQL injection patterns', () {
      final sqlInjection = "'; DROP TABLE users; --";
      final isSafe = SecurityUtils.isSqlInjectionSafe(sqlInjection);
      expect(isSafe, isFalse);
    });

    test('should detect malicious patterns', () {
      final patterns = [
        '<script>alert(1)</script>',
        'javascript:void(0)',
        '<iframe src="evil"></iframe>',
        'data:text/html,<script>alert(1)</script>',
      ];

      for (final pattern in patterns) {
        expect(SecurityUtils.containsMaliciousPatterns(pattern), isTrue);
      }
    });

    test('should generate secure token', () {
      final token1 = SecurityUtils.generateSecureToken();
      final token2 = SecurityUtils.generateSecureToken();
      
      expect(token1.length, equals(32));
      expect(token2.length, equals(32));
      expect(token1, isNot(equals(token2))); // Should be unique
    });

    test('should hash password with salt', () {
      final password = 'MyPassword123';
      final salt = SecurityUtils.generateSalt();
      
      final hash1 = SecurityUtils.hashPassword(password, salt);
      final hash2 = SecurityUtils.hashPassword(password, salt);
      
      expect(hash1, equals(hash2)); // Same password+salt = same hash
      expect(hash1.length, greaterThan(0));
    });
  });
}
```

---

## 🔗 Integration Tests

### 1. Authentication Flow Test

Create `test/integration/auth_flow_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mayegue/features/authentication/data/services/hybrid_auth_service.dart';
import '../test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    setUpAll(() {
      initializeTestEnvironment();
    });

    test('should complete full sign-up flow', () async {
      // Sign up
      final signUpResult = await HybridAuthService.signUpWithEmail(
        email: 'integration_test@example.com',
        password: 'Test@123456',
        displayName: 'Integration Test User',
        role: 'student',
      );

      expect(signUpResult['success'], isTrue);
      expect(signUpResult['role'], equals('student'));

      final userId = signUpResult['user_id'];

      // Verify user created in SQLite
      final user = await HybridAuthService.getCurrentUser();
      expect(user, isNotNull);
      expect(user?['user_id'], equals(userId));
      expect(user?['role'], equals('student'));

      // Verify statistics created
      final stats = await StudentService.getStatistics(userId);
      expect(stats, isNotEmpty);
      expect(stats['total_lessons_completed'], equals(0));
    });

    test('should complete sign-in flow', () async {
      // Sign in
      final signInResult = await HybridAuthService.signInWithEmail(
        email: 'integration_test@example.com',
        password: 'Test@123456',
      );

      expect(signInResult['success'], isTrue);
      expect(signInResult['role'], equals('student'));

      // Verify last_login updated in SQLite
      final user = await HybridAuthService.getCurrentUser();
      expect(user?['last_login'], isNotNull);
    });

    test('should handle password reset', () async {
      final resetResult = await HybridAuthService.sendPasswordResetEmail(
        'integration_test@example.com',
      );

      expect(resetResult['success'], isTrue);
      expect(resetResult['message'], contains('email'));
    });
  });
}
```

### 2. Guest to Student Flow

Create `test/integration/guest_to_student_flow_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mayegue/features/guest/data/services/guest_limit_service.dart';
import 'package:mayegue/features/guest/data/services/guest_dictionary_service.dart';
import 'package:mayegue/features/authentication/data/services/hybrid_auth_service.dart';
import '../test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Guest to Student Flow', () {
    setUpAll(() {
      initializeTestEnvironment();
    });

    test('should allow guest to browse dictionary', () async {
      final languages = await GuestDictionaryService.getAvailableLanguages();
      expect(languages, isNotEmpty);
      expect(languages.length, greaterThanOrEqualTo(7)); // 7 languages

      final words = await GuestDictionaryService.getBasicWords(limit: 10);
      expect(words, isNotEmpty);
      expect(words.length, lessThanOrEqualTo(10));
    });

    test('should enforce guest daily limits', () async {
      final guestService = GuestLimitService();

      // Use up all lesson access
      for (int i = 0; i < 5; i++) {
        expect(await guestService.canAccessLesson(), isTrue);
        await guestService.incrementLessonCount();
      }

      // Should be blocked now
      expect(await guestService.canAccessLesson(), isFalse);
    });

    test('should convert guest to student after sign-up', () async {
      // Sign up
      final signUpResult = await HybridAuthService.signUpWithEmail(
        email: 'guest_convert@example.com',
        password: 'Test@123456',
        displayName: 'Converted Student',
        role: 'student',
      );

      expect(signUpResult['success'], isTrue);

      // As student, should have unlimited lesson access
      final hasSubscription = await StudentService.hasActiveSubscription(
        signUpResult['user_id'],
      );

      // Free user - limited but no daily limits
      final lessons = await StudentService.getAvailableLessons(
        userId: signUpResult['user_id'],
      );
      
      expect(lessons, isNotEmpty);
      // Free students get first 3 lessons per language
      expect(lessons.length, lessThanOrEqualTo(3));
    });
  });
}
```

---

## 🎨 Widget Tests

### Login View Test

Create `test/widget/login_view_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mayegue/features/authentication/presentation/views/login_view.dart';
import 'package:mayegue/features/authentication/presentation/viewmodels/auth_viewmodel.dart';

void main() {
  group('LoginView Widget Tests', () {
    testWidgets('should display all login form fields', (tester) async {
      // Create mock view model
      final authViewModel = AuthViewModel(/* mock dependencies */);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: authViewModel,
            child: LoginView(),
          ),
        ),
      );

      // Verify email field exists
      expect(find.byType(TextField), findsNWidgets(2)); // Email + Password

      // Verify login button exists
      expect(find.text('Se connecter'), findsOneWidget);

      // Verify forgot password link exists
      expect(find.text('Mot de passe oublié?'), findsOneWidget);
    });

    testWidgets('should validate empty email', (tester) async {
      final authViewModel = AuthViewModel(/* mock dependencies */);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: authViewModel,
            child: LoginView(),
          ),
        ),
      );

      // Tap login without entering email
      await tester.tap(find.text('Se connecter'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Email requis'), findsOneWidget);
    });

    testWidgets('should show/hide password', (tester) async {
      final authViewModel = AuthViewModel(/* mock dependencies */);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: authViewModel,
            child: LoginView(),
          ),
        ),
      );

      // Find password field
      final passwordField = find.byKey(Key('password_field'));

      // Initially should be obscured
      TextField passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, isTrue);

      // Tap show/hide icon
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Should now be visible
      passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, isFalse);
    });
  });
}
```

---

## 🏃 Running Tests

### Run All Tests:
```bash
# Run all unit and widget tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run Integration Tests:
```bash
# Run on connected device/emulator
flutter test integration_test/

# Run specific integration test
flutter test integration_test/auth_flow_test.dart
```

### Run Tests in Watch Mode:
```bash
# Install flutter_test_watch
pub global activate flutter_test_watch

# Run in watch mode
flutter_test_watch
```

---

## 📊 Test Coverage Goals

### Target Coverage:
- **Core Database**: 90%+
- **Core Services**: 85%+
- **Feature Services**: 80%+
- **ViewModels**: 75%+
- **Widgets**: 70%+

### Critical Paths (Must be 100%):
- Authentication flow
- Daily limits for guests
- User progress tracking
- Role-based access control
- Payment processing
- Two-factor authentication

---

## ✅ Testing Checklist

### Before Deployment:
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] All widget tests pass
- [ ] Code coverage > 75%
- [ ] No failing lints
- [ ] Manual testing on real devices
- [ ] Performance testing completed
- [ ] Security testing completed

---

**Created**: October 7, 2025
**Status**: Testing guide ready for implementation
**Next**: Implement tests following this guide

*End of Testing Guide*

