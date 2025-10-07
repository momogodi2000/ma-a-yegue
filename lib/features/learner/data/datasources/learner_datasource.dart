import 'package:sqflite/sqflite.dart';
import '../../domain/repositories/learner_repository.dart';
import '../models/learner_model.dart';
import '../../../../core/errors/failures.dart';

/// Abstract data source for learner data
abstract class LearnerDataSource {
  /// Get learner profile from local database
  Future<LearnerModel?> getLearnerProfile(String userId);

  /// Save learner profile to local database
  Future<void> saveLearnerProfile(LearnerModel learner);

  /// Get language progress from local database
  Future<LanguageProgressModel?> getLanguageProgress(
    String userId,
    String languageCode,
  );

  /// Save language progress to local database
  Future<void> saveLanguageProgress(
    String userId,
    String languageCode,
    LanguageProgressModel progress,
  );

  /// Get learner achievements from local database
  Future<List<AchievementModel>> getLearnerAchievements(String userId);

  /// Save learner achievements to local database
  Future<void> saveLearnerAchievements(
    String userId,
    List<AchievementModel> achievements,
  );

  /// Get learning statistics from local database
  Future<Map<String, dynamic>> getLearningStatistics(String userId);

  /// Record lesson completion in local database
  Future<void> recordLessonCompletion({
    required String userId,
    required String lessonId,
    required String languageCode,
    required int score,
    required int timeSpentMinutes,
    required Map<String, dynamic> metadata,
  });

  /// Record course completion in local database
  Future<void> recordCourseCompletion({
    required String userId,
    required String courseId,
    required String languageCode,
    required int finalScore,
    required int totalTimeSpentMinutes,
  });

  /// Get study streak from local database
  Future<int> getStudyStreak(String userId);

  /// Update study streak in local database
  Future<void> updateStudyStreak(String userId, DateTime studyDate);

  /// Get learning history from local database
  Future<List<Map<String, dynamic>>> getLearningHistory(
    String userId, {
    int limit = 50,
  });

  /// Get level assessments from local database
  Future<List<Map<String, dynamic>>> getLevelAssessments(
    String userId,
    String languageCode,
  );

  /// Save level assessment to local database
  Future<void> saveLevelAssessment({
    required String userId,
    required String languageCode,
    required String level,
    required double score,
    required Map<String, dynamic> assessmentData,
  });

  /// Get skill assessments from local database
  Future<Map<String, double>> getSkillAssessments(
    String userId,
    String languageCode,
  );

  /// Update skill assessment in local database
  Future<void> updateSkillAssessment(
    String userId,
    String languageCode,
    String skill,
    double score,
  );

  /// Get learning goals from local database
  Future<List<LearningGoalModel>> getLearningGoals(String userId);

  /// Save learning goal to local database
  Future<void> saveLearningGoal(LearningGoalModel goal);

  /// Update learning goal progress in local database
  Future<void> updateGoalProgress(
    String userId,
    String goalId,
    double progress,
  );

  /// Get learning recommendations from local database
  Future<List<LearningRecommendationModel>> getLearningRecommendations(
    String userId,
    String languageCode,
  );

  /// Save learning recommendation to local database
  Future<void> saveLearningRecommendation(
    LearningRecommendationModel recommendation,
  );

  /// Complete learning recommendation in local database
  Future<void> completeLearningRecommendation(
    String userId,
    String recommendationId,
  );

  /// Get learning preferences from local database
  Future<LearningPreferencesModel?> getLearningPreferences(String userId);

  /// Save learning preferences to local database
  Future<void> saveLearningPreferences(
    String userId,
    LearningPreferencesModel preferences,
  );

  /// Get peer comparison data from local database
  Future<Map<String, dynamic>> getPeerComparison(
    String userId,
    String languageCode,
  );

  /// Get study patterns from local database
  Future<Map<String, dynamic>> getStudyPatterns(String userId);

  /// Get performance analytics from local database
  Future<Map<String, dynamic>> getPerformanceAnalytics(
    String userId,
    String languageCode,
  );

  /// Get current learning path from local database
  Future<List<String>> getCurrentLearningPath(
    String userId,
    String languageCode,
  );

  /// Update learning path in local database
  Future<void> updateLearningPath(
    String userId,
    String languageCode,
    List<String> lessonIds,
  );

  /// Reset learner progress in local database
  Future<void> resetLearnerProgress(String userId, String languageCode);

  /// Clear all learner data (for testing)
  Future<void> clearAllData();
}

/// Local learner data source implementation
class LearnerLocalDataSource implements LearnerDataSource {
  final Database _database;

  LearnerLocalDataSource(this._database);

  @override
  Future<LearnerModel?> getLearnerProfile(String userId) async {
    try {
      final result = await _database.query(
        'learner_profiles',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      if (result.isEmpty) return null;

      return LearnerModel.fromJson(result.first);
    } catch (e) {
      throw CacheFailure('Failed to get learner profile: $e');
    }
  }

  @override
  Future<void> saveLearnerProfile(LearnerModel learner) async {
    try {
      await _database.insert(
        'learner_profiles',
        learner.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save learner profile: $e');
    }
  }

  @override
  Future<LanguageProgressModel?> getLanguageProgress(
    String userId,
    String languageCode,
  ) async {
    try {
      final result = await _database.query(
        'language_progress',
        where: 'userId = ? AND languageCode = ?',
        whereArgs: [userId, languageCode],
      );

      if (result.isEmpty) return null;

      return LanguageProgressModel.fromJson(result.first);
    } catch (e) {
      throw CacheFailure('Failed to get language progress: $e');
    }
  }

  @override
  Future<void> saveLanguageProgress(
    String userId,
    String languageCode,
    LanguageProgressModel progress,
  ) async {
    try {
      final progressData = progress.toJson();
      progressData['userId'] = userId;

      await _database.insert(
        'language_progress',
        progressData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save language progress: $e');
    }
  }

  @override
  Future<List<AchievementModel>> getLearnerAchievements(String userId) async {
    try {
      final result = await _database.query(
        'learner_achievements',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'earnedAt DESC',
      );

      return result
          .map((achievement) => AchievementModel.fromJson(achievement))
          .toList();
    } catch (e) {
      throw CacheFailure('Failed to get learner achievements: $e');
    }
  }

  @override
  Future<void> saveLearnerAchievements(
    String userId,
    List<AchievementModel> achievements,
  ) async {
    try {
      await _database.delete(
        'learner_achievements',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      for (final achievement in achievements) {
        final achievementData = achievement.toJson();
        achievementData['userId'] = userId;
        await _database.insert('learner_achievements', achievementData);
      }
    } catch (e) {
      throw CacheFailure('Failed to save learner achievements: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getLearningStatistics(String userId) async {
    try {
      // Get basic statistics
      final profile = await getLearnerProfile(userId);
      if (profile == null) {
        return {
          'totalLessonsCompleted': 0,
          'totalCoursesCompleted': 0,
          'totalStudyTime': 0,
          'currentStreak': 0,
          'longestStreak': 0,
          'totalExperiencePoints': 0,
          'averageAccuracy': 0.0,
        };
      }

      // Get additional statistics from learning history
      final history = await getLearningHistory(userId, limit: 1000);

      int totalStudyTime = 0;
      double totalAccuracy = 0.0;
      int accuracyCount = 0;

      for (final record in history) {
        totalStudyTime += record['timeSpentMinutes'] as int? ?? 0;
        if (record['accuracy'] != null) {
          totalAccuracy += (record['accuracy'] as num).toDouble();
          accuracyCount++;
        }
      }

      return {
        'totalLessonsCompleted': profile.completedLessons.length,
        'totalCoursesCompleted': profile.completedCourses.length,
        'totalStudyTime': totalStudyTime,
        'currentStreak': profile.currentStreak,
        'longestStreak': profile.longestStreak,
        'totalExperiencePoints': profile.totalExperiencePoints,
        'averageAccuracy': accuracyCount > 0
            ? totalAccuracy / accuracyCount
            : 0.0,
        'languagesLearned': profile.learningLanguages.length,
        'achievementsEarned': profile.achievements.length,
      };
    } catch (e) {
      throw CacheFailure('Failed to get learning statistics: $e');
    }
  }

  @override
  Future<void> recordLessonCompletion({
    required String userId,
    required String lessonId,
    required String languageCode,
    required int score,
    required int timeSpentMinutes,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      await _database.insert('learning_history', {
        'userId': userId,
        'lessonId': lessonId,
        'languageCode': languageCode,
        'activityType': 'lesson_completion',
        'score': score,
        'timeSpentMinutes': timeSpentMinutes,
        'metadata': metadata.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Update language progress
      final progress = await getLanguageProgress(userId, languageCode);
      if (progress != null) {
        final updatedProgress = LanguageProgressModel(
          languageCode: progress.languageCode,
          languageName: progress.languageName,
          currentLevel: progress.currentLevel,
          experiencePoints: progress.experiencePoints + score,
          lessonsCompleted: progress.lessonsCompleted + 1,
          coursesCompleted: progress.coursesCompleted,
          accuracy: progress.accuracy, // Will be updated separately
          studyTimeMinutes: progress.studyTimeMinutes + timeSpentMinutes,
          lastStudiedAt: DateTime.now(),
          completedLessons: [...progress.completedLessons, lessonId],
          completedCourses: progress.completedCourses,
          skillScores: progress.skillScores,
        );
        await saveLanguageProgress(userId, languageCode, updatedProgress);
      }

      // Update study streak
      await updateStudyStreak(userId, DateTime.now());
    } catch (e) {
      throw CacheFailure('Failed to record lesson completion: $e');
    }
  }

  @override
  Future<void> recordCourseCompletion({
    required String userId,
    required String courseId,
    required String languageCode,
    required int finalScore,
    required int totalTimeSpentMinutes,
  }) async {
    try {
      await _database.insert('learning_history', {
        'userId': userId,
        'courseId': courseId,
        'languageCode': languageCode,
        'activityType': 'course_completion',
        'score': finalScore,
        'timeSpentMinutes': totalTimeSpentMinutes,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Update language progress
      final progress = await getLanguageProgress(userId, languageCode);
      if (progress != null) {
        final updatedProgress = LanguageProgressModel(
          languageCode: progress.languageCode,
          languageName: progress.languageName,
          currentLevel: progress.currentLevel,
          experiencePoints: progress.experiencePoints + finalScore,
          lessonsCompleted: progress.lessonsCompleted,
          coursesCompleted: progress.coursesCompleted + 1,
          accuracy: progress.accuracy,
          studyTimeMinutes: progress.studyTimeMinutes + totalTimeSpentMinutes,
          lastStudiedAt: DateTime.now(),
          completedLessons: progress.completedLessons,
          completedCourses: [...progress.completedCourses, courseId],
          skillScores: progress.skillScores,
        );
        await saveLanguageProgress(userId, languageCode, updatedProgress);
      }
    } catch (e) {
      throw CacheFailure('Failed to record course completion: $e');
    }
  }

  @override
  Future<int> getStudyStreak(String userId) async {
    try {
      final result = await _database.query(
        'study_streaks',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      if (result.isEmpty) return 0;
      return result.first['currentStreak'] as int? ?? 0;
    } catch (e) {
      throw CacheFailure('Failed to get study streak: $e');
    }
  }

  @override
  Future<void> updateStudyStreak(String userId, DateTime studyDate) async {
    try {
      final today = DateTime(studyDate.year, studyDate.month, studyDate.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final currentStreak = await _database.query(
        'study_streaks',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      int newStreak = 1;
      DateTime lastStudyDate = today;

      if (currentStreak.isNotEmpty) {
        final lastDate = DateTime.parse(
          currentStreak.first['lastStudyDate'] as String,
        );
        final lastStreak = currentStreak.first['currentStreak'] as int;

        if (lastDate == yesterday) {
          newStreak = lastStreak + 1;
        } else if (lastDate != today) {
          newStreak = 1;
        } else {
          return; // Already studied today
        }
      }

      await _database.insert('study_streaks', {
        'userId': userId,
        'currentStreak': newStreak,
        'lastStudyDate': lastStudyDate.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw CacheFailure('Failed to update study streak: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLearningHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final result = await _database.query(
        'learning_history',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      return result;
    } catch (e) {
      throw CacheFailure('Failed to get learning history: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLevelAssessments(
    String userId,
    String languageCode,
  ) async {
    try {
      final result = await _database.query(
        'level_assessments',
        where: 'userId = ? AND languageCode = ?',
        whereArgs: [userId, languageCode],
        orderBy: 'completedAt DESC',
      );

      return result;
    } catch (e) {
      throw CacheFailure('Failed to get level assessments: $e');
    }
  }

  @override
  Future<void> saveLevelAssessment({
    required String userId,
    required String languageCode,
    required String level,
    required double score,
    required Map<String, dynamic> assessmentData,
  }) async {
    try {
      await _database.insert('level_assessments', {
        'userId': userId,
        'languageCode': languageCode,
        'level': level,
        'score': score,
        'assessmentData': assessmentData.toString(),
        'completedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw CacheFailure('Failed to save level assessment: $e');
    }
  }

  @override
  Future<Map<String, double>> getSkillAssessments(
    String userId,
    String languageCode,
  ) async {
    try {
      final result = await _database.query(
        'skill_assessments',
        where: 'userId = ? AND languageCode = ?',
        whereArgs: [userId, languageCode],
      );

      final Map<String, double> skills = {};
      for (final row in result) {
        skills[row['skill'] as String] = (row['score'] as num).toDouble();
      }

      return skills;
    } catch (e) {
      throw CacheFailure('Failed to get skill assessments: $e');
    }
  }

  @override
  Future<void> updateSkillAssessment(
    String userId,
    String languageCode,
    String skill,
    double score,
  ) async {
    try {
      await _database.insert('skill_assessments', {
        'userId': userId,
        'languageCode': languageCode,
        'skill': skill,
        'score': score,
        'updatedAt': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw CacheFailure('Failed to update skill assessment: $e');
    }
  }

  @override
  Future<List<LearningGoalModel>> getLearningGoals(String userId) async {
    try {
      final result = await _database.query(
        'learning_goals',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );

      return result.map((goal) => LearningGoalModel.fromJson(goal)).toList();
    } catch (e) {
      throw CacheFailure('Failed to get learning goals: $e');
    }
  }

  @override
  Future<void> saveLearningGoal(LearningGoalModel goal) async {
    try {
      await _database.insert(
        'learning_goals',
        goal.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save learning goal: $e');
    }
  }

  @override
  Future<void> updateGoalProgress(
    String userId,
    String goalId,
    double progress,
  ) async {
    try {
      await _database.update(
        'learning_goals',
        {'progress': progress, 'updatedAt': DateTime.now().toIso8601String()},
        where: 'id = ? AND userId = ?',
        whereArgs: [goalId, userId],
      );
    } catch (e) {
      throw CacheFailure('Failed to update goal progress: $e');
    }
  }

  @override
  Future<List<LearningRecommendationModel>> getLearningRecommendations(
    String userId,
    String languageCode,
  ) async {
    try {
      final result = await _database.query(
        'learning_recommendations',
        where: 'userId = ? AND languageCode = ?',
        whereArgs: [userId, languageCode],
        orderBy: 'priority DESC, createdAt DESC',
      );

      return result
          .map((rec) => LearningRecommendationModel.fromJson(rec))
          .toList();
    } catch (e) {
      throw CacheFailure('Failed to get learning recommendations: $e');
    }
  }

  @override
  Future<void> saveLearningRecommendation(
    LearningRecommendationModel recommendation,
  ) async {
    try {
      await _database.insert(
        'learning_recommendations',
        recommendation.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save learning recommendation: $e');
    }
  }

  @override
  Future<void> completeLearningRecommendation(
    String userId,
    String recommendationId,
  ) async {
    try {
      await _database.update(
        'learning_recommendations',
        {
          'isCompleted': true,
          'completedAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ? AND userId = ?',
        whereArgs: [recommendationId, userId],
      );
    } catch (e) {
      throw CacheFailure('Failed to complete learning recommendation: $e');
    }
  }

  @override
  Future<LearningPreferencesModel?> getLearningPreferences(
    String userId,
  ) async {
    try {
      final result = await _database.query(
        'learning_preferences',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      if (result.isEmpty) return null;
      return LearningPreferencesModel.fromJson(result.first);
    } catch (e) {
      throw CacheFailure('Failed to get learning preferences: $e');
    }
  }

  @override
  Future<void> saveLearningPreferences(
    String userId,
    LearningPreferencesModel preferences,
  ) async {
    try {
      final preferencesData = preferences.toJson();
      preferencesData['userId'] = userId;

      await _database.insert(
        'learning_preferences',
        preferencesData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save learning preferences: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPeerComparison(
    String userId,
    String languageCode,
  ) async {
    // This would typically involve comparing with other learners
    // For now, return mock data
    return {
      'userRank': 1,
      'totalLearners': 100,
      'averageProgress': 0.65,
      'userProgress': 0.78,
      'percentile': 85,
    };
  }

  @override
  Future<Map<String, dynamic>> getStudyPatterns(String userId) async {
    try {
      final history = await getLearningHistory(userId, limit: 1000);

      // Analyze study patterns
      final Map<String, int> hourlyPattern = {};
      final Map<String, int> dailyPattern = {};

      for (final record in history) {
        final timestamp = DateTime.parse(record['timestamp'] as String);
        final hour = timestamp.hour.toString().padLeft(2, '0');
        final day = timestamp.weekday.toString();

        hourlyPattern[hour] = (hourlyPattern[hour] ?? 0) + 1;
        dailyPattern[day] = (dailyPattern[day] ?? 0) + 1;
      }

      return {
        'hourlyPattern': hourlyPattern,
        'dailyPattern': dailyPattern,
        'averageSessionDuration': 25, // minutes
        'mostActiveHour': '10',
        'mostActiveDay': '2', // Tuesday
      };
    } catch (e) {
      throw CacheFailure('Failed to get study patterns: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPerformanceAnalytics(
    String userId,
    String languageCode,
  ) async {
    try {
      final progress = await getLanguageProgress(userId, languageCode);
      final history = await getLearningHistory(userId, limit: 100);

      if (progress == null) {
        return {
          'accuracy': 0.0,
          'speed': 0.0,
          'consistency': 0.0,
          'improvement': 0.0,
        };
      }

      // Calculate performance metrics
      double totalAccuracy = 0.0;
      int accuracyCount = 0;
      double totalSpeed = 0.0;
      int speedCount = 0;

      for (final record in history) {
        if (record['languageCode'] == languageCode) {
          if (record['accuracy'] != null) {
            totalAccuracy += (record['accuracy'] as num).toDouble();
            accuracyCount++;
          }
          if (record['timeSpentMinutes'] != null) {
            totalSpeed += (record['timeSpentMinutes'] as num).toDouble();
            speedCount++;
          }
        }
      }

      return {
        'accuracy': accuracyCount > 0 ? totalAccuracy / accuracyCount : 0.0,
        'speed': speedCount > 0 ? totalSpeed / speedCount : 0.0,
        'consistency': 0.8, // Mock value
        'improvement': 0.15, // Mock value
        'totalLessons': progress.lessonsCompleted,
        'totalCourses': progress.coursesCompleted,
        'studyTime': progress.studyTimeMinutes,
      };
    } catch (e) {
      throw CacheFailure('Failed to get performance analytics: $e');
    }
  }

  @override
  Future<List<String>> getCurrentLearningPath(
    String userId,
    String languageCode,
  ) async {
    try {
      final result = await _database.query(
        'learning_paths',
        where: 'userId = ? AND languageCode = ?',
        whereArgs: [userId, languageCode],
      );

      if (result.isEmpty) return [];
      return List<String>.from(result.first['lessonIds'] as List);
    } catch (e) {
      throw CacheFailure('Failed to get current learning path: $e');
    }
  }

  @override
  Future<void> updateLearningPath(
    String userId,
    String languageCode,
    List<String> lessonIds,
  ) async {
    try {
      await _database.insert('learning_paths', {
        'userId': userId,
        'languageCode': languageCode,
        'lessonIds': lessonIds.join(','),
        'updatedAt': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw CacheFailure('Failed to update learning path: $e');
    }
  }

  @override
  Future<void> resetLearnerProgress(String userId, String languageCode) async {
    try {
      await _database.delete(
        'language_progress',
        where: 'userId = ? AND languageCode = ?',
        whereArgs: [userId, languageCode],
      );

      await _database.delete(
        'learning_history',
        where: 'userId = ? AND languageCode = ?',
        whereArgs: [userId, languageCode],
      );

      await _database.delete(
        'level_assessments',
        where: 'userId = ? AND languageCode = ?',
        whereArgs: [userId, languageCode],
      );

      await _database.delete(
        'skill_assessments',
        where: 'userId = ? AND languageCode = ?',
        whereArgs: [userId, languageCode],
      );

      await _database.delete(
        'learning_paths',
        where: 'userId = ? AND languageCode = ?',
        whereArgs: [userId, languageCode],
      );
    } catch (e) {
      throw CacheFailure('Failed to reset learner progress: $e');
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await _database.delete('learner_profiles');
      await _database.delete('language_progress');
      await _database.delete('learner_achievements');
      await _database.delete('learning_history');
      await _database.delete('study_streaks');
      await _database.delete('level_assessments');
      await _database.delete('skill_assessments');
      await _database.delete('learning_goals');
      await _database.delete('learning_recommendations');
      await _database.delete('learning_preferences');
      await _database.delete('learning_paths');
    } catch (e) {
      throw CacheFailure('Failed to clear all data: $e');
    }
  }
}

/// Learning goal data model
class LearningGoalModel {
  final String id;
  final String userId;
  final String languageCode;
  final String title;
  final String description;
  final GoalType type;
  final double targetValue;
  final double currentValue;
  final double progress;
  final DateTime targetDate;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final Map<String, dynamic> metadata;

  const LearningGoalModel({
    required this.id,
    required this.userId,
    required this.languageCode,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.progress,
    required this.targetDate,
    required this.createdAt,
    this.completedAt,
    required this.isCompleted,
    required this.metadata,
  });

  factory LearningGoalModel.fromJson(Map<String, dynamic> json) {
    return LearningGoalModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      languageCode: json['languageCode'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: GoalType.values.firstWhere((e) => e.name == json['type']),
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      progress: (json['progress'] as num).toDouble(),
      targetDate: DateTime.parse(json['targetDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'languageCode': languageCode,
      'title': title,
      'description': description,
      'type': type.name,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'progress': progress,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isCompleted': isCompleted,
      'metadata': metadata,
    };
  }
}

/// Learning recommendation data model
class LearningRecommendationModel {
  final String id;
  final String userId;
  final String languageCode;
  final String title;
  final String description;
  final RecommendationType type;
  final String contentId;
  final String contentType;
  final double priority;
  final String reason;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final Map<String, dynamic> metadata;

  const LearningRecommendationModel({
    required this.id,
    required this.userId,
    required this.languageCode,
    required this.title,
    required this.description,
    required this.type,
    required this.contentId,
    required this.contentType,
    required this.priority,
    required this.reason,
    required this.createdAt,
    this.completedAt,
    required this.isCompleted,
    required this.metadata,
  });

  factory LearningRecommendationModel.fromJson(Map<String, dynamic> json) {
    return LearningRecommendationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      languageCode: json['languageCode'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: RecommendationType.values.firstWhere((e) => e.name == json['type']),
      contentId: json['contentId'] as String,
      contentType: json['contentType'] as String,
      priority: (json['priority'] as num).toDouble(),
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'languageCode': languageCode,
      'title': title,
      'description': description,
      'type': type.name,
      'contentId': contentId,
      'contentType': contentType,
      'priority': priority,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isCompleted': isCompleted,
      'metadata': metadata,
    };
  }
}
