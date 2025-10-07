import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/learner_entity.dart';
import '../repositories/learner_repository.dart';

/// Get learner profile use case
class GetLearnerProfile {
  final LearnerRepository repository;

  GetLearnerProfile(this.repository);

  Future<Either<Failure, LearnerEntity>> call(String userId) async {
    return await repository.getLearnerProfile(userId);
  }
}

/// Update learner profile use case
class UpdateLearnerProfile {
  final LearnerRepository repository;

  UpdateLearnerProfile(this.repository);

  Future<Either<Failure, LearnerEntity>> call(LearnerEntity learner) async {
    return await repository.updateLearnerProfile(learner);
  }
}

/// Get language progress use case
class GetLanguageProgress {
  final LearnerRepository repository;

  GetLanguageProgress(this.repository);

  Future<Either<Failure, LanguageProgress>> call(
    String userId,
    String languageCode,
  ) async {
    return await repository.getLanguageProgress(userId, languageCode);
  }
}

/// Update language progress use case
class UpdateLanguageProgress {
  final LearnerRepository repository;

  UpdateLanguageProgress(this.repository);

  Future<Either<Failure, LanguageProgress>> call(
    String userId,
    String languageCode,
    LanguageProgress progress,
  ) async {
    return await repository.updateLanguageProgress(
      userId,
      languageCode,
      progress,
    );
  }
}

/// Record lesson completion use case
class RecordLessonCompletion {
  final LearnerRepository repository;

  RecordLessonCompletion(this.repository);

  Future<Either<Failure, bool>> call({
    required String userId,
    required String lessonId,
    required String languageCode,
    required int score,
    required int timeSpentMinutes,
    required Map<String, dynamic> metadata,
  }) async {
    return await repository.recordLessonCompletion(
      userId: userId,
      lessonId: lessonId,
      languageCode: languageCode,
      score: score,
      timeSpentMinutes: timeSpentMinutes,
      metadata: metadata,
    );
  }
}

/// Record course completion use case
class RecordCourseCompletion {
  final LearnerRepository repository;

  RecordCourseCompletion(this.repository);

  Future<Either<Failure, bool>> call({
    required String userId,
    required String courseId,
    required String languageCode,
    required int finalScore,
    required int totalTimeSpentMinutes,
  }) async {
    return await repository.recordCourseCompletion(
      userId: userId,
      courseId: courseId,
      languageCode: languageCode,
      finalScore: finalScore,
      totalTimeSpentMinutes: totalTimeSpentMinutes,
    );
  }
}

/// Get recommended lessons use case
class GetRecommendedLessons {
  final LearnerRepository repository;

  GetRecommendedLessons(this.repository);

  Future<Either<Failure, List<String>>> call(
    String userId,
    String languageCode,
  ) async {
    return await repository.getRecommendedLessons(userId, languageCode);
  }
}

/// Get learning statistics use case
class GetLearningStatistics {
  final LearnerRepository repository;

  GetLearningStatistics(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    return await repository.getLearningStatistics(userId);
  }
}

/// Get learner achievements use case
class GetLearnerAchievements {
  final LearnerRepository repository;

  GetLearnerAchievements(this.repository);

  Future<Either<Failure, List<Achievement>>> call(String userId) async {
    return await repository.getLearnerAchievements(userId);
  }
}

/// Award achievement use case
class AwardAchievement {
  final LearnerRepository repository;

  AwardAchievement(this.repository);

  Future<Either<Failure, Achievement>> call(
    String userId,
    String achievementId,
  ) async {
    return await repository.awardAchievement(userId, achievementId);
  }
}

/// Update study streak use case
class UpdateStudyStreak {
  final LearnerRepository repository;

  UpdateStudyStreak(this.repository);

  Future<Either<Failure, int>> call(String userId, DateTime studyDate) async {
    return await repository.updateStudyStreak(userId, studyDate);
  }
}

/// Get study streak use case
class GetStudyStreak {
  final LearnerRepository repository;

  GetStudyStreak(this.repository);

  Future<Either<Failure, int>> call(String userId) async {
    return await repository.getStudyStreak(userId);
  }
}

/// Save level assessment use case
class SaveLevelAssessment {
  final LearnerRepository repository;

  SaveLevelAssessment(this.repository);

  Future<Either<Failure, bool>> call({
    required String userId,
    required String languageCode,
    required String level,
    required double score,
    required Map<String, dynamic> assessmentData,
  }) async {
    return await repository.saveLevelAssessment(
      userId: userId,
      languageCode: languageCode,
      level: level,
      score: score,
      assessmentData: assessmentData,
    );
  }
}

/// Get adaptive recommendations use case
class GetAdaptiveRecommendations {
  final LearnerRepository repository;

  GetAdaptiveRecommendations(this.repository);

  Future<Either<Failure, List<String>>> call(
    String userId,
    String languageCode,
  ) async {
    return await repository.getAdaptiveRecommendations(userId, languageCode);
  }
}

/// Get learning goals use case
class GetLearningGoals {
  final LearnerRepository repository;

  GetLearningGoals(this.repository);

  Future<Either<Failure, List<LearningGoal>>> call(String userId) async {
    return await repository.getLearningGoals(userId);
  }
}

/// Set learning goal use case
class SetLearningGoal {
  final LearnerRepository repository;

  SetLearningGoal(this.repository);

  Future<Either<Failure, LearningGoal>> call(
    String userId,
    LearningGoal goal,
  ) async {
    return await repository.setLearningGoal(userId, goal);
  }
}

/// Update goal progress use case
class UpdateGoalProgress {
  final LearnerRepository repository;

  UpdateGoalProgress(this.repository);

  Future<Either<Failure, LearningGoal>> call(
    String userId,
    String goalId,
    double progress,
  ) async {
    return await repository.updateGoalProgress(userId, goalId, progress);
  }
}

/// Get performance analytics use case
class GetPerformanceAnalytics {
  final LearnerRepository repository;

  GetPerformanceAnalytics(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String userId,
    String languageCode,
  ) async {
    return await repository.getPerformanceAnalytics(userId, languageCode);
  }
}

/// Get study patterns use case
class GetStudyPatterns {
  final LearnerRepository repository;

  GetStudyPatterns(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    return await repository.getStudyPatterns(userId);
  }
}

/// Get peer comparison use case
class GetPeerComparison {
  final LearnerRepository repository;

  GetPeerComparison(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String userId,
    String languageCode,
  ) async {
    return await repository.getPeerComparison(userId, languageCode);
  }
}

/// Get learning history use case
class GetLearningHistory {
  final LearnerRepository repository;

  GetLearningHistory(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    String userId, {
    int limit = 50,
  }) async {
    return await repository.getLearningHistory(userId, limit: limit);
  }
}

/// Get current learning path use case
class GetCurrentLearningPath {
  final LearnerRepository repository;

  GetCurrentLearningPath(this.repository);

  Future<Either<Failure, List<String>>> call(
    String userId,
    String languageCode,
  ) async {
    return await repository.getCurrentLearningPath(userId, languageCode);
  }
}

/// Update learning path use case
class UpdateLearningPath {
  final LearnerRepository repository;

  UpdateLearningPath(this.repository);

  Future<Either<Failure, bool>> call(
    String userId,
    String languageCode,
    List<String> lessonIds,
  ) async {
    return await repository.updateLearningPath(userId, languageCode, lessonIds);
  }
}

/// Get skill assessments use case
class GetSkillAssessments {
  final LearnerRepository repository;

  GetSkillAssessments(this.repository);

  Future<Either<Failure, Map<String, double>>> call(
    String userId,
    String languageCode,
  ) async {
    return await repository.getSkillAssessments(userId, languageCode);
  }
}

/// Update skill assessment use case
class UpdateSkillAssessment {
  final LearnerRepository repository;

  UpdateSkillAssessment(this.repository);

  Future<Either<Failure, bool>> call(
    String userId,
    String languageCode,
    String skill,
    double score,
  ) async {
    return await repository.updateSkillAssessment(
      userId,
      languageCode,
      skill,
      score,
    );
  }
}

/// Get learning recommendations use case
class GetLearningRecommendations {
  final LearnerRepository repository;

  GetLearningRecommendations(this.repository);

  Future<Either<Failure, List<LearningRecommendation>>> call(
    String userId,
    String languageCode,
  ) async {
    return await repository.getLearningRecommendations(userId, languageCode);
  }
}

/// Complete learning recommendation use case
class CompleteLearningRecommendation {
  final LearnerRepository repository;

  CompleteLearningRecommendation(this.repository);

  Future<Either<Failure, bool>> call(
    String userId,
    String recommendationId,
  ) async {
    return await repository.completeLearningRecommendation(
      userId,
      recommendationId,
    );
  }
}

/// Update learning preferences use case
class UpdateLearningPreferences {
  final LearnerRepository repository;

  UpdateLearningPreferences(this.repository);

  Future<Either<Failure, LearningPreferences>> call(
    String userId,
    LearningPreferences preferences,
  ) async {
    return await repository.updateLearningPreferences(userId, preferences);
  }
}

/// Reset learner progress use case
class ResetLearnerProgress {
  final LearnerRepository repository;

  ResetLearnerProgress(this.repository);

  Future<Either<Failure, bool>> call(String userId, String languageCode) async {
    return await repository.resetLearnerProgress(userId, languageCode);
  }
}
