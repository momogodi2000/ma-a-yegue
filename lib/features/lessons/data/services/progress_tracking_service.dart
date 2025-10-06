import 'package:sqflite/sqflite.dart';
import 'package:maa_yegue/core/database/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple service for tracking learner progress during lessons
/// Manages lesson_progress, skill_progress, and milestones tables
class ProgressTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Start a new lesson session
  Future<void> startLesson({
    required String userId,
    required String languageCode,
    required String lessonId,
  }) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Check if lesson progress already exists
    final existing = await db.query(
      'lesson_progress',
      where: 'user_id = ? AND language_code = ? AND lesson_id = ?',
      whereArgs: [userId, languageCode, lessonId],
    );

    if (existing.isEmpty) {
      // Create new lesson progress record
      await db.insert('lesson_progress', {
        'id': '${userId}_${languageCode}_${lessonId}_$now',
        'user_id': userId,
        'language_code': languageCode,
        'lesson_id': lessonId,
        'status': 'in_progress',
        'progress_percentage': 0,
        'time_spent_seconds': 0,
        'attempts_count': 1,
        'last_score': 0,
        'best_score': 0,
        'started_at': now,
        'last_accessed': now,
        'completed_at': null,
        'created_at': now,
        'updated_at': now,
      });

      print('✅ Lesson $lessonId started for user $userId');
    } else {
      // Update existing record - increment attempts
      await db.update(
        'lesson_progress',
        {
          'status': 'in_progress',
          'last_accessed': now,
          'attempts_count': (existing.first['attempts_count'] as int) + 1,
          'updated_at': now,
        },
        where: 'user_id = ? AND language_code = ? AND lesson_id = ?',
        whereArgs: [userId, languageCode, lessonId],
      );

      print('✅ Lesson $lessonId resumed for user $userId');
    }

    // Sync to Firebase (fire and forget)
    _syncLessonProgressToFirebase(userId, languageCode, lessonId).catchError((e) {
      print('⚠️ Firebase sync failed: $e');
    });
  }

  /// Update lesson progress during the session
  Future<void> updateLessonProgress({
    required String userId,
    required String languageCode,
    required String lessonId,
    required int progressPercentage,
    required int timeSpentSeconds,
    int? currentScore,
  }) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final existing = await db.query(
      'lesson_progress',
      where: 'user_id = ? AND language_code = ? AND lesson_id = ?',
      whereArgs: [userId, languageCode, lessonId],
    );

    if (existing.isEmpty) {
      print('⚠️ Lesson progress not found. Starting lesson first...');
      await startLesson(
        userId: userId,
        languageCode: languageCode,
        lessonId: lessonId,
      );
      return;
    }

    final currentBestScore = existing.first['best_score'] as int;
    final newBestScore = currentScore != null && currentScore > currentBestScore
        ? currentScore
        : currentBestScore;

    await db.update(
      'lesson_progress',
      {
        'progress_percentage': progressPercentage,
        'time_spent_seconds': timeSpentSeconds,
        'last_score': currentScore ?? existing.first['last_score'],
        'best_score': newBestScore,
        'last_accessed': now,
        'updated_at': now,
      },
      where: 'user_id = ? AND language_code = ? AND lesson_id = ?',
      whereArgs: [userId, languageCode, lessonId],
    );

    print('📊 Progress updated: $progressPercentage% for lesson $lessonId');
  }

  /// Complete a lesson
  Future<void> completeLesson({
    required String userId,
    required String languageCode,
    required String lessonId,
    required int finalScore,
    required int totalTimeSpent,
  }) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final existing = await db.query(
      'lesson_progress',
      where: 'user_id = ? AND language_code = ? AND lesson_id = ?',
      whereArgs: [userId, languageCode, lessonId],
    );

    if (existing.isEmpty) {
      print('⚠️ Lesson progress not found');
      return;
    }

    final currentBestScore = existing.first['best_score'] as int;
    final newBestScore = finalScore > currentBestScore ? finalScore : currentBestScore;

    await db.update(
      'lesson_progress',
      {
        'status': 'completed',
        'progress_percentage': 100,
        'time_spent_seconds': totalTimeSpent,
        'last_score': finalScore,
        'best_score': newBestScore,
        'completed_at': now,
        'last_accessed': now,
        'updated_at': now,
      },
      where: 'user_id = ? AND language_code = ? AND lesson_id = ?',
      whereArgs: [userId, languageCode, lessonId],
    );

    // Update overall learning progress statistics
    await _updateOverallProgress(userId, languageCode);

    // Check for milestones
    await _checkAndRecordMilestones(userId, languageCode);

    // Sync to Firebase
    _syncLessonProgressToFirebase(userId, languageCode, lessonId).catchError((e) {
      print('⚠️ Firebase sync failed: $e');
    });

    print('🎉 Lesson $lessonId completed! Score: $finalScore');
  }

  /// Get lesson progress
  Future<Map<String, dynamic>?> getLessonProgress({
    required String userId,
    required String languageCode,
    required String lessonId,
  }) async {
    final db = await DatabaseHelper.database;

    final results = await db.query(
      'lesson_progress',
      where: 'user_id = ? AND language_code = ? AND lesson_id = ?',
      whereArgs: [userId, languageCode, lessonId],
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Get all lesson progress for a user
  Future<List<Map<String, dynamic>>> getAllLessonProgress({
    required String userId,
    required String languageCode,
  }) async {
    final db = await DatabaseHelper.database;

    return await db.query(
      'lesson_progress',
      where: 'user_id = ? AND language_code = ?',
      whereArgs: [userId, languageCode],
      orderBy: 'last_accessed DESC',
    );
  }

  /// Update skill progress
  Future<void> updateSkillProgress({
    required String userId,
    required String languageCode,
    required String skillName,
    required int proficiencyScore, // 0-100
    int practiceCount = 1,
  }) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final existing = await db.query(
      'skill_progress',
      where: 'user_id = ? AND language_code = ? AND skill_name = ?',
      whereArgs: [userId, languageCode, skillName],
    );

    if (existing.isEmpty) {
      // Create new skill progress
      await db.insert('skill_progress', {
        'id': '${userId}_${languageCode}_${skillName}_$now',
        'user_id': userId,
        'language_code': languageCode,
        'skill_name': skillName,
        'proficiency_score': proficiencyScore,
        'practice_count': practiceCount,
        'last_practiced': now,
        'created_at': now,
        'updated_at': now,
      });

      print('✅ New skill progress created: $skillName ($proficiencyScore/100)');
    } else {
      // Update existing skill
      final currentPracticeCount = existing.first['practice_count'] as int;
      final currentProficiency = existing.first['proficiency_score'] as int;
      
      // Average the proficiency scores for smoother progression
      final newProficiency = ((currentProficiency + proficiencyScore) / 2).round();

      await db.update(
        'skill_progress',
        {
          'proficiency_score': newProficiency,
          'practice_count': currentPracticeCount + practiceCount,
          'last_practiced': now,
          'updated_at': now,
        },
        where: 'user_id = ? AND language_code = ? AND skill_name = ?',
        whereArgs: [userId, languageCode, skillName],
      );

      print('📈 Skill updated: $skillName ($newProficiency/100)');
    }

    // Sync to Firebase
    _syncSkillProgressToFirebase(userId, languageCode, skillName).catchError((e) {
      print('⚠️ Firebase sync failed: $e');
    });
  }

  /// Get skill progress
  Future<Map<String, dynamic>?> getSkillProgress({
    required String userId,
    required String languageCode,
    required String skillName,
  }) async {
    final db = await DatabaseHelper.database;

    final results = await db.query(
      'skill_progress',
      where: 'user_id = ? AND language_code = ? AND skill_name = ?',
      whereArgs: [userId, languageCode, skillName],
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Get all skills progress for a user
  Future<List<Map<String, dynamic>>> getAllSkillsProgress({
    required String userId,
    required String languageCode,
  }) async {
    final db = await DatabaseHelper.database;

    return await db.query(
      'skill_progress',
      where: 'user_id = ? AND language_code = ?',
      whereArgs: [userId, languageCode],
      orderBy: 'proficiency_score DESC',
    );
  }

  /// Record milestone achievement
  Future<void> recordMilestone({
    required String userId,
    required String languageCode,
    required String milestoneType,
    required String milestoneTitle,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Check if milestone already exists
    final existing = await db.query(
      'milestones',
      where: 'user_id = ? AND language_code = ? AND milestone_type = ?',
      whereArgs: [userId, languageCode, milestoneType],
    );

    if (existing.isEmpty) {
      await db.insert('milestones', {
        'id': '${userId}_${languageCode}_${milestoneType}_$now',
        'user_id': userId,
        'language_code': languageCode,
        'milestone_type': milestoneType,
        'title': milestoneTitle,
        'description': description ?? '',
        'achieved_at': now,
        'metadata': metadata?.toString() ?? '',
        'created_at': now,
      });

      print('🏆 Milestone achieved: $milestoneTitle');

      // Sync to Firebase
      _syncMilestoneToFirebase(userId, languageCode, milestoneType).catchError((e) {
        print('⚠️ Firebase sync failed: $e');
      });
    }
  }

  /// Get all milestones for a user
  Future<List<Map<String, dynamic>>> getMilestones({
    required String userId,
    required String languageCode,
  }) async {
    final db = await DatabaseHelper.database;

    return await db.query(
      'milestones',
      where: 'user_id = ? AND language_code = ?',
      whereArgs: [userId, languageCode],
      orderBy: 'achieved_at DESC',
    );
  }

  /// Get overall statistics for a user
  Future<Map<String, dynamic>> getOverallStatistics({
    required String userId,
    required String languageCode,
  }) async {
    final db = await DatabaseHelper.database;

    // Get completed lessons count
    final completedCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM lesson_progress WHERE user_id = ? AND language_code = ? AND status = ?',
          [userId, languageCode, 'completed'],
        )) ??
        0;

    // Get in-progress lessons count
    final inProgressCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM lesson_progress WHERE user_id = ? AND language_code = ? AND status = ?',
          [userId, languageCode, 'in_progress'],
        )) ??
        0;

    // Get total time spent
    final totalTimeSeconds = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT SUM(time_spent_seconds) FROM lesson_progress WHERE user_id = ? AND language_code = ?',
          [userId, languageCode],
        )) ??
        0;

    // Get average score
    final avgScore = await db.rawQuery(
      'SELECT AVG(best_score) as avg_score FROM lesson_progress WHERE user_id = ? AND language_code = ? AND status = ?',
      [userId, languageCode, 'completed'],
    );
    final averageScore = (avgScore.first['avg_score'] as num?)?.toDouble() ?? 0.0;

    // Get streak
    final streak = await _calculateStreak(userId, languageCode);

    // Get milestone count
    final milestoneCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM milestones WHERE user_id = ? AND language_code = ?',
          [userId, languageCode],
        )) ??
        0;

    return {
      'completedLessons': completedCount,
      'inProgressLessons': inProgressCount,
      'totalTimeSpentSeconds': totalTimeSeconds,
      'totalTimeSpentMinutes': (totalTimeSeconds / 60).round(),
      'totalTimeSpentHours': (totalTimeSeconds / 3600).toStringAsFixed(1),
      'averageScore': averageScore.toStringAsFixed(1),
      'currentStreak': streak,
      'milestonesEarned': milestoneCount,
    };
  }

  /// Update overall learning progress in learning_progress table
  Future<void> _updateOverallProgress(String userId, String languageCode) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Get statistics
    final stats = await getOverallStatistics(
      userId: userId,
      languageCode: languageCode,
    );

    final completedCount = stats['completedLessons'] as int;
    final totalTime = stats['totalTimeSpentSeconds'] as int;
    final streak = stats['currentStreak'] as int;

    // Get existing progress or create new
    final existing = await db.query(
      'learning_progress',
      where: 'user_id = ? AND language_code = ?',
      whereArgs: [userId, languageCode],
    );

    final averageSession = completedCount > 0 ? totalTime ~/ completedCount : 0;
    final completionRate = await _calculateCompletionRate(userId, languageCode);

    if (existing.isEmpty) {
      await db.insert('learning_progress', {
        'id': '${userId}_${languageCode}_$now',
        'user_id': userId,
        'language_code': languageCode,
        'total_lessons_completed': completedCount,
        'total_time_spent': totalTime,
        'current_streak': streak,
        'longest_streak': streak,
        'last_study_date': now,
        'average_session_duration': averageSession,
        'study_frequency': 'active',
        'completion_rate': completionRate,
        'last_updated': now,
        'created_at': now,
      });

      print('✅ Learning progress record created');
    } else {
      final longestStreak = existing.first['longest_streak'] as int;
      final newLongestStreak = streak > longestStreak ? streak : longestStreak;

      await db.update(
        'learning_progress',
        {
          'total_lessons_completed': completedCount,
          'total_time_spent': totalTime,
          'current_streak': streak,
          'longest_streak': newLongestStreak,
          'last_study_date': now,
          'average_session_duration': averageSession,
          'completion_rate': completionRate,
          'last_updated': now,
        },
        where: 'user_id = ? AND language_code = ?',
        whereArgs: [userId, languageCode],
      );

      print('✅ Learning progress updated');
    }
  }

  /// Calculate current streak (consecutive days studied)
  Future<int> _calculateStreak(String userId, String languageCode) async {
    final db = await DatabaseHelper.database;

    final completedLessons = await db.query(
      'lesson_progress',
      where: 'user_id = ? AND language_code = ? AND status = ?',
      whereArgs: [userId, languageCode, 'completed'],
      orderBy: 'completed_at DESC',
    );

    if (completedLessons.isEmpty) return 0;

    int streak = 0;
    final Set<String> studyDays = {};

    for (var lesson in completedLessons) {
      final completedAt = DateTime.fromMillisecondsSinceEpoch(
        lesson['completed_at'] as int,
      );
      
      final dateKey = '${completedAt.year}-${completedAt.month}-${completedAt.day}';
      studyDays.add(dateKey);
    }

    // Count consecutive days from today
    final now = DateTime.now();
    DateTime checkDate = now;
    
    for (int i = 0; i < 365; i++) {
      final dateKey = '${checkDate.year}-${checkDate.month}-${checkDate.day}';
      
      if (studyDays.contains(dateKey)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // Allow one day grace period for today
        if (i == 0) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }

    return streak;
  }

  /// Calculate completion rate
  Future<double> _calculateCompletionRate(String userId, String languageCode) async {
    final db = await DatabaseHelper.database;

    final totalStarted = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM lesson_progress WHERE user_id = ? AND language_code = ?',
          [userId, languageCode],
        )) ??
        0;

    final totalCompleted = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM lesson_progress WHERE user_id = ? AND language_code = ? AND status = ?',
          [userId, languageCode, 'completed'],
        )) ??
        0;

    return totalStarted > 0 ? (totalCompleted / totalStarted) * 100 : 0.0;
  }

  /// Check and record automatic milestones based on progress
  Future<void> _checkAndRecordMilestones(String userId, String languageCode) async {
    final db = await DatabaseHelper.database;

    final completedCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM lesson_progress WHERE user_id = ? AND language_code = ? AND status = ?',
          [userId, languageCode, 'completed'],
        )) ??
        0;

    // Define milestone thresholds
    final milestones = [
      {'count': 1, 'type': 'first_lesson', 'title': 'First Steps', 'description': 'Completed your first lesson!'},
      {'count': 5, 'type': 'five_lessons', 'title': 'Getting Started', 'description': 'Completed 5 lessons!'},
      {'count': 10, 'type': 'ten_lessons', 'title': 'Dedicated Learner', 'description': 'Completed 10 lessons!'},
      {'count': 25, 'type': 'twentyfive_lessons', 'title': 'Committed Student', 'description': 'Completed 25 lessons!'},
      {'count': 50, 'type': 'fifty_lessons', 'title': 'Language Enthusiast', 'description': 'Completed 50 lessons!'},
      {'count': 100, 'type': 'hundred_lessons', 'title': 'Master Student', 'description': 'Completed 100 lessons!'},
    ];

    for (var milestone in milestones) {
      if (completedCount == milestone['count']) {
        await recordMilestone(
          userId: userId,
          languageCode: languageCode,
          milestoneType: milestone['type'] as String,
          milestoneTitle: milestone['title'] as String,
          description: milestone['description'] as String,
        );
      }
    }
  }

  /// Sync lesson progress to Firebase
  Future<void> _syncLessonProgressToFirebase(
      String userId, String languageCode, String lessonId) async {
    final db = await DatabaseHelper.database;
    final progress = await db.query(
      'lesson_progress',
      where: 'user_id = ? AND language_code = ? AND lesson_id = ?',
      whereArgs: [userId, languageCode, lessonId],
    );

    if (progress.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('lesson_progress')
          .doc('${languageCode}_$lessonId')
          .set(progress.first, SetOptions(merge: true));
    }
  }

  /// Sync skill progress to Firebase
  Future<void> _syncSkillProgressToFirebase(
      String userId, String languageCode, String skillName) async {
    final db = await DatabaseHelper.database;
    final skill = await db.query(
      'skill_progress',
      where: 'user_id = ? AND language_code = ? AND skill_name = ?',
      whereArgs: [userId, languageCode, skillName],
    );

    if (skill.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('skill_progress')
          .doc('${languageCode}_$skillName')
          .set(skill.first, SetOptions(merge: true));
    }
  }

  /// Sync milestone to Firebase
  Future<void> _syncMilestoneToFirebase(
      String userId, String languageCode, String milestoneType) async {
    final db = await DatabaseHelper.database;
    final milestone = await db.query(
      'milestones',
      where: 'user_id = ? AND language_code = ? AND milestone_type = ?',
      whereArgs: [userId, languageCode, milestoneType],
    );

    if (milestone.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('milestones')
          .doc('${languageCode}_$milestoneType')
          .set(milestone.first, SetOptions(merge: true));
    }
  }
}
