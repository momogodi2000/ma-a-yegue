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

  group('UnifiedDatabaseService Tests', () {
    late UnifiedDatabaseService db;

    setUp(() async {
      db = UnifiedDatabaseService.instance;
      await db.deleteDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    test('Database initializes successfully', () async {
      final database = await db.database;
      expect(database, isNotNull);
      expect(database.isOpen, isTrue);
    });

    test('Metadata is set and retrieved correctly', () async {
      await db.setMetadata('test_key', 'test_value');
      final value = await db.getMetadata('test_key');
      expect(value, equals('test_value'));
    });

    test('User CRUD operations work correctly', () async {
      final userId = 'crud-test-user';
      final now = DateTime.now().millisecondsSinceEpoch;

      // Create
      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': 'crud@test.com',
        'display_name': 'CRUD Test',
        'role': 'student',
        'created_at': now,
        'updated_at': now,
      });

      // Read
      final user = await db.getUserById(userId);
      expect(user, isNotNull);
      expect(user?['email'], equals('crud@test.com'));

      // Update
      await db.upsertUser({
        'user_id': userId,
        'display_name': 'Updated Name',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      final updatedUser = await db.getUserById(userId);
      expect(updatedUser?['display_name'], equals('Updated Name'));
    });

    test('User statistics operations work correctly', () async {
      final userId = 'stats-test-user';

      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': 'stats@test.com',
        'display_name': 'Stats Test',
        'role': 'student',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Create statistics
      await db.upsertUserStatistics(userId, {
        'total_lessons_completed': 5,
        'experience_points': 500,
      });

      // Increment
      await db.incrementStatistic(
        userId,
        'total_lessons_completed',
        incrementBy: 3,
      );
      await db.incrementStatistic(
        userId,
        'experience_points',
        incrementBy: 200,
      );

      // Verify
      final stats = await db.getUserStatistics(userId);
      expect(stats?['total_lessons_completed'], equals(8));
      expect(stats?['experience_points'], equals(700));
    });

    test('Progress tracking works correctly', () async {
      final userId = 'progress-test-user';

      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': 'progress@test.com',
        'display_name': 'Progress Test',
        'role': 'student',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Save progress
      await db.saveProgress(
        userId: userId,
        contentType: 'lesson',
        contentId: 1,
        status: 'in_progress',
        timeSpent: 60,
      );

      // Get progress
      final progress = await db.getProgress(
        userId: userId,
        contentType: 'lesson',
        contentId: 1,
      );

      expect(progress, isNotNull);
      expect(progress?['status'], equals('in_progress'));
      expect(progress?['time_spent'], equals(60));

      // Update progress to completed
      await db.saveProgress(
        userId: userId,
        contentType: 'lesson',
        contentId: 1,
        status: 'completed',
        score: 95.0,
        timeSpent: 120,
      );

      final completedProgress = await db.getProgress(
        userId: userId,
        contentType: 'lesson',
        contentId: 1,
      );

      expect(completedProgress?['status'], equals('completed'));
      expect(completedProgress?['score'], equals(95.0));
      expect(completedProgress?['attempts'], greaterThan(1));
    });

    test('Favorites operations work correctly', () async {
      final userId = 'fav-test-user';

      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': 'fav@test.com',
        'display_name': 'Fav Test',
        'role': 'student',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Add favorites
      await db.addFavorite(userId: userId, contentType: 'lesson', contentId: 1);

      await db.addFavorite(userId: userId, contentType: 'quiz', contentId: 2);

      // Get all favorites
      final allFavorites = await db.getUserFavorites(userId);
      expect(allFavorites.length, equals(2));

      // Get favorites by type
      final lessonFavorites = await db.getUserFavorites(
        userId,
        contentType: 'lesson',
      );
      expect(lessonFavorites.length, equals(1));

      // Check if favorited
      final isFav = await db.isFavorite(
        userId: userId,
        contentType: 'lesson',
        contentId: 1,
      );
      expect(isFav, isTrue);

      // Remove favorite
      await db.removeFavorite(
        userId: userId,
        contentType: 'lesson',
        contentId: 1,
      );

      final isFavAfterRemove = await db.isFavorite(
        userId: userId,
        contentType: 'lesson',
        contentId: 1,
      );
      expect(isFavAfterRemove, isFalse);
    });

    test('Platform statistics are calculated correctly', () async {
      // Create test data
      for (int i = 0; i < 20; i++) {
        final userId = 'platform-user-$i';
        await db.upsertUser({
          'user_id': userId,
          'firebase_uid': userId,
          'email': 'platform$i@test.com',
          'display_name': 'Platform User $i',
          'role': i < 15 ? 'student' : 'teacher',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });

        if (i < 15) {
          await db.upsertUserStatistics(userId, {
            'total_lessons_completed': i + 1,
            'total_quizzes_completed': i,
            'total_words_learned': i * 10,
          });
        }
      }

      final stats = await db.getPlatformStatistics();

      expect(stats['total_users'], greaterThanOrEqualTo(20));
      expect(stats['total_students'], greaterThanOrEqualTo(15));
      expect(stats['total_teachers'], greaterThanOrEqualTo(5));
      expect(stats['total_lessons_completed'], greaterThan(0));
      expect(stats['total_quizzes_completed'], greaterThan(0));
      expect(stats['total_words_learned'], greaterThan(0));
    });
  });
}
