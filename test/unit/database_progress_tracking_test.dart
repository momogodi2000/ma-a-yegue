import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:maa_yegue/core/database/database_helper.dart';
import 'package:maa_yegue/features/lessons/data/services/progress_tracking_service.dart';

/// Test database migration and progress tracking
void main() {
  setUpAll(() {
    // Initialize FFI for desktop testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Migration Tests', () {
    test('Database should initialize at version 3', () async {
      final db = await DatabaseHelper.database;
      final version = await db.getVersion();
      
      expect(version, 3);
      print('✅ Database version: $version');
    });

    test('All v3 tables should exist', () async {
      final tables = [
        'user_levels',
        'learning_progress',
        'lesson_progress',
        'milestones',
        'skill_progress',
      ];

      for (var tableName in tables) {
        final exists = await DatabaseHelper.tableExists(tableName);
        expect(exists, true, reason: 'Table $tableName should exist');
        print('✅ Table exists: $tableName');
      }
    });

    test('Database info should return counts', () async {
      final info = await DatabaseHelper.getDatabaseInfo();
      
      expect(info, isNotNull);
      expect(info.containsKey('userLevels'), true);
      expect(info.containsKey('learningProgress'), true);
      
      print('📊 Database Info:');
      info.forEach((key, value) {
        print('  $key: $value');
      });
    });
  });

  group('Progress Tracking Service Tests', () {
    final service = ProgressTrackingService();
    final testUserId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
    const testLanguage = 'yemba';
    const testLessonId = 'lesson_test_01';

    test('Start lesson should create progress record', () async {
      await service.startLesson(
        userId: testUserId,
        languageCode: testLanguage,
        lessonId: testLessonId,
      );

      final progress = await service.getLessonProgress(
        userId: testUserId,
        languageCode: testLanguage,
        lessonId: testLessonId,
      );

      expect(progress, isNotNull);
      expect(progress!['status'], 'in_progress');
      expect(progress['progress_percentage'], 0);
      expect(progress['attempts_count'], 1);
      
      print('✅ Lesson started successfully');
      print('   Progress: ${progress['progress_percentage']}%');
      print('   Status: ${progress['status']}');
    });

    test('Update lesson progress should modify values', () async {
      await service.updateLessonProgress(
        userId: testUserId,
        languageCode: testLanguage,
        lessonId: testLessonId,
        progressPercentage: 50,
        timeSpentSeconds: 300,
        currentScore: 75,
      );

      final progress = await service.getLessonProgress(
        userId: testUserId,
        languageCode: testLanguage,
        lessonId: testLessonId,
      );

      expect(progress!['progress_percentage'], 50);
      expect(progress['time_spent_seconds'], 300);
      expect(progress['last_score'], 75);
      
      print('✅ Progress updated successfully');
      print('   Progress: ${progress['progress_percentage']}%');
      print('   Time spent: ${progress['time_spent_seconds']}s');
      print('   Score: ${progress['last_score']}');
    });

    test('Complete lesson should mark as completed', () async {
      await service.completeLesson(
        userId: testUserId,
        languageCode: testLanguage,
        lessonId: testLessonId,
        finalScore: 85,
        totalTimeSpent: 600,
      );

      final progress = await service.getLessonProgress(
        userId: testUserId,
        languageCode: testLanguage,
        lessonId: testLessonId,
      );

      expect(progress!['status'], 'completed');
      expect(progress['progress_percentage'], 100);
      expect(progress['last_score'], 85);
      expect(progress['best_score'], 85);
      
      print('✅ Lesson completed successfully');
      print('   Status: ${progress['status']}');
      print('   Final Score: ${progress['last_score']}');
      print('   Best Score: ${progress['best_score']}');
    });

    test('Update skill progress should track proficiency', () async {
      await service.updateSkillProgress(
        userId: testUserId,
        languageCode: testLanguage,
        skillName: 'vocabulary',
        proficiencyScore: 80,
      );

      final skill = await service.getSkillProgress(
        userId: testUserId,
        languageCode: testLanguage,
        skillName: 'vocabulary',
      );

      expect(skill, isNotNull);
      expect(skill!['skill_name'], 'vocabulary');
      expect(skill['proficiency_score'], 80);
      expect(skill['practice_count'], 1);
      
      print('✅ Skill progress tracked');
      print('   Skill: ${skill['skill_name']}');
      print('   Proficiency: ${skill['proficiency_score']}/100');
      print('   Practice count: ${skill['practice_count']}');
    });

    test('Record milestone should create achievement', () async {
      await service.recordMilestone(
        userId: testUserId,
        languageCode: testLanguage,
        milestoneType: 'first_lesson',
        milestoneTitle: 'First Steps',
        description: 'Completed your first lesson!',
      );

      final milestones = await service.getMilestones(
        userId: testUserId,
        languageCode: testLanguage,
      );

      expect(milestones.isNotEmpty, true);
      expect(milestones.first['milestone_type'], 'first_lesson');
      expect(milestones.first['title'], 'First Steps');
      
      print('✅ Milestone recorded');
      print('   Type: ${milestones.first['milestone_type']}');
      print('   Title: ${milestones.first['title']}');
    });

    test('Get overall statistics should calculate correctly', () async {
      final stats = await service.getOverallStatistics(
        userId: testUserId,
        languageCode: testLanguage,
      );

      expect(stats['completedLessons'], greaterThan(0));
      expect(stats['totalTimeSpentSeconds'], greaterThan(0));
      expect(stats['currentStreak'], greaterThanOrEqualTo(0));
      
      print('✅ Overall statistics calculated');
      print('   Completed Lessons: ${stats['completedLessons']}');
      print('   Total Time: ${stats['totalTimeSpentMinutes']} minutes');
      print('   Average Score: ${stats['averageScore']}%');
      print('   Current Streak: ${stats['currentStreak']} days');
      print('   Milestones: ${stats['milestonesEarned']}');
    });

    test('Get all lesson progress should return all lessons', () async {
      final allProgress = await service.getAllLessonProgress(
        userId: testUserId,
        languageCode: testLanguage,
      );

      expect(allProgress, isNotEmpty);
      expect(allProgress.length, greaterThan(0));
      
      print('✅ Retrieved all lesson progress');
      print('   Total lessons: ${allProgress.length}');
    });

    test('Get all skills progress should return all skills', () async {
      final allSkills = await service.getAllSkillsProgress(
        userId: testUserId,
        languageCode: testLanguage,
      );

      expect(allSkills, isNotEmpty);
      
      print('✅ Retrieved all skills');
      print('   Total skills: ${allSkills.length}');
      for (var skill in allSkills) {
        print('   - ${skill['skill_name']}: ${skill['proficiency_score']}/100');
      }
    });
  });

  tearDownAll(() async {
    // Clean up test data
    await DatabaseHelper.close();
    print('\n🧹 Test cleanup complete');
  });
}
