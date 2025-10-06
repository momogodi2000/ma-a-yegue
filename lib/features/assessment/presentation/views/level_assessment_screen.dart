import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/level_assessment_viewmodel.dart';
import '../../domain/entities/level_assessment_entity.dart';

class LevelAssessmentScreen extends StatefulWidget {
  final String userId;
  final String languageCode;
  final String currentLevel;
  final String targetLevel;
  final String languageName;

  const LevelAssessmentScreen({
    super.key,
    required this.userId,
    required this.languageCode,
    required this.currentLevel,
    required this.targetLevel,
    required this.languageName,
  });

  @override
  State<LevelAssessmentScreen> createState() => _LevelAssessmentScreenState();
}

class _LevelAssessmentScreenState extends State<LevelAssessmentScreen> {
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAssessment();
    });
  }

  Future<void> _startAssessment() async {
    final viewModel = context.read<LevelAssessmentViewModel>();
    final success = await viewModel.startAssessment(
      userId: widget.userId,
      languageCode: widget.languageCode,
      currentLevel: widget.currentLevel,
      targetLevel: widget.targetLevel,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Erreur lors du démarrage de l\'évaluation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test de niveau - ${widget.languageName}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<LevelAssessmentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Préparation de votre test...'),
                ],
              ),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _startAssessment,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.showResult && viewModel.result != null) {
            return _buildResultScreen(context, viewModel);
          }

          if (viewModel.currentAssessment != null) {
            return _buildAssessmentScreen(context, viewModel);
          }

          return const Center(child: Text('Chargement...'));
        },
      ),
    );
  }

  Widget _buildAssessmentScreen(BuildContext context, LevelAssessmentViewModel viewModel) {
    final question = viewModel.currentQuestion;
    if (question == null) return const Center(child: Text('Aucune question disponible'));

    // Reset selected answer when question changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.currentQuestionAnswer != null) {
        _selectedAnswer = viewModel.currentQuestionAnswer;
      } else {
        _selectedAnswer = null;
      }
    });

    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${viewModel.currentQuestionIndex + 1} sur ${viewModel.totalQuestions}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${(viewModel.progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: viewModel.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
        
        // Question content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getQuestionTypeLabel(question.type),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Question text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    question.question,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Answer options
                Expanded(
                  child: _buildAnswerOptions(question, viewModel),
                ),
              ],
            ),
          ),
        ),
        
        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              if (viewModel.canGoPrevious)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      viewModel.previousQuestion();
                      setState(() {
                        _selectedAnswer = viewModel.currentQuestionAnswer;
                      });
                    },
                    child: const Text('Précédent'),
                  ),
                ),
              if (viewModel.canGoPrevious) const SizedBox(width: 16),
              
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: viewModel.currentQuestionAnswered ? () {
                    if (viewModel.isLastQuestion) {
                      _showSubmissionDialog(context, viewModel);
                    } else {
                      viewModel.nextQuestion();
                      setState(() {
                        _selectedAnswer = viewModel.currentQuestionAnswer;
                      });
                    }
                  } : null,
                  child: Text(viewModel.isLastQuestion ? 'Terminer' : 'Suivant'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerOptions(AssessmentQuestionEntity question, LevelAssessmentViewModel viewModel) {
    if (question.type == 'multiple_choice') {
      return Column(
        children: question.options.map((option) {
          final isSelected = _selectedAnswer == option;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedAnswer = option;
                });
                viewModel.answerQuestion(option);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[400]!,
                        ),
                      ),
                      child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isSelected ? Theme.of(context).primaryColor : null,
                          fontWeight: isSelected ? FontWeight.w500 : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    } else {
      // Translation or open-ended question
      return Column(
        children: [
          TextField(
            onChanged: (value) {
              viewModel.answerQuestion(value);
              setState(() {
                _selectedAnswer = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Tapez votre réponse ici...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 3,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Conseil: Répondez de manière claire et concise.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildResultScreen(BuildContext context, LevelAssessmentViewModel viewModel) {
    final result = viewModel.result!;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          const Icon(
            Icons.emoji_events,
            size: 80,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          Text(
            result.levelPassed ? 'Félicitations!' : 'Test terminé',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: result.levelPassed ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 32),
          
          // Score card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  Theme.of(context).primaryColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildScoreItem(context, 'Score', '${result.totalScore.toInt()}', Icons.star),
                    _buildScoreItem(context, 'Pourcentage', '${result.percentage.toInt()}%', Icons.percent),
                    _buildScoreItem(context, 'Niveau', result.recommendedLevel, Icons.trending_up),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Feedback
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commentaires:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.feedback,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Strengths and weaknesses
          if (result.strengths.isNotEmpty || result.weaknesses.isNotEmpty)
            Row(
              children: [
                if (result.strengths.isNotEmpty)
                  Expanded(
                    child: _buildSkillsList(context, 'Points forts', result.strengths, Colors.green),
                  ),
                if (result.strengths.isNotEmpty && result.weaknesses.isNotEmpty)
                  const SizedBox(width: 16),
                if (result.weaknesses.isNotEmpty)
                  Expanded(
                    child: _buildSkillsList(context, 'À améliorer', result.weaknesses, Colors.orange),
                  ),
              ],
            ),
          
          const Spacer(),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Retour'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    viewModel.resetAssessment();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Nouveau test'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsList(BuildContext context, String title, List<String> skills, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ...skills.map((skill) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    skill,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Choix multiple';
      case 'translation':
        return 'Traduction';
      case 'audio':
        return 'Écoute';
      case 'speaking':
        return 'Expression orale';
      default:
        return 'Question';
    }
  }

  void _showSubmissionDialog(BuildContext context, LevelAssessmentViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer le test'),
        content: const Text('Êtes-vous sûr de vouloir terminer le test? Vous ne pourrez plus modifier vos réponses.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.submitAssessment();
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }
}