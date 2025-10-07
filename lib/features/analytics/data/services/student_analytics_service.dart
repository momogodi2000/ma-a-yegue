import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maa_yegue/core/database/database_helper.dart';
import 'package:maa_yegue/features/analytics/data/models/student_analytics_models.dart';

/// Service for student analytics and performance tracking
class StudentAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get comprehensive student analytics
  Future<StudentAnalytics> getStudentAnalytics(String userId) async {
    final db = await DatabaseHelper.database;

    // Get learning progress data
    final progressData = await _getLearningProgress(userId, db);

    // Get performance metrics
    final performanceData = await _getPerformanceMetrics(userId, db);

    // Get learning patterns
    final patternsData = await _getLearningPatterns(userId, db);

    // Get achievements and badges
    final achievementsData = await _getAchievements(userId, db);

    return StudentAnalytics(
      userId: userId,
      learningProgress: progressData,
      performanceMetrics: performanceData,
      learningPatterns: patternsData,
      achievements: achievementsData,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get learning progress summary
  Future<LearningProgress> _getLearningProgress(
    String userId,
    Database db,
  ) async {
    // Get total courses enrolled
    final enrolledCourses = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT course_id) as count
      FROM lesson_progress
      WHERE user_id = ?
    ''',
      [userId],
    );

    // Get completed courses
    final completedCourses = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM (
        SELECT course_id
        FROM lesson_progress
        WHERE user_id = ? AND status = 'completed'
        GROUP BY course_id
        HAVING COUNT(*) = (
          SELECT COUNT(*) FROM lessons WHERE course_id = lesson_progress.course_id
        )
      )
    ''',
      [userId],
    );

    // Get total lessons completed
    final completedLessons = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM lesson_progress
      WHERE user_id = ? AND status = 'completed'
    ''',
      [userId],
    );

    // Get total study time
    final studyTime = await db.rawQuery(
      '''
      SELECT SUM(time_spent_seconds) as total_seconds
      FROM lesson_progress
      WHERE user_id = ?
    ''',
      [userId],
    );

    // Get current streak
    final streakData = await _calculateCurrentStreak(userId, db);

    return LearningProgress(
      enrolledCourses: enrolledCourses.first['count'] as int? ?? 0,
      completedCourses: completedCourses.first['count'] as int? ?? 0,
      completedLessons: completedLessons.first['count'] as int? ?? 0,
      totalStudyTimeMinutes:
          ((studyTime.first['total_seconds'] as int? ?? 0) / 60).round(),
      currentStreak: streakData['current'] ?? 0,
      longestStreak: streakData['longest'] ?? 0,
    );
  }

  /// Get performance metrics
  Future<PerformanceMetrics> _getPerformanceMetrics(
    String userId,
    Database db,
  ) async {
    // Get average quiz scores
    final quizScores = await db.rawQuery(
      '''
      SELECT AVG(best_score) as avg_score, COUNT(*) as total_quizzes
      FROM lesson_progress
      WHERE user_id = ? AND best_score > 0
    ''',
      [userId],
    );

    // Get language-specific performance
    final languagePerformance = await _getLanguagePerformance(userId, db);

    // Get improvement trends
    final improvementData = await _calculateImprovementTrends(userId, db);

    return PerformanceMetrics(
      averageQuizScore: (quizScores.first['avg_score'] as double? ?? 0.0),
      totalQuizzesTaken: quizScores.first['total_quizzes'] as int? ?? 0,
      languagePerformance: languagePerformance,
      improvementRate: improvementData['rate'] ?? 0.0,
      strengths: improvementData['strengths'] ?? [],
      weaknesses: improvementData['weaknesses'] ?? [],
    );
  }

  /// Get learning patterns and insights
  Future<LearningPatterns> _getLearningPatterns(
    String userId,
    Database db,
  ) async {
    // Get study sessions by hour of day
    final hourlyPattern = await db.rawQuery(
      '''
      SELECT
        strftime('%H', datetime(last_accessed/1000, 'unixepoch')) as hour,
        COUNT(*) as sessions
      FROM lesson_progress
      WHERE user_id = ?
      GROUP BY hour
      ORDER BY sessions DESC
      LIMIT 1
    ''',
      [userId],
    );

    // Get study sessions by day of week
    final weeklyPattern = await db.rawQuery(
      '''
      SELECT
        strftime('%w', datetime(last_accessed/1000, 'unixepoch')) as day,
        COUNT(*) as sessions
      FROM lesson_progress
      WHERE user_id = ?
      GROUP BY day
      ORDER BY sessions DESC
      LIMIT 1
    ''',
      [userId],
    );

    // Get preferred content types
    final contentPreferences = await _getContentTypePreferences(userId, db);

    // Get learning pace analysis
    final paceAnalysis = await _analyzeLearningPace(userId, db);

    return LearningPatterns(
      preferredStudyHour:
          int.tryParse(hourlyPattern.first['hour'] as String? ?? '9') ?? 9,
      preferredStudyDay: _getDayName(
        int.tryParse(weeklyPattern.first['day'] as String? ?? '1') ?? 1,
      ),
      contentTypePreferences: contentPreferences,
      averageSessionDuration: paceAnalysis['avg_duration'] ?? 15,
      consistencyScore: paceAnalysis['consistency'] ?? 0.0,
      recommendedStudyTime: _calculateRecommendedStudyTime(paceAnalysis),
    );
  }

  /// Get achievements and badges
  Future<AchievementsData> _getAchievements(String userId, Database db) async {
    // This would typically come from a dedicated achievements table
    // For now, calculate based on progress
    final progress = await _getLearningProgress(userId, db);

    final badges = <Badge>[];

    // Course completion badges
    if (progress.completedCourses >= 1) {
      badges.add(
        Badge(name: 'First Course', icon: '🎓', earnedAt: DateTime.now()),
      );
    }
    if (progress.completedCourses >= 5) {
      badges.add(Badge(name: 'Scholar', icon: '📚', earnedAt: DateTime.now()));
    }
    if (progress.completedCourses >= 10) {
      badges.add(
        Badge(name: 'Master Linguist', icon: '🏆', earnedAt: DateTime.now()),
      );
    }

    // Streak badges
    if (progress.currentStreak >= 7) {
      badges.add(
        Badge(name: 'Week Warrior', icon: '🔥', earnedAt: DateTime.now()),
      );
    }
    if (progress.longestStreak >= 30) {
      badges.add(
        Badge(
          name: 'Dedication Champion',
          icon: '💪',
          earnedAt: DateTime.now(),
        ),
      );
    }

    // Study time badges
    if (progress.totalStudyTimeMinutes >= 60) {
      badges.add(
        Badge(name: 'Hour Master', icon: '⏰', earnedAt: DateTime.now()),
      );
    }
    if (progress.totalStudyTimeMinutes >= 600) {
      badges.add(
        Badge(name: 'Study Legend', icon: '🌟', earnedAt: DateTime.now()),
      );
    }

    return AchievementsData(
      earnedBadges: badges,
      totalPoints:
          progress.completedLessons * 10 + progress.totalStudyTimeMinutes,
      level: (progress.completedLessons / 5).floor() + 1,
      nextLevelProgress: (progress.completedLessons % 5) * 20,
    );
  }

  // ===== PRIVATE HELPER METHODS =====

  Future<Map<String, int>> _calculateCurrentStreak(
    String userId,
    Database db,
  ) async {
    // Get study dates for the last 60 days
    final studyDates = await db.rawQuery(
      '''
      SELECT DISTINCT date(datetime(last_accessed/1000, 'unixepoch')) as study_date
      FROM lesson_progress
      WHERE user_id = ?
        AND last_accessed > strftime('%s', datetime('now', '-60 days')) * 1000
      ORDER BY study_date DESC
    ''',
      [userId],
    );

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    if (studyDates.isNotEmpty) {
      final dates = studyDates
          .map((row) => row['study_date'] as String)
          .toList();
      // Calculate current streak
      DateTime checkDate = DateTime.now();
      while (dates.contains(checkDate.toIso8601String().split('T')[0])) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      // Calculate longest streak
      for (int i = 0; i < dates.length; i++) {
        tempStreak = 1;
        DateTime current = DateTime.parse(dates[i]);

        for (int j = i + 1; j < dates.length; j++) {
          DateTime next = DateTime.parse(dates[j]);
          if (current.difference(next).inDays == 1) {
            tempStreak++;
            current = next;
          } else {
            break;
          }
        }

        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
      }
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }

  Future<Map<String, dynamic>> _getLanguagePerformance(
    String userId,
    Database db,
  ) async {
    // This would analyze performance by language
    // For now, return mock data
    return {
      'ewondo': {'score': 85.0, 'lessons_completed': 12},
      'duala': {'score': 78.0, 'lessons_completed': 8},
      'fulfulde': {'score': 92.0, 'lessons_completed': 15},
    };
  }

  Future<Map<String, dynamic>> _calculateImprovementTrends(
    String userId,
    Database db,
  ) async {
    // Calculate improvement rate over time
    // For now, return mock data
    return {
      'rate': 2.5, // 2.5% improvement per week
      'strengths': ['vocabulary', 'pronunciation'],
      'weaknesses': ['grammar', 'conversation'],
    };
  }

  Future<Map<String, int>> _getContentTypePreferences(
    String userId,
    Database db,
  ) async {
    // This would analyze preferred content types
    // For now, return mock data
    return {'video': 45, 'audio': 30, 'text': 15, 'quiz': 10};
  }

  Future<Map<String, dynamic>> _analyzeLearningPace(
    String userId,
    Database db,
  ) async {
    // Analyze average session duration and consistency
    final sessions = await db.rawQuery(
      '''
      SELECT time_spent_seconds, last_accessed
      FROM lesson_progress
      WHERE user_id = ? AND time_spent_seconds > 0
      ORDER BY last_accessed DESC
      LIMIT 30
    ''',
      [userId],
    );

    if (sessions.isEmpty) {
      return {'avg_duration': 15, 'consistency': 0.0};
    }

    final durations = sessions
        .map((s) => s['time_spent_seconds'] as int)
        .toList();
    final avgDuration = durations.reduce((a, b) => a + b) / durations.length;

    // Calculate consistency (lower variance = higher consistency)
    final variance =
        durations
            .map((d) => (d - avgDuration) * (d - avgDuration))
            .reduce((a, b) => a + b) /
        durations.length;
    final consistency = 1.0 / (1.0 + variance / 10000); // Normalize to 0-1

    return {
      'avg_duration': (avgDuration / 60).round(), // Convert to minutes
      'consistency': consistency,
    };
  }

  String _getDayName(int dayIndex) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return days[dayIndex % 7];
  }

  int _calculateRecommendedStudyTime(Map<String, dynamic> paceAnalysis) {
    final avgDuration = paceAnalysis['avg_duration'] ?? 15;
    final consistency = paceAnalysis['consistency'] ?? 0.0;

    // Recommend based on current patterns
    if (consistency > 0.7) {
      return avgDuration + 5; // Increase if consistent
    } else {
      return avgDuration - 2; // Decrease if inconsistent
    }
  }

  /// Sync analytics data to Firebase
  Future<void> syncAnalyticsToFirebase(
    String userId,
    StudentAnalytics analytics,
  ) async {
    try {
      await _firestore.collection('user_analytics').doc(userId).set({
        'learning_progress': analytics.learningProgress.toJson(),
        'performance_metrics': analytics.performanceMetrics.toJson(),
        'learning_patterns': analytics.learningPatterns.toJson(),
        'achievements': analytics.achievements.toJson(),
        'last_updated': analytics.lastUpdated.toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ Failed to sync analytics to Firebase: $e');
    }
  }
}
