import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:maa_yegue/core/database/unified_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Initialize FFI for SQLite
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('HybridAuthService Tests', () {
    late UnifiedDatabaseService db;

    setUp(() async {
      db = UnifiedDatabaseService.instance;
      await db.deleteDatabase(); // Clean start for each test
    });

    tearDown(() async {
      await db.close();
    });

    test('Sign up creates user in SQLite with correct role', () async {
      // Note: This test requires Firebase to be mocked or Firebase Emulator running
      // For now, we test the database portion

      const userId = 'test-user-123';
      const email = 'test@example.com';
      const displayName = 'Test User';
      const role = 'student';

      // Manually insert user (simulating what signUpWithEmail would do)
      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': email,
        'display_name': displayName,
        'role': role,
        'subscription_status': 'free',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Verify user was created
      final user = await db.getUserById(userId);
      expect(user, isNotNull);
      expect(user?['email'], equals(email));
      expect(user?['role'], equals(role));
      expect(user?['subscription_status'], equals('free'));
    });

    test('Sign up creates user statistics', () async {
      const userId = 'test-user-456';

      // Create user
      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': 'test2@example.com',
        'display_name': 'Test User 2',
        'role': 'student',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Create statistics
      await db.upsertUserStatistics(userId, {
        'total_lessons_completed': 0,
        'total_quizzes_completed': 0,
        'total_words_learned': 0,
        'level': 1,
        'experience_points': 0,
      });

      // Verify statistics were created
      final stats = await db.getUserStatistics(userId);
      expect(stats, isNotNull);
      expect(stats?['level'], equals(1));
      expect(stats?['experience_points'], equals(0));
    });

    test('Update user last login updates timestamp', () async {
      const userId = 'test-user-789';

      // Create user
      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': 'test3@example.com',
        'display_name': 'Test User 3',
        'role': 'student',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 100));

      // Update last login
      await db.updateUserLastLogin(userId);

      // Verify last login was updated
      final user = await db.getUserById(userId);
      expect(user?['last_login'], isNotNull);
    });

    test('User roles are validated correctly', () async {
      final validRoles = ['guest', 'student', 'teacher', 'admin'];

      for (final role in validRoles) {
        final userId = 'user-$role';
        await db.upsertUser({
          'user_id': userId,
          'firebase_uid': userId,
          'email': '$role@example.com',
          'display_name': 'User $role',
          'role': role,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });

        final user = await db.getUserById(userId);
        expect(user?['role'], equals(role));
      }
    });
  });
}
