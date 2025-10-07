import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:maa_yegue/features/quiz/domain/entities/quiz_entity.dart';
import 'package:maa_yegue/features/lessons/data/services/progress_tracking_service.dart';
import 'package:maa_yegue/core/database/unified_database_service.dart';

/// Service for managing quiz/assessment functionality
///
/// HYBRID ARCHITECTURE:
/// - Quiz data stored in SQLite (cameroon_languages.db)
/// - Progress/scores stored in SQLite (user_progress table)
/// - No Firestore usage for data storage
class QuizService {
  final ProgressTrackingService _progressService;
  final UnifiedDatabaseService _database = UnifiedDatabaseService.instance;

  // In-memory cache for active quiz attempts
  final Map<String, QuizAttempt> _activeAttempts = {};

  QuizService(this._progressService);

  /// Get quiz for a specific lesson
  Future<QuizEntity?> getQuizForLesson({
    required String lessonId,
    required String languageCode,
  }) async {
    try {
      // Get quiz from SQLite (cameroon_languages.db)
      final quizzes = await _database.getQuizzesByLanguageAndLesson(
        languageId: languageCode.toUpperCase().substring(
          0,
          3,
        ), // EWO, DUA, etc.
        lessonId: int.tryParse(lessonId),
      );

      if (quizzes.isNotEmpty) {
        return await _quizFromSQLite(quizzes.first);
      }

      // Fallback to sample quiz for development
      return _createSampleQuiz(lessonId, languageCode);
    } catch (e) {
      debugPrint('Error getting quiz: $e');
      return null;
    }
  }

  /// Start a quiz attempt
  Future<String> startQuizAttempt({
    required String userId,
    required String quizId,
  }) async {
    final attemptId =
        '${userId}_${quizId}_${DateTime.now().millisecondsSinceEpoch}';

    final attempt = QuizAttempt(
      id: attemptId,
      userId: userId,
      quizId: quizId,
      answers: const [],
      totalScore: 0,
      maxScore: 0,
      percentage: 0.0,
      passed: false,
      timeSpentSeconds: 0,
      startedAt: DateTime.now(),
      completedAt: DateTime.now(), // Will be updated when completed
    );

    _activeAttempts[attemptId] = attempt;

    // Record quiz start in progress tracking
    await _progressService.updateSkillProgress(
      userId: userId,
      languageCode: 'yemba', // TODO: Get from quiz
      skillName: 'assessment',
      proficiencyScore: 0, // Will be updated as quiz progresses
    );

    debugPrint('✅ Quiz attempt started: $attemptId');
    return attemptId;
  }

  /// Submit answer for a question
  Future<bool> submitAnswer({
    required String attemptId,
    required QuestionEntity question,
    required String answer,
    required int timeSpentSeconds,
  }) async {
    final attempt = _activeAttempts[attemptId];
    if (attempt == null) {
      debugPrint('⚠️ Quiz attempt not found: $attemptId');
      return false;
    }

    final isCorrect = question.isCorrect(answer);
    final pointsEarned = isCorrect ? question.points : 0;

    final questionAnswer = QuestionAnswer(
      questionId: question.id,
      answer: answer,
      isCorrect: isCorrect,
      timeSpentSeconds: timeSpentSeconds,
      pointsEarned: pointsEarned,
      answeredAt: DateTime.now(),
    );

    // Update attempt with new answer
    final updatedAnswers = List<QuestionAnswer>.from(attempt.answers)
      ..add(questionAnswer);
    final updatedScore = attempt.totalScore + pointsEarned;

    _activeAttempts[attemptId] = attempt.copyWith(
      answers: updatedAnswers,
      totalScore: updatedScore,
    );

    debugPrint(
      '📝 Answer submitted: ${question.id} - ${isCorrect ? 'Correct' : 'Incorrect'} (+$pointsEarned points)',
    );

    return isCorrect;
  }

  /// Complete quiz attempt
  Future<QuizAttempt?> completeQuizAttempt({
    required String attemptId,
    required QuizEntity quiz,
  }) async {
    final attempt = _activeAttempts[attemptId];
    if (attempt == null) {
      debugPrint('⚠️ Quiz attempt not found: $attemptId');
      return null;
    }

    final completedAt = DateTime.now();
    final timeSpent = completedAt.difference(attempt.startedAt).inSeconds;

    final percentage = quiz.totalPoints > 0
        ? (attempt.totalScore / quiz.totalPoints) * 100
        : 0.0;
    final passed = percentage >= quiz.passingScore;

    final completedAttempt = attempt.copyWith(
      maxScore: quiz.totalPoints,
      percentage: percentage,
      passed: passed,
      timeSpentSeconds: timeSpent,
      completedAt: completedAt,
    );

    // Save to database
    await _saveQuizAttempt(completedAttempt);

    // Update progress tracking
    await _updateProgressAfterQuiz(completedAttempt, quiz);

    // Remove from active attempts
    _activeAttempts.remove(attemptId);

    debugPrint(
      '🎉 Quiz completed: ${completedAttempt.totalScore}/${completedAttempt.maxScore} (${percentage.toStringAsFixed(1)}%) - ${passed ? 'PASSED' : 'FAILED'}',
    );

    return completedAttempt;
  }

  /// Get quiz attempt results
  Future<QuizAttempt?> getQuizAttempt(String attemptId) async {
    // Check active attempts first
    if (_activeAttempts.containsKey(attemptId)) {
      return _activeAttempts[attemptId];
    }

    // Check database
    return await _loadQuizAttempt(attemptId);
  }

  /// Get user's quiz history
  Future<List<QuizAttempt>> getUserQuizHistory({
    required String userId,
    String? languageCode,
    int limit = 20,
  }) async {
    final db = await _database.database;

    String whereClause = 'user_id = ?';
    List<String> whereArgs = [userId];

    if (languageCode != null) {
      whereClause += ' AND quiz_id LIKE ?';
      whereArgs.add('%$languageCode%');
    }

    final results = await db.query(
      'quiz_attempts',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'completed_at DESC',
      limit: limit,
    );

    return results.map((row) => _quizAttemptFromDb(row)).toList();
  }

  /// Get quiz statistics for a user
  Future<Map<String, dynamic>> getQuizStatistics({
    required String userId,
    String? languageCode,
  }) async {
    final history = await getUserQuizHistory(
      userId: userId,
      languageCode: languageCode,
      limit: 100, // Get more for statistics
    );

    if (history.isEmpty) {
      return {
        'totalQuizzes': 0,
        'averageScore': 0.0,
        'passRate': 0.0,
        'totalTimeSpent': 0,
        'bestScore': 0,
        'recentPerformance': [],
      };
    }

    final totalQuizzes = history.length;
    final passedQuizzes = history.where((q) => q.passed).length;
    final passRate = (passedQuizzes / totalQuizzes) * 100;

    final averageScore =
        history.map((q) => q.percentage).reduce((a, b) => a + b) / totalQuizzes;
    final totalTimeSpent = history
        .map((q) => q.timeSpentSeconds)
        .reduce((a, b) => a + b);
    final bestScore = history
        .map((q) => q.percentage)
        .reduce((a, b) => a > b ? a : b);

    // Recent performance (last 5 quizzes)
    final recentPerformance = history
        .take(5)
        .map(
          (q) => {
            'date': q.completedAt.toIso8601String(),
            'score': q.percentage,
            'passed': q.passed,
          },
        )
        .toList();

    return {
      'totalQuizzes': totalQuizzes,
      'averageScore': averageScore,
      'passRate': passRate,
      'totalTimeSpent': totalTimeSpent,
      'bestScore': bestScore,
      'recentPerformance': recentPerformance,
    };
  }

  /// Create sample quiz for development/testing
  /// Convert SQLite quiz data to QuizEntity
  Future<QuizEntity> _quizFromSQLite(Map<String, dynamic> quizData) async {
    try {
      final quizId = quizData['quiz_id'] as int;

      // Get questions for this quiz
      final questions = await _database.getQuizQuestions(quizId);

      final questionEntities = questions.map((q) {
        final optionsJson = q['options'] as String?;
        final options = optionsJson != null && optionsJson.isNotEmpty
            ? (optionsJson.split(',').toList())
            : <String>[];

        return QuestionEntity(
          id: q['question_id'].toString(),
          quizId: quizId.toString(),
          type: QuestionType.multipleChoice,
          question: q['question_text'] as String,
          options: options,
          correctAnswer: q['correct_answer'] as String,
          explanation: q['explanation'] as String? ?? '',
          hints: const [],
          points: q['points'] as int? ?? 1,
          timeLimitSeconds: 60,
          audioUrl: null,
          imageUrl: null,
          metadata: {},
        );
      }).toList();

      return QuizEntity(
        id: quizId.toString(),
        lessonId: '0', // Not associated with a specific lesson
        languageCode: quizData['language_id'] as String,
        title: quizData['title'] as String,
        description: quizData['description'] as String? ?? '',
        questions: questionEntities,
        timeLimitMinutes: 15,
        passingScore: 70,
        difficulty: QuizDifficulty.beginner,
        skillsTested: const ['vocabulary', 'grammar'],
        isAdaptive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error converting SQLite quiz: $e');
      rethrow;
    }
  }

  QuizEntity _createSampleQuiz(String lessonId, String languageCode) {
    final questions = [
      QuestionEntity(
        id: '${lessonId}_q1',
        quizId: '${lessonId}_quiz',
        type: QuestionType.multipleChoice,
        question: 'What does "Màà" mean in Yemba?',
        options: const ['Mother', 'Father', 'Sister', 'Brother'],
        correctAnswer: 'Mother',
        explanation: '"Màà" means "mother" in the Yemba language.',
        hints: const ['Think about family relationships', 'It starts with M'],
        points: 10,
        timeLimitSeconds: 30,
      ),
      QuestionEntity(
        id: '${lessonId}_q2',
        quizId: '${lessonId}_quiz',
        type: QuestionType.fillInBlank,
        question: 'Complete: "My name is ___"',
        options: const [], // Not used for fill-in-blank
        correctAnswer: 'Màà yegue',
        explanation: '"Màà yegue" means "my name" in Yemba.',
        hints: const ['It means "my name"', 'Pronounced "mah ah yeh-gweh"'],
        points: 15,
        timeLimitSeconds: 45,
      ),
      QuestionEntity(
        id: '${lessonId}_q3',
        quizId: '${lessonId}_quiz',
        type: QuestionType.trueFalse,
        question: '"Yemba" is a Cameroonian language.',
        options: const ['True', 'False'],
        correctAnswer: 'True',
        explanation:
            'Yemba is indeed a traditional language spoken in Cameroon.',
        hints: const ['Check the app description'],
        points: 5,
        timeLimitSeconds: 15,
      ),
    ];

    return QuizEntity(
      id: '${lessonId}_quiz',
      lessonId: lessonId,
      languageCode: languageCode,
      title: 'Lesson $lessonId Assessment',
      description: 'Test your understanding of the lesson content.',
      questions: questions,
      timeLimitMinutes: 10,
      passingScore: 70,
      difficulty: QuizDifficulty.beginner,
      skillsTested: const ['vocabulary', 'grammar'],
      isAdaptive: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Note: Firestore quiz support removed for hybrid architecture
  // All quiz data is now in SQLite

  /// Save quiz attempt to database
  Future<void> _saveQuizAttempt(QuizAttempt attempt) async {
    final db = await _database.database;

    await db.insert('quiz_attempts', {
      'id': attempt.id,
      'user_id': attempt.userId,
      'quiz_id': attempt.quizId,
      'answers': attempt.answers
          .map(
            (a) => {
              'questionId': a.questionId,
              'answer': a.answer,
              'isCorrect': a.isCorrect ? 1 : 0,
              'timeSpentSeconds': a.timeSpentSeconds,
              'pointsEarned': a.pointsEarned,
              'answeredAt': a.answeredAt.millisecondsSinceEpoch,
            },
          )
          .toList()
          .toString(),
      'total_score': attempt.totalScore,
      'max_score': attempt.maxScore,
      'percentage': attempt.percentage,
      'passed': attempt.passed ? 1 : 0,
      'time_spent_seconds': attempt.timeSpentSeconds,
      'started_at': attempt.startedAt.millisecondsSinceEpoch,
      'completed_at': attempt.completedAt.millisecondsSinceEpoch,
      'metadata': attempt.metadata?.toString(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });

    // Sync to Firebase
    await _syncQuizAttemptToFirebase(attempt);
  }

  /// Load quiz attempt from database
  Future<QuizAttempt?> _loadQuizAttempt(String attemptId) async {
    final db = await _database.database;

    final results = await db.query(
      'quiz_attempts',
      where: 'id = ?',
      whereArgs: [attemptId],
    );

    if (results.isEmpty) return null;

    return _quizAttemptFromDb(results.first);
  }

  /// Convert database row to QuizAttempt
  QuizAttempt _quizAttemptFromDb(Map<String, dynamic> row) {
    // TODO: Parse answers from JSON string - for now return empty
    final answers = <QuestionAnswer>[];

    return QuizAttempt(
      id: row['id'],
      userId: row['user_id'],
      quizId: row['quiz_id'],
      answers: answers,
      totalScore: row['total_score'],
      maxScore: row['max_score'],
      percentage: row['percentage'],
      passed: (row['passed'] as int) == 1,
      timeSpentSeconds: row['time_spent_seconds'],
      startedAt: DateTime.fromMillisecondsSinceEpoch(row['started_at']),
      completedAt: DateTime.fromMillisecondsSinceEpoch(row['completed_at']),
      metadata: null,
    );
  }

  /// Update progress tracking after quiz completion
  Future<void> _updateProgressAfterQuiz(
    QuizAttempt attempt,
    QuizEntity quiz,
  ) async {
    // Update assessment skill proficiency
    final assessmentScore = attempt.percentage.round();
    await _progressService.updateSkillProgress(
      userId: attempt.userId,
      languageCode: quiz.languageCode,
      skillName: 'assessment',
      proficiencyScore: assessmentScore,
    );

    // Update other skills tested
    for (final skill in quiz.skillsTested) {
      final skillScore = attempt.percentage.round();
      await _progressService.updateSkillProgress(
        userId: attempt.userId,
        languageCode: quiz.languageCode,
        skillName: skill,
        proficiencyScore: skillScore,
      );
    }

    // Record quiz completion milestone
    if (attempt.passed) {
      final quizHistory = await getUserQuizHistory(userId: attempt.userId);
      final passedCount = quizHistory.where((q) => q.passed).length;

      if (passedCount == 1) {
        await _progressService.recordMilestone(
          userId: attempt.userId,
          languageCode: quiz.languageCode,
          milestoneType: 'first_quiz_passed',
          milestoneTitle: 'First Quiz Passed!',
          description: 'Congratulations on passing your first quiz!',
        );
      } else if (passedCount == 10) {
        await _progressService.recordMilestone(
          userId: attempt.userId,
          languageCode: quiz.languageCode,
          milestoneType: 'ten_quizzes_passed',
          milestoneTitle: 'Quiz Master',
          description: 'Passed 10 quizzes successfully!',
        );
      }
    }
  }

  /// Sync quiz attempt to Firebase
  Future<void> _syncQuizAttemptToFirebase(QuizAttempt attempt) async {
    // HYBRID ARCHITECTURE: Quiz attempts are stored in SQLite
    // Firebase Firestore is NOT used for primary data storage
    // This method is kept for compatibility but does nothing
    debugPrint('Quiz attempt saved locally in SQLite: ${attempt.id}');
  }
}
