import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/learner_entity.dart';

/// Repository interface for learner management
abstract class LearnerRepository {
  /// Get learner profile by user ID
  Future<Either<Failure, LearnerEntity>> getLearnerProfile(String userId);

  /// Update learner profile
  Future<Either<Failure, LearnerEntity>> updateLearnerProfile(
    LearnerEntity learner,
  );

  /// Get learner's progress for a specific language
  Future<Either<Failure, LanguageProgress>> getLanguageProgress(
    String userId,
    String languageCode,
  );

  /// Update learner's progress for a specific language
  Future<Either<Failure, LanguageProgress>> updateLanguageProgress(
    String userId,
    String languageCode,
    LanguageProgress progress,
  );

  /// Get learner's achievements
  Future<Either<Failure, List<Achievement>>> getLearnerAchievements(
    String userId,
  );

  /// Award achievement to learner
  Future<Either<Failure, Achievement>> awardAchievement(
    String userId,
    String achievementId,
  );

  /// Get recommended lessons for learner
  Future<Either<Failure, List<String>>> getRecommendedLessons(
    String userId,
    String languageCode,
  );

  /// Get learner's learning statistics
  Future<Either<Failure, Map<String, dynamic>>> getLearningStatistics(
    String userId,
  );

  /// Update learner's learning preferences
  Future<Either<Failure, LearningPreferences>> updateLearningPreferences(
    String userId,
    LearningPreferences preferences,
  );

  /// Record lesson completion
  Future<Either<Failure, bool>> recordLessonCompletion({
    required String userId,
    required String lessonId,
    required String languageCode,
    required int score,
    required int timeSpentMinutes,
    required Map<String, dynamic> metadata,
  });

  /// Record course completion
  Future<Either<Failure, bool>> recordCourseCompletion({
    required String userId,
    required String courseId,
    required String languageCode,
    required int finalScore,
    required int totalTimeSpentMinutes,
  });

  /// Get learner's study streak
  Future<Either<Failure, int>> getStudyStreak(String userId);

  /// Update study streak
  Future<Either<Failure, int>> updateStudyStreak(
    String userId,
    DateTime studyDate,
  );

  /// Get learner's level assessment results
  Future<Either<Failure, List<Map<String, dynamic>>>> getLevelAssessments(
    String userId,
    String languageCode,
  );

  /// Save level assessment result
  Future<Either<Failure, bool>> saveLevelAssessment({
    required String userId,
    required String languageCode,
    required String level,
    required double score,
    required Map<String, dynamic> assessmentData,
  });

  /// Get adaptive learning recommendations
  Future<Either<Failure, List<String>>> getAdaptiveRecommendations(
    String userId,
    String languageCode,
  );

  /// Get learner's learning goals
  Future<Either<Failure, List<LearningGoal>>> getLearningGoals(String userId);

  /// Set learning goal
  Future<Either<Failure, LearningGoal>> setLearningGoal(
    String userId,
    LearningGoal goal,
  );

  /// Update learning goal progress
  Future<Either<Failure, LearningGoal>> updateGoalProgress(
    String userId,
    String goalId,
    double progress,
  );

  /// Get learner's performance analytics
  Future<Either<Failure, Map<String, dynamic>>> getPerformanceAnalytics(
    String userId,
    String languageCode,
  );

  /// Get learner's study patterns
  Future<Either<Failure, Map<String, dynamic>>> getStudyPatterns(String userId);

  /// Get learner's progress comparison with peers
  Future<Either<Failure, Map<String, dynamic>>> getPeerComparison(
    String userId,
    String languageCode,
  );

  /// Reset learner's progress (for testing or account reset)
  Future<Either<Failure, bool>> resetLearnerProgress(
    String userId,
    String languageCode,
  );

  /// Get learner's learning history
  Future<Either<Failure, List<Map<String, dynamic>>>> getLearningHistory(
    String userId, {
    int limit = 50,
  });

  /// Get learner's current learning path
  Future<Either<Failure, List<String>>> getCurrentLearningPath(
    String userId,
    String languageCode,
  );

  /// Update learning path
  Future<Either<Failure, bool>> updateLearningPath(
    String userId,
    String languageCode,
    List<String> lessonIds,
  );

  /// Get learner's skill assessment results
  Future<Either<Failure, Map<String, double>>> getSkillAssessments(
    String userId,
    String languageCode,
  );

  /// Update skill assessment
  Future<Either<Failure, bool>> updateSkillAssessment(
    String userId,
    String languageCode,
    String skill,
    double score,
  );

  /// Get learner's learning recommendations based on performance
  Future<Either<Failure, List<LearningRecommendation>>>
  getLearningRecommendations(String userId, String languageCode);

  /// Mark learning recommendation as completed
  Future<Either<Failure, bool>> completeLearningRecommendation(
    String userId,
    String recommendationId,
  );
}

/// Learning goal entity
class LearningGoal {
  final String id;
  final String userId;
  final String languageCode;
  final String title;
  final String description;
  final GoalType type;
  final double targetValue;
  final double currentValue;
  final double progress; // 0.0 to 1.0
  final DateTime targetDate;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final Map<String, dynamic> metadata;

  const LearningGoal({
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

  // Note: This class doesn't extend Equatable, so no props getter needed
}

/// Learning recommendation entity
class LearningRecommendation {
  final String id;
  final String userId;
  final String languageCode;
  final String title;
  final String description;
  final RecommendationType type;
  final String contentId; // lesson ID, course ID, etc.
  final String contentType; // lesson, course, exercise, etc.
  final double priority; // 0.0 to 1.0
  final String reason;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final Map<String, dynamic> metadata;

  const LearningRecommendation({
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

  // Note: This class doesn't extend Equatable, so no props getter needed
}

/// Goal types
enum GoalType {
  lessonsCompleted,
  studyTime,
  accuracy,
  streak,
  level,
  vocabulary,
  grammar,
  pronunciation,
  conversation,
}

/// Recommendation types
enum RecommendationType {
  lesson,
  course,
  exercise,
  practice,
  review,
  assessment,
  challenge,
}
