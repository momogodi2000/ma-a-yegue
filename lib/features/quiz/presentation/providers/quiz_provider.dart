import 'package:flutter/material.dart';
import 'package:maa_yegue/features/quiz/domain/entities/quiz_entity.dart';
import 'package:maa_yegue/features/quiz/data/services/quiz_service.dart';

/// Provider for managing quiz state across the app
class QuizProvider extends ChangeNotifier {
  final QuizService _quizService;

  QuizProvider(this._quizService);

  // Current quiz state
  QuizEntity? _currentQuiz;
  String? _currentAttemptId;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  QuizEntity? get currentQuiz => _currentQuiz;
  String? get currentAttemptId => _currentAttemptId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load quiz for a specific lesson
  Future<bool> loadQuiz({
    required String lessonId,
    required String languageCode,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final quiz = await _quizService.getQuizForLesson(
        lessonId: lessonId,
        languageCode: languageCode,
      );

      if (quiz == null) {
        _setError('Quiz not found for this lesson');
        return false;
      }

      _currentQuiz = quiz;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to load quiz: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Start a new quiz attempt
  Future<bool> startQuizAttempt(String userId) async {
    if (_currentQuiz == null) {
      _setError('No quiz loaded');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final attemptId = await _quizService.startQuizAttempt(
        userId: userId,
        quizId: _currentQuiz!.id,
      );

      _currentAttemptId = attemptId;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to start quiz: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Submit an answer for the current quiz attempt
  Future<bool> submitAnswer({
    required QuestionEntity question,
    required String answer,
    required int timeSpentSeconds,
  }) async {
    if (_currentAttemptId == null) {
      _setError('No active quiz attempt');
      return false;
    }

    try {
      await _quizService.submitAnswer(
        attemptId: _currentAttemptId!,
        question: question,
        answer: answer,
        timeSpentSeconds: timeSpentSeconds,
      );
      return true;
    } catch (e) {
      _setError('Failed to submit answer: $e');
      return false;
    }
  }

  /// Complete the current quiz attempt
  Future<QuizAttempt?> completeQuizAttempt() async {
    if (_currentQuiz == null || _currentAttemptId == null) {
      _setError('No active quiz to complete');
      return null;
    }

    try {
      _setLoading(true);
      _clearError();

      final attempt = await _quizService.completeQuizAttempt(
        attemptId: _currentAttemptId!,
        quiz: _currentQuiz!,
      );

      if (attempt != null) {
        // Clear current state
        _currentQuiz = null;
        _currentAttemptId = null;
        notifyListeners();
      }

      return attempt;
    } catch (e) {
      _setError('Failed to complete quiz: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get quiz history for a user
  Future<List<QuizAttempt>> getQuizHistory(String userId) async {
    try {
      return await _quizService.getUserQuizHistory(userId: userId);
    } catch (e) {
      _setError('Failed to load quiz history: $e');
      return [];
    }
  }

  /// Get quiz statistics for a user
  Future<Map<String, dynamic>> getQuizStatistics(String userId) async {
    try {
      return await _quizService.getQuizStatistics(userId: userId);
    } catch (e) {
      _setError('Failed to load quiz statistics: $e');
      return {};
    }
  }

  /// Clear current quiz state
  void clearCurrentQuiz() {
    _currentQuiz = null;
    _currentAttemptId = null;
    _clearError();
    notifyListeners();
  }

  /// Reset error state
  void clearError() {
    _clearError();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}