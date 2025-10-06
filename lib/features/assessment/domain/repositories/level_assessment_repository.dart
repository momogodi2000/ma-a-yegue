import '../entities/level_assessment_entity.dart';

/// Repository interface for level assessments
abstract class LevelAssessmentRepository {
  /// Start a new level assessment
  Future<LevelAssessmentEntity> startLevelAssessment({
    required String userId,
    required String languageCode,
    required String currentLevel,
    required String targetLevel,
  });

  /// Get questions for level assessment
  Future<List<AssessmentQuestionEntity>> getAssessmentQuestions({
    required String languageCode,
    required String level,
    required int questionCount,
  });

  /// Submit answer for a question
  Future<void> submitAnswer({
    required String assessmentId,
    required String questionId,
    required String answer,
  });

  /// Complete assessment and get result
  Future<AssessmentResult> completeAssessment(String assessmentId);

  /// Get user's assessment history
  Future<List<LevelAssessmentEntity>> getUserAssessmentHistory(String userId);

  /// Get current user level for a language
  Future<String> getCurrentUserLevel({
    required String userId,
    required String languageCode,
  });

  /// Update user level after successful assessment
  Future<void> updateUserLevel({
    required String userId,
    required String languageCode,
    required String newLevel,
  });
}