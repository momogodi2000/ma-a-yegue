import 'package:equatable/equatable.dart';

/// Quiz entity representing a complete assessment
class QuizEntity extends Equatable {
  final String id;
  final String lessonId;
  final String languageCode;
  final String title;
  final String description;
  final List<QuestionEntity> questions;
  final int timeLimitMinutes; // 0 = no time limit
  final int passingScore; // percentage 0-100
  final QuizDifficulty difficulty;
  final List<String> skillsTested; // e.g., ['vocabulary', 'grammar', 'listening']
  final bool isAdaptive; // adjusts difficulty based on performance
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuizEntity({
    required this.id,
    required this.lessonId,
    required this.languageCode,
    required this.title,
    required this.description,
    required this.questions,
    required this.timeLimitMinutes,
    required this.passingScore,
    required this.difficulty,
    required this.skillsTested,
    required this.isAdaptive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate total possible points
  int get totalPoints => questions.fold(0, (sum, q) => sum + q.points);

  /// Get question count
  int get questionCount => questions.length;

  /// Check if quiz is timed
  bool get isTimed => timeLimitMinutes > 0;

  /// Get estimated completion time in minutes
  int get estimatedTimeMinutes {
    // Rough estimate: 1 minute per question + 2 minutes for review
    return (questions.length * 1) + 2;
  }

  @override
  List<Object?> get props => [
        id,
        lessonId,
        languageCode,
        title,
        description,
        questions,
        timeLimitMinutes,
        passingScore,
        difficulty,
        skillsTested,
        isAdaptive,
        createdAt,
        updatedAt,
      ];

  QuizEntity copyWith({
    String? id,
    String? lessonId,
    String? languageCode,
    String? title,
    String? description,
    List<QuestionEntity>? questions,
    int? timeLimitMinutes,
    int? passingScore,
    QuizDifficulty? difficulty,
    List<String>? skillsTested,
    bool? isAdaptive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuizEntity(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      languageCode: languageCode ?? this.languageCode,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      passingScore: passingScore ?? this.passingScore,
      difficulty: difficulty ?? this.difficulty,
      skillsTested: skillsTested ?? this.skillsTested,
      isAdaptive: isAdaptive ?? this.isAdaptive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Quiz difficulty levels
enum QuizDifficulty {
  beginner,
  intermediate,
  advanced,
  expert;

  String get displayName {
    switch (this) {
      case QuizDifficulty.beginner:
        return 'Débutant';
      case QuizDifficulty.intermediate:
        return 'Intermédiaire';
      case QuizDifficulty.advanced:
        return 'Avancé';
      case QuizDifficulty.expert:
        return 'Expert';
    }
  }

  int get levelValue {
    switch (this) {
      case QuizDifficulty.beginner:
        return 1;
      case QuizDifficulty.intermediate:
        return 2;
      case QuizDifficulty.advanced:
        return 3;
      case QuizDifficulty.expert:
        return 4;
    }
  }
}

/// Individual question entity
class QuestionEntity extends Equatable {
  final String id;
  final String quizId;
  final QuestionType type;
  final String question;
  final List<String> options; // for multiple choice
  final String correctAnswer;
  final String explanation; // why the answer is correct
  final List<String> hints; // optional hints
  final int points;
  final int timeLimitSeconds; // 0 = no limit
  final String? audioUrl; // for audio questions
  final String? imageUrl; // for visual questions
  final Map<String, dynamic>? metadata; // additional data

  const QuestionEntity({
    required this.id,
    required this.quizId,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.hints,
    required this.points,
    required this.timeLimitSeconds,
    this.audioUrl,
    this.imageUrl,
    this.metadata,
  });

  /// Check if question has media
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Check if question is timed
  bool get isTimed => timeLimitSeconds > 0;

  /// Get formatted options for display
  List<String> get formattedOptions {
    if (type == QuestionType.multipleChoice) {
      return options.map((option) => option.trim()).toList();
    }
    return options;
  }

  /// Validate answer format based on question type
  bool isValidAnswer(String answer) {
    switch (type) {
      case QuestionType.multipleChoice:
        return options.contains(answer);
      case QuestionType.fillInBlank:
        return answer.trim().isNotEmpty;
      case QuestionType.audioComprehension:
        return options.contains(answer);
      case QuestionType.trueFalse:
        return ['true', 'false', 'vrai', 'faux'].contains(answer.toLowerCase());
    }
  }

  /// Check if answer is correct (case insensitive for text answers)
  bool isCorrect(String answer) {
    final normalizedAnswer = answer.trim().toLowerCase();
    final normalizedCorrect = correctAnswer.trim().toLowerCase();

    switch (type) {
      case QuestionType.multipleChoice:
      case QuestionType.audioComprehension:
        return normalizedAnswer == normalizedCorrect;
      case QuestionType.fillInBlank:
        // Allow some flexibility for fill-in-blank
        return _isFillInBlankCorrect(normalizedAnswer, normalizedCorrect);
      case QuestionType.trueFalse:
        return normalizedAnswer == normalizedCorrect;
    }
  }

  /// Flexible matching for fill-in-blank questions
  bool _isFillInBlankCorrect(String userAnswer, String correctAnswer) {
    // Exact match
    if (userAnswer == correctAnswer) return true;

    // Remove accents and special characters for more flexible matching
    final normalizedUser = _normalizeText(userAnswer);
    final normalizedCorrect = _normalizeText(correctAnswer);

    return normalizedUser == normalizedCorrect;
  }

  /// Normalize text for flexible matching
  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ') // normalize spaces
        .trim();
  }

  @override
  List<Object?> get props => [
        id,
        quizId,
        type,
        question,
        options,
        correctAnswer,
        explanation,
        hints,
        points,
        timeLimitSeconds,
        audioUrl,
        imageUrl,
        metadata,
      ];

  QuestionEntity copyWith({
    String? id,
    String? quizId,
    QuestionType? type,
    String? question,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    List<String>? hints,
    int? points,
    int? timeLimitSeconds,
    String? audioUrl,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return QuestionEntity(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      type: type ?? this.type,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      hints: hints ?? this.hints,
      points: points ?? this.points,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Question types supported
enum QuestionType {
  multipleChoice, // 4 options, single correct
  fillInBlank, // text input
  audioComprehension, // listen and choose/answer
  trueFalse; // true/false questions

  String get displayName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'Choix multiple';
      case QuestionType.fillInBlank:
        return 'Compléter';
      case QuestionType.audioComprehension:
        return 'Compréhension audio';
      case QuestionType.trueFalse:
        return 'Vrai/Faux';
    }
  }

  String get iconName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'list';
      case QuestionType.fillInBlank:
        return 'edit';
      case QuestionType.audioComprehension:
        return 'volume_up';
      case QuestionType.trueFalse:
        return 'check_circle';
    }
  }
}

/// User's answer to a question
class QuestionAnswer extends Equatable {
  final String questionId;
  final String answer;
  final bool isCorrect;
  final int timeSpentSeconds;
  final int pointsEarned;
  final DateTime answeredAt;

  const QuestionAnswer({
    required this.questionId,
    required this.answer,
    required this.isCorrect,
    required this.timeSpentSeconds,
    required this.pointsEarned,
    required this.answeredAt,
  });

  @override
  List<Object?> get props => [
        questionId,
        answer,
        isCorrect,
        timeSpentSeconds,
        pointsEarned,
        answeredAt,
      ];
}

/// Complete quiz attempt/result
class QuizAttempt extends Equatable {
  final String id;
  final String userId;
  final String quizId;
  final List<QuestionAnswer> answers;
  final int totalScore;
  final int maxScore;
  final double percentage;
  final bool passed;
  final int timeSpentSeconds;
  final DateTime startedAt;
  final DateTime completedAt;
  final Map<String, dynamic>? metadata;

  const QuizAttempt({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.answers,
    required this.totalScore,
    required this.maxScore,
    required this.percentage,
    required this.passed,
    required this.timeSpentSeconds,
    required this.startedAt,
    required this.completedAt,
    this.metadata,
  });

  /// Calculate accuracy percentage
  double get accuracy => answers.isEmpty ? 0.0 : (answers.where((a) => a.isCorrect).length / answers.length) * 100;

  /// Get average time per question
  double get averageTimePerQuestion => answers.isEmpty ? 0.0 : timeSpentSeconds / answers.length;

  /// Get questions answered correctly
  int get correctAnswers => answers.where((a) => a.isCorrect).length;

  /// Get total questions
  int get totalQuestions => answers.length;

  @override
  List<Object?> get props => [
        id,
        userId,
        quizId,
        answers,
        totalScore,
        maxScore,
        percentage,
        passed,
        timeSpentSeconds,
        startedAt,
        completedAt,
        metadata,
      ];

  QuizAttempt copyWith({
    String? id,
    String? userId,
    String? quizId,
    List<QuestionAnswer>? answers,
    int? totalScore,
    int? maxScore,
    double? percentage,
    bool? passed,
    int? timeSpentSeconds,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return QuizAttempt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      quizId: quizId ?? this.quizId,
      answers: answers ?? this.answers,
      totalScore: totalScore ?? this.totalScore,
      maxScore: maxScore ?? this.maxScore,
      percentage: percentage ?? this.percentage,
      passed: passed ?? this.passed,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
