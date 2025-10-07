import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/learner_entity.dart';
import '../../domain/repositories/learner_repository.dart';
import '../datasources/learner_datasource.dart';
import '../models/learner_model.dart';

/// Implementation of the learner repository
class LearnerRepositoryImpl implements LearnerRepository {
  final LearnerDataSource _localDataSource;

  LearnerRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, LearnerEntity>> getLearnerProfile(
    String userId,
  ) async {
    try {
      final learnerModel = await _localDataSource.getLearnerProfile(userId);
      if (learnerModel == null) {
        return const Left(CacheFailure('Learner profile not found'));
      }
      return Right(learnerModel.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get learner profile: $e'));
    }
  }

  @override
  Future<Either<Failure, LearnerEntity>> updateLearnerProfile(
    LearnerEntity learner,
  ) async {
    try {
      final learnerModel = LearnerModel.fromEntity(learner);
      await _localDataSource.saveLearnerProfile(learnerModel);
      return Right(learner);
    } catch (e) {
      return Left(CacheFailure('Failed to update learner profile: $e'));
    }
  }

  @override
  Future<Either<Failure, LanguageProgress>> getLanguageProgress(
    String userId,
    String languageCode,
  ) async {
    try {
      final progressModel = await _localDataSource.getLanguageProgress(
        userId,
        languageCode,
      );
      if (progressModel == null) {
        return const Left(CacheFailure('Language progress not found'));
      }
      return Right(progressModel.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get language progress: $e'));
    }
  }

  @override
  Future<Either<Failure, LanguageProgress>> updateLanguageProgress(
    String userId,
    String languageCode,
    LanguageProgress progress,
  ) async {
    try {
      final progressModel = LanguageProgressModel.fromEntity(progress);
      await _localDataSource.saveLanguageProgress(
        userId,
        languageCode,
        progressModel,
      );
      return Right(progress);
    } catch (e) {
      return Left(CacheFailure('Failed to update language progress: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Achievement>>> getLearnerAchievements(
    String userId,
  ) async {
    try {
      final achievementModels = await _localDataSource.getLearnerAchievements(
        userId,
      );
      final achievements = achievementModels
          .map((model) => model.toEntity())
          .toList();
      return Right(achievements);
    } catch (e) {
      return Left(CacheFailure('Failed to get learner achievements: $e'));
    }
  }

  @override
  Future<Either<Failure, Achievement>> awardAchievement(
    String userId,
    String achievementId,
  ) async {
    try {
      // This would typically involve creating a new achievement
      // For now, return a mock achievement
      final achievement = Achievement(
        id: achievementId,
        title: 'New Achievement',
        description: 'You earned a new achievement!',
        iconUrl: 'assets/icons/achievement.png',
        type: AchievementType.special,
        points: 100,
        earnedAt: DateTime.now(),
        isUnlocked: true,
      );

      // Save the achievement
      final achievementModel = AchievementModel.fromEntity(achievement);
      final achievements = await _localDataSource.getLearnerAchievements(
        userId,
      );
      achievements.add(achievementModel);
      await _localDataSource.saveLearnerAchievements(userId, achievements);

      return Right(achievement);
    } catch (e) {
      return Left(CacheFailure('Failed to award achievement: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getRecommendedLessons(
    String userId,
    String languageCode,
  ) async {
    try {
      // This would typically involve complex recommendation logic
      // For now, return mock recommendations
      final recommendations = ['lesson_1', 'lesson_2', 'lesson_3'];
      return Right(recommendations);
    } catch (e) {
      return Left(CacheFailure('Failed to get recommended lessons: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLearningStatistics(
    String userId,
  ) async {
    try {
      final statistics = await _localDataSource.getLearningStatistics(userId);
      return Right(statistics);
    } catch (e) {
      return Left(CacheFailure('Failed to get learning statistics: $e'));
    }
  }

  @override
  Future<Either<Failure, LearningPreferences>> updateLearningPreferences(
    String userId,
    LearningPreferences preferences,
  ) async {
    try {
      final preferencesModel = LearningPreferencesModel.fromEntity(preferences);
      await _localDataSource.saveLearningPreferences(userId, preferencesModel);
      return Right(preferences);
    } catch (e) {
      return Left(CacheFailure('Failed to update learning preferences: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> recordLessonCompletion({
    required String userId,
    required String lessonId,
    required String languageCode,
    required int score,
    required int timeSpentMinutes,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      await _localDataSource.recordLessonCompletion(
        userId: userId,
        lessonId: lessonId,
        languageCode: languageCode,
        score: score,
        timeSpentMinutes: timeSpentMinutes,
        metadata: metadata,
      );
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to record lesson completion: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> recordCourseCompletion({
    required String userId,
    required String courseId,
    required String languageCode,
    required int finalScore,
    required int totalTimeSpentMinutes,
  }) async {
    try {
      await _localDataSource.recordCourseCompletion(
        userId: userId,
        courseId: courseId,
        languageCode: languageCode,
        finalScore: finalScore,
        totalTimeSpentMinutes: totalTimeSpentMinutes,
      );
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to record course completion: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getStudyStreak(String userId) async {
    try {
      final streak = await _localDataSource.getStudyStreak(userId);
      return Right(streak);
    } catch (e) {
      return Left(CacheFailure('Failed to get study streak: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> updateStudyStreak(
    String userId,
    DateTime studyDate,
  ) async {
    try {
      await _localDataSource.updateStudyStreak(userId, studyDate);
      final streak = await _localDataSource.getStudyStreak(userId);
      return Right(streak);
    } catch (e) {
      return Left(CacheFailure('Failed to update study streak: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getLevelAssessments(
    String userId,
    String languageCode,
  ) async {
    try {
      final assessments = await _localDataSource.getLevelAssessments(
        userId,
        languageCode,
      );
      return Right(assessments);
    } catch (e) {
      return Left(CacheFailure('Failed to get level assessments: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> saveLevelAssessment({
    required String userId,
    required String languageCode,
    required String level,
    required double score,
    required Map<String, dynamic> assessmentData,
  }) async {
    try {
      await _localDataSource.saveLevelAssessment(
        userId: userId,
        languageCode: languageCode,
        level: level,
        score: score,
        assessmentData: assessmentData,
      );
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to save level assessment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAdaptiveRecommendations(
    String userId,
    String languageCode,
  ) async {
    try {
      // This would typically involve AI-based recommendation logic
      // For now, return mock recommendations
      final recommendations = [
        'adaptive_lesson_1',
        'adaptive_lesson_2',
        'adaptive_lesson_3',
      ];
      return Right(recommendations);
    } catch (e) {
      return Left(CacheFailure('Failed to get adaptive recommendations: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LearningGoal>>> getLearningGoals(
    String userId,
  ) async {
    try {
      final goalModels = await _localDataSource.getLearningGoals(userId);
      final goals = goalModels
          .map((model) => _goalModelToEntity(model))
          .toList();
      return Right(goals);
    } catch (e) {
      return Left(CacheFailure('Failed to get learning goals: $e'));
    }
  }

  @override
  Future<Either<Failure, LearningGoal>> setLearningGoal(
    String userId,
    LearningGoal goal,
  ) async {
    try {
      final goalModel = _goalEntityToModel(goal);
      await _localDataSource.saveLearningGoal(goalModel);
      return Right(goal);
    } catch (e) {
      return Left(CacheFailure('Failed to set learning goal: $e'));
    }
  }

  @override
  Future<Either<Failure, LearningGoal>> updateGoalProgress(
    String userId,
    String goalId,
    double progress,
  ) async {
    try {
      await _localDataSource.updateGoalProgress(userId, goalId, progress);

      // Get the updated goal
      final goals = await _localDataSource.getLearningGoals(userId);
      final goalModel = goals.firstWhere((goal) => goal.id == goalId);
      final updatedGoal = _goalModelToEntity(goalModel);

      return Right(updatedGoal);
    } catch (e) {
      return Left(CacheFailure('Failed to update goal progress: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPerformanceAnalytics(
    String userId,
    String languageCode,
  ) async {
    try {
      final analytics = await _localDataSource.getPerformanceAnalytics(
        userId,
        languageCode,
      );
      return Right(analytics);
    } catch (e) {
      return Left(CacheFailure('Failed to get performance analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStudyPatterns(
    String userId,
  ) async {
    try {
      final patterns = await _localDataSource.getStudyPatterns(userId);
      return Right(patterns);
    } catch (e) {
      return Left(CacheFailure('Failed to get study patterns: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPeerComparison(
    String userId,
    String languageCode,
  ) async {
    try {
      final comparison = await _localDataSource.getPeerComparison(
        userId,
        languageCode,
      );
      return Right(comparison);
    } catch (e) {
      return Left(CacheFailure('Failed to get peer comparison: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> resetLearnerProgress(
    String userId,
    String languageCode,
  ) async {
    try {
      await _localDataSource.resetLearnerProgress(userId, languageCode);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to reset learner progress: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getLearningHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final history = await _localDataSource.getLearningHistory(
        userId,
        limit: limit,
      );
      return Right(history);
    } catch (e) {
      return Left(CacheFailure('Failed to get learning history: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCurrentLearningPath(
    String userId,
    String languageCode,
  ) async {
    try {
      final path = await _localDataSource.getCurrentLearningPath(
        userId,
        languageCode,
      );
      return Right(path);
    } catch (e) {
      return Left(CacheFailure('Failed to get current learning path: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateLearningPath(
    String userId,
    String languageCode,
    List<String> lessonIds,
  ) async {
    try {
      await _localDataSource.updateLearningPath(
        userId,
        languageCode,
        lessonIds,
      );
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to update learning path: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getSkillAssessments(
    String userId,
    String languageCode,
  ) async {
    try {
      final assessments = await _localDataSource.getSkillAssessments(
        userId,
        languageCode,
      );
      return Right(assessments);
    } catch (e) {
      return Left(CacheFailure('Failed to get skill assessments: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateSkillAssessment(
    String userId,
    String languageCode,
    String skill,
    double score,
  ) async {
    try {
      await _localDataSource.updateSkillAssessment(
        userId,
        languageCode,
        skill,
        score,
      );
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to update skill assessment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LearningRecommendation>>>
  getLearningRecommendations(String userId, String languageCode) async {
    try {
      final recommendationModels = await _localDataSource
          .getLearningRecommendations(userId, languageCode);
      final recommendations = recommendationModels
          .map((model) => _recommendationModelToEntity(model))
          .toList();
      return Right(recommendations);
    } catch (e) {
      return Left(CacheFailure('Failed to get learning recommendations: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> completeLearningRecommendation(
    String userId,
    String recommendationId,
  ) async {
    try {
      await _localDataSource.completeLearningRecommendation(
        userId,
        recommendationId,
      );
      return const Right(true);
    } catch (e) {
      return Left(
        CacheFailure('Failed to complete learning recommendation: $e'),
      );
    }
  }

  // Helper methods to convert between models and entities
  LearningGoal _goalModelToEntity(LearningGoalModel model) {
    return LearningGoal(
      id: model.id,
      userId: model.userId,
      languageCode: model.languageCode,
      title: model.title,
      description: model.description,
      type: model.type,
      targetValue: model.targetValue,
      currentValue: model.currentValue,
      progress: model.progress,
      targetDate: model.targetDate,
      createdAt: model.createdAt,
      completedAt: model.completedAt,
      isCompleted: model.isCompleted,
      metadata: model.metadata,
    );
  }

  LearningGoalModel _goalEntityToModel(LearningGoal entity) {
    return LearningGoalModel(
      id: entity.id,
      userId: entity.userId,
      languageCode: entity.languageCode,
      title: entity.title,
      description: entity.description,
      type: entity.type,
      targetValue: entity.targetValue,
      currentValue: entity.currentValue,
      progress: entity.progress,
      targetDate: entity.targetDate,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
      isCompleted: entity.isCompleted,
      metadata: entity.metadata,
    );
  }

  LearningRecommendation _recommendationModelToEntity(
    LearningRecommendationModel model,
  ) {
    return LearningRecommendation(
      id: model.id,
      userId: model.userId,
      languageCode: model.languageCode,
      title: model.title,
      description: model.description,
      type: model.type,
      contentId: model.contentId,
      contentType: model.contentType,
      priority: model.priority,
      reason: model.reason,
      createdAt: model.createdAt,
      completedAt: model.completedAt,
      isCompleted: model.isCompleted,
      metadata: model.metadata,
    );
  }
}
