import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:maa_yegue/core/database/unified_database_service.dart';
import 'package:maa_yegue/features/authentication/data/services/hybrid_auth_service.dart';
import 'package:maa_yegue/features/guest/data/services/guest_dictionary_service.dart';
import 'package:maa_yegue/features/learner/data/services/student_service.dart';
import 'package:maa_yegue/features/teacher/data/services/teacher_service.dart';
import 'package:maa_yegue/features/admin/data/services/admin_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Hybrid Architecture Integration Tests', () {
    late UnifiedDatabaseService db;

    setUp(() async {
      db = UnifiedDatabaseService.instance;
      await db.deleteDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    test('Complete user flow: Guest → Student → Premium Student', () async {
      // 1. Guest user accesses dictionary
      final languages = await GuestDictionaryService.getAvailableLanguages();
      expect(languages, isNotEmpty);
      expect(languages.length, greaterThanOrEqualTo(7)); // 7 Cameroon languages

      // 2. Guest accesses limited lessons
      final guestLessons = await GuestDictionaryService.getDemoLessons(
        limit: 3,
      );
      expect(guestLessons.length, lessThanOrEqualTo(3));

      // 3. User signs up (simulated - Firebase auth would be here)
      final userId = 'integration-student-1';
      await db.upsertUser({
        'user_id': userId,
        'firebase_uid': userId,
        'email': 'integration@test.com',
        'display_name': 'Integration Student',
        'role': 'student',
        'subscription_status': 'free',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.upsertUserStatistics(userId, {
        'total_lessons_completed': 0,
        'experience_points': 0,
      });

      // 4. Free student has limited access
      final hasSubscription = await StudentService.hasActiveSubscription(
        userId,
      );
      expect(hasSubscription, isFalse);

      final freeLessons = await StudentService.getAvailableLessons(
        userId: userId,
        languageId: 'EWO',
      );
      expect(freeLessons.length, lessThanOrEqualTo(3));

      // 5. Student upgrades to premium
      await HybridAuthService.updateSubscriptionStatus(
        userId: userId,
        status: 'premium',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      // 6. Premium student has full access
      final hasSubscriptionAfterUpgrade =
          await StudentService.hasActiveSubscription(userId);
      expect(hasSubscriptionAfterUpgrade, isTrue);
    });

    test('Complete teacher flow: Create and publish content', () async {
      // 1. Create teacher
      final teacherId = 'integration-teacher-1';
      await db.upsertUser({
        'user_id': teacherId,
        'firebase_uid': teacherId,
        'email': 'teacher@test.com',
        'display_name': 'Integration Teacher',
        'role': 'teacher',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // 2. Teacher creates a lesson
      final lessonResult = await TeacherService.createLesson(
        teacherId: teacherId,
        languageId: 'YMB',
        title: 'Yemba Greetings',
        content: 'Learn basic Yemba greetings',
        level: 'beginner',
        status: 'draft',
      );

      expect(lessonResult['success'], isTrue);
      final lessonId = lessonResult['lesson_id'] as int;

      // 3. Teacher creates a quiz
      final quizResult = await TeacherService.createQuiz(
        teacherId: teacherId,
        languageId: 'YMB',
        title: 'Yemba Quiz 1',
        difficultyLevel: 'beginner',
      );

      expect(quizResult['success'], isTrue);
      final quizId = quizResult['quiz_id'] as int;

      // 4. Teacher adds questions to quiz
      await TeacherService.addQuizQuestion(
        quizId: quizId,
        questionText: 'What is "Hello" in Yemba?',
        questionType: 'multiple_choice',
        correctAnswer: 'Ndɛ',
        options: ['Ndɛ', 'Mbolo', 'Kweni', 'Jam waali'],
      );

      // 5. Teacher publishes content
      final publishResult = await TeacherService.publishContent(
        contentId: lessonId,
      );

      expect(publishResult['success'], isTrue);

      // 6. Verify published content appears
      final publishedContent = await TeacherService.getCreatedContent(
        teacherId: teacherId,
        status: 'published',
      );

      expect(publishedContent.length, equals(1));
    });

    test('Complete admin flow: Manage users and content', () async {
      // 1. Create admin
      final adminId = 'integration-admin-1';
      await db.upsertUser({
        'user_id': adminId,
        'firebase_uid': adminId,
        'email': 'admin@test.com',
        'display_name': 'Integration Admin',
        'role': 'admin',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // 2. Create multiple users
      for (int i = 0; i < 10; i++) {
        await db.upsertUser({
          'user_id': 'managed-user-$i',
          'firebase_uid': 'managed-user-$i',
          'email': 'user$i@test.com',
          'display_name': 'User $i',
          'role': i < 7 ? 'student' : 'teacher',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });

        if (i < 7) {
          await db.upsertUserStatistics('managed-user-$i', {
            'total_lessons_completed': i,
            'experience_points': i * 100,
          });
        }
      }

      // 3. Admin views all users
      final allUsers = await AdminService.getAllUsers();
      expect(allUsers.length, greaterThanOrEqualTo(11)); // 10 + 1 admin

      // 4. Admin views students only
      final students = await AdminService.getAllStudents();
      expect(students.length, equals(7));

      // 5. Admin changes a user's role
      final roleChangeResult = await AdminService.updateUserRole(
        userId: 'managed-user-0',
        newRole: 'teacher',
      );

      expect(roleChangeResult['success'], isTrue);

      // 6. Admin views platform statistics
      final platformStats = await AdminService.getPlatformStatistics();
      expect(platformStats['total_users'], greaterThanOrEqualTo(11));
      expect(
        platformStats['total_students'],
        greaterThanOrEqualTo(6),
      ); // One promoted to teacher

      // 7. Admin gets top students
      final topStudents = await AdminService.getTopStudents(limit: 5);
      expect(topStudents.length, lessThanOrEqualTo(5));
    });

    test(
      'Full learning session: Student completes lesson with progress tracking',
      () async {
        // 1. Create student
        final userId = 'learning-student-1';
        await db.upsertUser({
          'user_id': userId,
          'firebase_uid': userId,
          'email': 'learner@test.com',
          'display_name': 'Learning Student',
          'role': 'student',
          'subscription_status': 'premium',
          'subscription_expires_at': DateTime.now()
              .add(const Duration(days: 30))
              .millisecondsSinceEpoch,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });

        await db.upsertUserStatistics(userId, {
          'total_lessons_completed': 0,
          'total_study_time': 0,
          'experience_points': 0,
          'current_streak': 0,
        });

        // 2. Student starts lesson
        await db.saveProgress(
          userId: userId,
          contentType: 'lesson',
          contentId: 1,
          status: 'started',
        );

        // 3. Student makes progress
        await db.saveProgress(
          userId: userId,
          contentType: 'lesson',
          contentId: 1,
          status: 'in_progress',
          timeSpent: 180, // 3 minutes
        );

        // 4. Student completes lesson
        await StudentService.saveLessonProgress(
          userId: userId,
          lessonId: 1,
          status: 'completed',
          timeSpent: 300, // 5 minutes total
          score: 92.0,
        );

        // 5. Verify progress
        final progress = await db.getProgress(
          userId: userId,
          contentType: 'lesson',
          contentId: 1,
        );

        expect(progress?['status'], equals('completed'));
        expect(progress?['score'], equals(92.0));

        // 6. Verify statistics updated
        final stats = await db.getUserStatistics(userId);
        expect(stats?['total_lessons_completed'], equals(1));
        expect(stats?['total_study_time'], greaterThan(0));

        // 7. Update streak
        await StudentService.updateStreak(userId);
        final updatedStats = await db.getUserStatistics(userId);
        expect(updatedStats?['current_streak'], equals(1));
      },
    );

    test(
      'Multi-role interaction: Teacher creates, Student uses, Admin manages',
      () async {
        // 1. Create teacher
        final teacherId = 'multi-teacher';
        await db.upsertUser({
          'user_id': teacherId,
          'firebase_uid': teacherId,
          'email': 'multiteacher@test.com',
          'display_name': 'Multi Teacher',
          'role': 'teacher',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });

        // 2. Teacher creates content
        final lessonResult = await TeacherService.createLesson(
          teacherId: teacherId,
          languageId: 'BAM',
          title: 'Bamum Writing System',
          content: 'Learn about the Bamum script',
          level: 'advanced',
          status: 'published',
        );

        final lessonId = lessonResult['lesson_id'] as int;

        // 3. Create student
        final studentId = 'multi-student';
        await db.upsertUser({
          'user_id': studentId,
          'firebase_uid': studentId,
          'email': 'multistudent@test.com',
          'display_name': 'Multi Student',
          'role': 'student',
          'subscription_status': 'premium',
          'subscription_expires_at': DateTime.now()
              .add(const Duration(days: 30))
              .millisecondsSinceEpoch,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });

        await db.upsertUserStatistics(studentId, {});

        // 4. Student accesses teacher's lesson
        await StudentService.saveLessonProgress(
          userId: studentId,
          lessonId: lessonId,
          status: 'completed',
          score: 88.0,
        );

        // 5. Create admin
        final adminId = 'multi-admin';
        await db.upsertUser({
          'user_id': adminId,
          'firebase_uid': adminId,
          'email': 'multiadmin@test.com',
          'display_name': 'Multi Admin',
          'role': 'admin',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });

        // 6. Admin reviews teacher's content
        final allContent = await AdminService.getAllUserCreatedContent();
        expect(allContent.length, greaterThan(0));

        // 7. Admin views student progress
        final studentDetails = await AdminService.getUserDetails(studentId);
        expect(studentDetails, isNotNull);
        expect(studentDetails?['progress_count'], greaterThan(0));

        // 8. Admin views platform statistics
        final platformStats = await AdminService.getPlatformStatistics();
        expect(platformStats['total_users'], greaterThanOrEqualTo(3));
        expect(
          platformStats['total_lessons_completed'],
          greaterThanOrEqualTo(1),
        );
      },
    );

    test('Database performance with large dataset', () async {
      // Create many users
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        await db.upsertUser({
          'user_id': 'perf-user-$i',
          'firebase_uid': 'perf-user-$i',
          'email': 'perf$i@test.com',
          'display_name': 'Performance User $i',
          'role': i % 3 == 0 ? 'teacher' : 'student',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      stopwatch.stop();
      final insertTime = stopwatch.elapsedMilliseconds;
      print('✅ Inserted 100 users in ${insertTime}ms');

      // Query performance
      stopwatch.reset();
      stopwatch.start();

      final allUsers = await AdminService.getAllUsers();
      expect(allUsers.length, greaterThanOrEqualTo(100));

      stopwatch.stop();
      final queryTime = stopwatch.elapsedMilliseconds;
      print('✅ Queried 100+ users in ${queryTime}ms');

      // Ensure reasonable performance
      expect(insertTime, lessThan(10000)); // Should insert in < 10s
      expect(queryTime, lessThan(1000)); // Should query in < 1s
    });
  });
}
