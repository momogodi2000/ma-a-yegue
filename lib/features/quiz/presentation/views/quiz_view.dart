import 'package:flutter/material.dart';
import 'package:maa_yegue/features/quiz/domain/entities/quiz_entity.dart';
import 'package:maa_yegue/features/quiz/data/services/quiz_service.dart';
import 'package:maa_yegue/features/quiz/presentation/widgets/question_widget.dart';
import 'package:maa_yegue/features/lessons/data/services/progress_tracking_service.dart';

/// Main quiz view that handles the complete quiz flow
class QuizView extends StatefulWidget {
  final String lessonId;
  final String languageCode;
  final QuizService quizService;
  final ProgressTrackingService progressService;

  const QuizView({
    Key? key,
    required this.lessonId,
    required this.languageCode,
    required this.quizService,
    required this.progressService,
  }) : super(key: key);

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> with TickerProviderStateMixin {
  QuizEntity? _quiz;
  String? _attemptId;
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Results tracking
  final List<Map<String, dynamic>> _questionResults = [];
  DateTime? _quizStartTime;

  // Animation
  late AnimationController _progressAnimation;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();

    _progressAnimation = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressAnimation, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _progressAnimation.dispose();
    super.dispose();
  }

  Future<void> _initializeQuiz() async {
    try {
      setState(() => _isLoading = true);

      // Load quiz
      final quiz = await widget.quizService.getQuizForLesson(
        lessonId: widget.lessonId,
        languageCode: widget.languageCode,
      );

      if (quiz == null) {
        setState(() {
          _errorMessage = 'Failed to load quiz. Please try again.';
          _isLoading = false;
        });
        return;
      }

      // Start quiz attempt
      final attemptId = await widget.quizService.startQuizAttempt(
        userId: 'current_user', // TODO: Get from auth
        quizId: quiz.id,
      );

      setState(() {
        _quiz = quiz;
        _attemptId = attemptId;
        _quizStartTime = DateTime.now();
        _isLoading = false;
      });

      _updateProgressAnimation();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing quiz: $e';
        _isLoading = false;
      });
    }
  }

  void _updateProgressAnimation() {
    if (_quiz != null) {
      final progress = (_currentQuestionIndex + 1) / _quiz!.questionCount;
      _progressValue = Tween<double>(begin: _progressValue.value, end: progress)
          .animate(
            CurvedAnimation(
              parent: _progressAnimation,
              curve: Curves.easeInOut,
            ),
          );
      _progressAnimation.forward(from: 0.0);
    }
  }

  void _onAnswerSubmitted(String answer, int timeSpentSeconds) {
    if (_quiz == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final question = _quiz!.questions[_currentQuestionIndex];
    final isCorrect = question.isCorrect(answer);

    // Record result
    _questionResults.add({
      'question': question,
      'userAnswer': answer,
      'isCorrect': isCorrect,
      'timeSpent': timeSpentSeconds,
      'points': isCorrect ? question.points : 0,
    });

    // Submit to service
    widget.quizService
        .submitAnswer(
          attemptId: _attemptId!,
          question: question,
          answer: answer,
          timeSpentSeconds: timeSpentSeconds,
        )
        .then((_) {
          setState(() => _isSubmitting = false);

          // Auto-advance after short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _nextQuestion();
            }
          });
        })
        .catchError((error) {
          setState(() {
            _isSubmitting = false;
            _errorMessage = 'Error submitting answer: $error';
          });
        });
  }

  void _nextQuestion() {
    if (_quiz == null) return;

    if (_currentQuestionIndex < _quiz!.questionCount - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _updateProgressAnimation();
    } else {
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    if (_quiz == null || _attemptId == null) return;

    setState(() => _isSubmitting = true);

    try {
      final attempt = await widget.quizService.completeQuizAttempt(
        attemptId: _attemptId!,
        quiz: _quiz!,
      );

      if (attempt != null) {
        // Navigate to results
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => QuizResultsView(
              quiz: _quiz!,
              attempt: attempt,
              questionResults: _questionResults,
              onRetry: () => Navigator.of(context).pop(),
              onContinue: () {
                // TODO: Navigate back to lesson or next lesson
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to complete quiz';
          _isSubmitting = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error completing quiz: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initializeQuiz,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_quiz == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('Quiz not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_quiz!.title),
        actions: [
          if (_quiz!.isTimed)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _getTimeRemaining(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          AnimatedBuilder(
            animation: _progressValue,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressValue.value,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              );
            },
          ),

          // Question content
          Expanded(
            child: QuestionWidget(
              question: _quiz!.questions[_currentQuestionIndex],
              questionNumber: _currentQuestionIndex + 1,
              totalQuestions: _quiz!.questionCount,
              onAnswerSubmitted: _onAnswerSubmitted,
              showResult: false,
            ),
          ),

          // Loading overlay
          if (_isSubmitting)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  String _getTimeRemaining() {
    if (_quizStartTime == null || !_quiz!.isTimed) return '';

    final elapsed = DateTime.now().difference(_quizStartTime!);
    final remaining = Duration(minutes: _quiz!.timeLimitMinutes) - elapsed;

    if (remaining.isNegative) return 'Time\'s up!';

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Quiz results view showing final score and breakdown
class QuizResultsView extends StatelessWidget {
  final QuizEntity quiz;
  final QuizAttempt attempt;
  final List<Map<String, dynamic>> questionResults;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  const QuizResultsView({
    Key? key,
    required this.quiz,
    required this.attempt,
    required this.questionResults,
    required this.onRetry,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final correctAnswers = questionResults
        .where((r) => r['isCorrect'] as bool)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Score circle
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: attempt.passed
                      ? [Colors.green[400]!, Colors.green[600]!]
                      : [Colors.red[400]!, Colors.red[600]!],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (attempt.passed ? Colors.green : Colors.red)
                        .withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${attempt.percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${attempt.totalScore}/${attempt.maxScore}',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: attempt.passed ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: attempt.passed ? Colors.green[200]! : Colors.red[200]!,
                ),
              ),
              child: Text(
                attempt.passed ? 'PASSED! 🎉' : 'Try Again',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: attempt.passed ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  icon: Icons.check_circle,
                  value: '$correctAnswers/${attempt.totalQuestions}',
                  label: 'Correct',
                  color: Colors.green,
                ),
                _buildStatCard(
                  icon: Icons.schedule,
                  value:
                      '${(attempt.timeSpentSeconds / 60).toStringAsFixed(1)}m',
                  label: 'Time',
                  color: Colors.blue,
                ),
                _buildStatCard(
                  icon: Icons.trending_up,
                  value: '${attempt.accuracy.toStringAsFixed(0)}%',
                  label: 'Accuracy',
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Question breakdown
            const Text(
              'Question Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            ...questionResults.asMap().entries.map((entry) {
              final index = entry.key;
              final result = entry.value;
              final question = result['question'] as QuestionEntity;
              final isCorrect = result['isCorrect'] as bool;
              final timeSpent = result['timeSpent'] as int;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCorrect
                        ? Colors.green[100]
                        : Colors.red[100],
                    child: Icon(
                      isCorrect ? Icons.check : Icons.close,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    'Question ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${timeSpent}s • ${question.points} points',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Text(
                    isCorrect ? '+${question.points}' : '0',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    child: const Text('Review Answers'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
