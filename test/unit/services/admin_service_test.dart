import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:maa_yegue/features/admin/data/services/admin_service.dart';
import 'package:maa_yegue/core/database/unified_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Initialize FFI for SQLite
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AdminService Tests', () {
    late UnifiedDatabaseService db;
    late String adminId;

    setUp(() async {
      db = UnifiedDatabaseService.instance;
      await db.deleteDatabase();

      // Create admin user
      adminId = 'admin-123';
      await db.upsertUser({
        'user_id': adminId,
        'firebase_uid': adminId,
        'email': 'admin@example.com',
        'display_name': 'Test Admin',
        'role': 'admin',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
    });

    tearDown(() async {
      await db.close();
    });

    test('Admin can get all users', () async {
      // Create multiple users
      final roles = ['student', 'teacher', 'student', 'teacher'];
      for (int i = 0; i < roles.length; i++) {
        await db.upsertUser({
          'user_id': 'user-$i',
          'firebase_uid': 'user-$i',
          'email': 'user$i@example.com',
          'display_name': 'User $i',
          'role': roles[i],
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      // Get all users
      final allUsers = await AdminService.getAllUsers();
      expect(allUsers.length, greaterThanOrEqualTo(5)); // 4 + 1 admin

      // Get only students
      final students = await AdminService.getUsersByRole('student');
      expect(students.length, equals(2));

      // Get only teachers
      final teachers = await AdminService.getUsersByRole('teacher');
      expect(teachers.length, equals(2));
    });

    test('Admin can change user role', () async {
      final userId = 'user-role-change';

      // Create student
      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': 'rolechange@example.com',
        'display_name': 'Role Change User',
        'role': 'student',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Change role to teacher
      final result = await AdminService.updateUserRole(
        userId: userId,
        newRole: 'teacher',
      );

      expect(result['success'], isTrue);

      // Verify role was changed
      final user = await db.getUserById(userId);
      expect(user?['role'], equals('teacher'));
    });

    test('Admin can get platform statistics', () async {
      // Create some test data
      for (int i = 0; i < 10; i++) {
        await db.upsertUser({
          'user_id': 'stats-user-$i',
          'firebase_uid': 'stats-user-$i',
          'email': 'stats$i@example.com',
          'display_name': 'Stats User $i',
          'role': i < 5 ? 'student' : 'teacher',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });

        if (i < 5) {
          await db.upsertUserStatistics('stats-user-$i', {
            'total_lessons_completed': i * 2,
            'total_quizzes_completed': i * 3,
            'total_words_learned': i * 10,
          });
        }
      }

      // Get platform statistics
      final stats = await AdminService.getPlatformStatistics();

      expect(stats['total_users'], greaterThanOrEqualTo(10));
      expect(stats['total_students'], greaterThanOrEqualTo(5));
      expect(stats['total_teachers'], greaterThanOrEqualTo(5));
    });

    test('Admin can get user details with full information', () async {
      final userId = 'detailed-user';

      // Create user
      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': 'detailed@example.com',
        'display_name': 'Detailed User',
        'role': 'student',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Add statistics
      await db.upsertUserStatistics(userId, {
        'total_lessons_completed': 10,
        'experience_points': 1000,
      });

      // Add progress
      await db.saveProgress(
        userId: userId,
        contentType: 'lesson',
        contentId: 1,
        status: 'completed',
      );

      // Add favorite
      await db.addFavorite(userId: userId, contentType: 'lesson', contentId: 2);

      // Get details
      final details = await AdminService.getUserDetails(userId);

      expect(details, isNotNull);
      expect(details?['user_id'], equals(userId));
      expect(details?['statistics'], isNotNull);
      expect(details?['progress_count'], greaterThan(0));
      expect(details?['favorites_count'], greaterThan(0));
    });

    test('Admin can manage user-created content', () async {
      final teacherId = 'content-teacher';

      // Create teacher
      await db.upsertUser({
        'user_id': teacherId,
        'firebase_uid': teacherId,
        'email': 'contentteacher@example.com',
        'display_name': 'Content Teacher',
        'role': 'teacher',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Create some content
      final lessonId = await db.createLesson({
        'creator_id': teacherId,
        'language_id': 'YMB',
        'title': 'Admin Test Lesson',
        'content': 'Content',
        'level': 'beginner',
        'status': 'draft',
      });

      // Admin retrieves all content
      final allContent = await AdminService.getAllUserCreatedContent();
      expect(allContent.length, greaterThan(0));

      // Admin approves content
      final approveResult = await AdminService.approveContent(
        contentId: lessonId,
      );
      expect(approveResult['success'], isTrue);

      // Verify it's published
      final publishedContent = await AdminService.getAllUserCreatedContent(
        status: 'published',
      );
      expect(publishedContent.length, equals(1));
    });

    test('Admin can get top students', () async {
      // Create students with different XP
      for (int i = 0; i < 5; i++) {
        final userId = 'top-student-$i';
        await db.upsertUser({
          'user_id': userId,
          'firebase_uid': userId,
          'email': 'topstudent$i@example.com',
          'display_name': 'Top Student $i',
          'role': 'student',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });

        await db.upsertUserStatistics(userId, {
          'experience_points': (5 - i) * 1000, // Descending XP
          'level': 5 - i,
        });
      }

      // Get top students
      final topStudents = await AdminService.getTopStudents(limit: 3);

      expect(topStudents.length, equals(3));
      // Should be sorted by XP descending
      expect(
        topStudents[0]['total_xp'],
        greaterThan(topStudents[1]['total_xp']),
      );
      expect(
        topStudents[1]['total_xp'],
        greaterThan(topStudents[2]['total_xp']),
      );
    });

    test('Admin validation rejects invalid roles', () async {
      final result = await AdminService.updateUserRole(
        userId: 'some-user',
        newRole: 'invalid_role',
      );

      expect(result['success'], isFalse);
      expect(result['error'], contains('invalide'));
    });
  });
}
