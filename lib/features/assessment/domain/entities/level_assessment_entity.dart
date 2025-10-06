/// Level assessment entity
class LevelAssessmentEntity {
  final String id;
  final String userId;
  final String languageCode;
  final String currentLevel;
  final String targetLevel;
  final List<AssessmentQuestionEntity> questions;
  final DateTime startedAt;
  final DateTime? completedAt;
  final double? score;
  final bool isCompleted;
  final AssessmentResult? result;

  const LevelAssessmentEntity({
    required this.id,
    required this.userId,
    required this.languageCode,
    required this.currentLevel,
    required this.targetLevel,
    required this.questions,
    required this.startedAt,
    this.completedAt,
    this.score,
    this.isCompleted = false,
    this.result,
  });
}

/// Assessment question entity
class AssessmentQuestionEntity {
  final String id;
  final String type; // 'multiple_choice', 'translation', 'audio', 'speaking'
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? userAnswer;
  final int points;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'

  const AssessmentQuestionEntity({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.userAnswer,
    required this.points,
    required this.difficulty,
  });
}

/// Assessment result entity
class AssessmentResult {
  final double totalScore;
  final double percentage;
  final String recommendedLevel;
  final bool levelPassed;
  final List<String> strengths;
  final List<String> weaknesses;
  final String feedback;

  const AssessmentResult({
    required this.totalScore,
    required this.percentage,
    required this.recommendedLevel,
    required this.levelPassed,
    required this.strengths,
    required this.weaknesses,
    required this.feedback,
  });
}