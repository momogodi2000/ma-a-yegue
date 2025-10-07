import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:maa_yegue/features/learner/data/services/student_service.dart';
import 'package:maa_yegue/core/database/unified_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Initialize FFI for SQLite
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('StudentService Tests', () {
    late UnifiedDatabaseService db;

    setUp(() async {
      db = UnifiedDatabaseService.instance;
      await db.deleteDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    test('Student without subscription has limited access', () async {
      const userId = 'student-1';

      // Create student with free subscription
      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': 'student@example.com',
        'display_name': 'Test Student',
        'role': 'student',
        'subscription_status': 'free',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Check subscription
      final hasSubscription = await StudentService.hasActiveSubscription(
        userId,
      );
      expect(hasSubscription, isFalse);
    });

    test('Student with active subscription has full access', () async {
      const userId = 'student-2';
      final expiresAt = DateTime.now().add(const Duration(days: 30));

      // Create student with active subscription
      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': 'premium@example.com',
        'display_name': 'Premium Student',
        'role': 'student',
        'subscription_status': 'premium',
        'subscription_expires_at': expiresAt.millisecondsSinceEpoch,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Check subscription
      final hasSubscription = await StudentService.hasActiveSubscription(
        userId,
      );
      expect(hasSubscription, isTrue);
    });

    test('Student progress is saved correctly', () async {
      const userId = 'student-3';

      // Create student
      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': 'progress@example.com',
        'display_name': 'Progress Student',
        'role': 'student',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Create stats
      await db.upsertUserStatistics(userId, {
        'total_lessons_completed': 0,
        'total_quizzes_completed': 0,
        'experience_points': 0,
      });

      // Save lesson progress
      await StudentService.saveLessonProgress(
        userId: userId,
        lessonId: 1,
        status: 'completed',
        timeSpent: 300, // 5 minutes
        score: 85.0,
      );

      // Verify progress was saved
      final progress = await db.getProgress(
        userId: userId,
        contentType: 'lesson',
        contentId: 1,
      );

      expect(progress, isNotNull);
      expect(progress?['status'], equals('completed'));
      expect(progress?['score'], equals(85.0));

      // Verify statistics were updated
      final stats = await db.getUserStatistics(userId);
      expect(stats?['total_lessons_completed'], equals(1));
    });

    test('Quiz results update statistics and XP', () async {
      final userId = 'student-4';

      // Create student
      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': 'quiz@example.com',
        'display_name': 'Quiz Student',
        'role': 'student',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Create stats
      await db.upsertUserStatistics(userId, {
        'total_quizzes_completed': 0,
        'experience_points': 0,
      });

      // Save quiz results
      await StudentService.saveQuizResults(
        userId: userId,
        quizId: 1,
        score: 90.0,
        timeSpent: 120,
      );

      // Verify statistics
      final stats = await db.getUserStatistics(userId);
      expect(stats?['total_quizzes_completed'], equals(1));

      // XP should be score * 10 = 900
      expect(stats?['experience_points'], equals(900));
    });

    test('Favorites can be added and removed', () async {
      final userId = 'student-5';

      // Create student
      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': 'fav@example.com',
        'display_name': 'Favorite Student',
        'role': 'student',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Add to favorites
      await StudentService.addToFavorites(
        userId: userId,
        contentType: 'lesson',
        contentId: 1,
      );

      // Check if favorited
      final isFav = await StudentService.isFavorite(
        userId: userId,
        contentType: 'lesson',
        contentId: 1,
      );
      expect(isFav, isTrue);

      // Remove from favorites
      await StudentService.removeFromFavorites(
        userId: userId,
        contentType: 'lesson',
        contentId: 1,
      );

      // Check again
      final isFavAfterRemove = await StudentService.isFavorite(
        userId: userId,
        contentType: 'lesson',
        contentId: 1,
      );
      expect(isFavAfterRemove, isFalse);
    });

    test('Student streak is tracked correctly', () async {
      const userId = 'student-6';
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Create student
      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': 'streak@example.com',
        'display_name': 'Streak Student',
        'role': 'student',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Create stats
      await db.upsertUserStatistics(userId, {
        'current_streak': 0,
        'longest_streak': 0,
        'last_activity_date': null,
      });

      // Update streak
      await StudentService.updateStreak(userId);

      // Verify streak
      final stats = await db.getUserStatistics(userId);
      expect(stats?['current_streak'], equals(1));
      expect(stats?['longest_streak'], equals(1));
      expect(stats?['last_activity_date'], equals(today));
    });
  });
}
