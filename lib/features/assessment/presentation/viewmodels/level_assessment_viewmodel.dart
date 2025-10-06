import 'package:flutter/material.dart';
import '../../domain/entities/level_assessment_entity.dart';
import '../../domain/usecases/start_level_assessment_usecase.dart';
import '../../../../core/errors/failures.dart';

class LevelAssessmentViewModel extends ChangeNotifier {
  final StartLevelAssessmentUsecase startLevelAssessmentUsecase;

  LevelAssessmentViewModel({
    required this.startLevelAssessmentUsecase,
  });

  // State
  bool _isLoading = false;
  String? _errorMessage;
  LevelAssessmentEntity? _currentAssessment;
  int _currentQuestionIndex = 0;
  final Map<String, String> _userAnswers = {};
  bool _showResult = false;
  AssessmentResult? _result;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LevelAssessmentEntity? get currentAssessment => _currentAssessment;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, String> get userAnswers => _userAnswers;
  bool get showResult => _showResult;
  AssessmentResult? get result => _result;

  AssessmentQuestionEntity? get currentQuestion {
    if (_currentAssessment != null && 
        _currentQuestionIndex < _currentAssessment!.questions.length) {
      return _currentAssessment!.questions[_currentQuestionIndex];
    }
    return null;
  }

  bool get canGoNext => _currentQuestionIndex < (_currentAssessment?.questions.length ?? 0) - 1;
  bool get canGoPrevious => _currentQuestionIndex > 0;
  bool get isLastQuestion => _currentQuestionIndex == (_currentAssessment?.questions.length ?? 0) - 1;
  int get totalQuestions => _currentAssessment?.questions.length ?? 0;
  double get progress => totalQuestions > 0 ? (_currentQuestionIndex + 1) / totalQuestions : 0.0;

  // Actions
  Future<bool> startAssessment({
    required String userId,
    required String languageCode,
    required String currentLevel,
    required String targetLevel,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await startLevelAssessmentUsecase(
      StartLevelAssessmentParams(
        userId: userId,
        languageCode: languageCode,
        currentLevel: currentLevel,
        targetLevel: targetLevel,
      ),
    );

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
        return false;
      },
      (assessment) {
        _currentAssessment = assessment;
        _currentQuestionIndex = 0;
        _userAnswers.clear();
        _showResult = false;
        _setLoading(false);
        notifyListeners();
        return true;
      },
    );
  }

  void answerQuestion(String answer) {
    if (currentQuestion != null) {
      _userAnswers[currentQuestion!.id] = answer;
      notifyListeners();
    }
  }

  bool get currentQuestionAnswered {
    return currentQuestion != null && _userAnswers.containsKey(currentQuestion!.id);
  }

  String? get currentQuestionAnswer {
    return currentQuestion != null ? _userAnswers[currentQuestion!.id] : null;
  }

  void nextQuestion() {
    if (canGoNext) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (canGoPrevious) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < totalQuestions) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  Future<bool> submitAssessment() async {
    if (_currentAssessment == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Here you would call the complete assessment usecase
      // For now, simulate the result calculation
      final totalScore = _calculateScore();
      final percentage = (totalScore / (totalQuestions * 10)) * 100;
      final levelPassed = percentage >= 70.0;

      _result = AssessmentResult(
        totalScore: totalScore,
        percentage: percentage,
        recommendedLevel: levelPassed ? _currentAssessment!.targetLevel : _currentAssessment!.currentLevel,
        levelPassed: levelPassed,
        strengths: _getStrengths(),
        weaknesses: _getWeaknesses(),
        feedback: _generateFeedback(percentage),
      );

      _showResult = true;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors de la soumission: $e');
      _setLoading(false);
      return false;
    }
  }

  double _calculateScore() {
    double score = 0;
    for (final question in _currentAssessment!.questions) {
      final userAnswer = _userAnswers[question.id];
      if (userAnswer != null && userAnswer.toLowerCase().trim() == question.correctAnswer.toLowerCase().trim()) {
        score += question.points;
      }
    }
    return score;
  }

  List<String> _getStrengths() {
    List<String> strengths = [];
    for (final question in _currentAssessment!.questions) {
      final userAnswer = _userAnswers[question.id];
      if (userAnswer != null && userAnswer.toLowerCase().trim() == question.correctAnswer.toLowerCase().trim()) {
        if (question.type == 'translation') {
          strengths.add('Traduction');
        } else if (question.type == 'multiple_choice') {
          strengths.add('Vocabulaire');
        }
      }
    }
    return strengths.toSet().toList();
  }

  List<String> _getWeaknesses() {
    List<String> weaknesses = [];
    for (final question in _currentAssessment!.questions) {
      final userAnswer = _userAnswers[question.id];
      if (userAnswer == null || userAnswer.toLowerCase().trim() != question.correctAnswer.toLowerCase().trim()) {
        if (question.type == 'translation') {
          weaknesses.add('Traduction');
        } else if (question.type == 'multiple_choice') {
          weaknesses.add('Vocabulaire');
        }
      }
    }
    return weaknesses.toSet().toList();
  }

  String _generateFeedback(double percentage) {
    if (percentage >= 90) {
      return 'Excellent! Vous maîtrisez très bien ce niveau.';
    } else if (percentage >= 80) {
      return 'Très bien! Vous êtes prêt pour le niveau suivant.';
    } else if (percentage >= 70) {
      return 'Bien! Vous pouvez passer au niveau suivant.';
    } else if (percentage >= 60) {
      return 'Pas mal, mais vous devriez réviser certains points.';
    } else {
      return 'Il faut encore travailler ce niveau. Continuez à pratiquer!';
    }
  }

  void resetAssessment() {
    _currentAssessment = null;
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _showResult = false;
    _result = null;
    _clearError();
    notifyListeners();
  }

  // Helper methods
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

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Erreur serveur: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'Erreur réseau: ${failure.message}';
    } else if (failure is AuthFailure) {
      return 'Erreur d\'authentification: ${failure.message}';
    } else {
      return 'Une erreur inattendue s\'est produite: ${failure.message}';
    }
  }
}