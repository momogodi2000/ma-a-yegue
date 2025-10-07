import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/learner_viewmodel.dart';
import '../../domain/repositories/learner_repository.dart';

/// Comprehensive learner dashboard view
class LearnerDashboardView extends StatefulWidget {
  final String userId;

  const LearnerDashboardView({super.key, required this.userId});

  @override
  State<LearnerDashboardView> createState() => _LearnerDashboardViewState();
}

class _LearnerDashboardViewState extends State<LearnerDashboardView> {
  @override
  void initState() {
    super.initState();
    // Load all learner data when the view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearnerViewModel>().loadAllLearnerData(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Tableau de Bord Apprenant'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LearnerViewModel>().loadAllLearnerData(
                widget.userId,
              );
            },
          ),
        ],
      ),
      body: Consumer<LearnerViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${viewModel.errorMessage}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.loadAllLearnerData(widget.userId);
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(viewModel),

                const SizedBox(height: 24),

                // Statistics Overview
                _buildStatisticsOverview(viewModel),

                const SizedBox(height: 24),

                // Language Progress
                _buildLanguageProgressSection(viewModel),

                const SizedBox(height: 24),

                // Achievements
                _buildAchievementsSection(viewModel),

                const SizedBox(height: 24),

                // Learning Goals
                _buildLearningGoalsSection(viewModel),

                const SizedBox(height: 24),

                // Recent Activity
                _buildRecentActivitySection(viewModel),

                const SizedBox(height: 24),

                // Learning Recommendations
                _buildLearningRecommendationsSection(viewModel),

                const SizedBox(height: 24),

                // Performance Analytics
                _buildPerformanceAnalyticsSection(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(LearnerViewModel viewModel) {
    final profile = viewModel.learnerProfile;
    final statistics = viewModel.learningStatistics;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👋 Bonjour ${profile?.name ?? 'Apprenant'} !',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Continuez votre parcours d\'apprentissage des langues camerounaises',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildWelcomeStat(
                profile?.currentLevel ?? 'Débutant',
                'Niveau',
                Icons.star,
              ),
              const SizedBox(width: 16),
              _buildWelcomeStat(
                '${statistics['totalLessonsCompleted'] ?? 0}',
                'Leçons',
                Icons.menu_book,
              ),
              const SizedBox(width: 16),
              _buildWelcomeStat(
                '${viewModel.studyStreak}',
                'Jours',
                Icons.local_fire_department,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsOverview(LearnerViewModel viewModel) {
    final statistics = viewModel.learningStatistics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 Aperçu des Statistiques',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              '${statistics['totalLessonsCompleted'] ?? 0}',
              'Leçons Terminées',
              Icons.menu_book,
              Colors.green,
            ),
            _buildStatCard(
              '${statistics['totalCoursesCompleted'] ?? 0}',
              'Cours Terminés',
              Icons.school,
              Colors.blue,
            ),
            _buildStatCard(
              '${(statistics['totalStudyTime'] ?? 0) ~/ 60}h',
              'Temps d\'Étude',
              Icons.timer,
              Colors.orange,
            ),
            _buildStatCard(
              '${(statistics['averageAccuracy'] ?? 0.0).toStringAsFixed(1)}%',
              'Précision Moyenne',
              Icons.adjust,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageProgressSection(LearnerViewModel viewModel) {
    final languageProgress = viewModel.languageProgress;

    if (languageProgress.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🌍 Progression par Langue',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...languageProgress.entries.map((entry) {
          final progress = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        progress.languageName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        progress.currentLevel,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${progress.lessonsCompleted} leçons',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progress.levelProgress,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          Text(
                            '${(progress.levelProgress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const Text(
                            'Progression',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAchievementsSection(LearnerViewModel viewModel) {
    final achievements = viewModel.achievements;

    if (achievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏆 Réalisations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          achievement.iconUrl,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          achievement.title,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLearningGoalsSection(LearnerViewModel viewModel) {
    final goals = viewModel.learningGoals;

    if (goals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎯 Objectifs d\'Apprentissage',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...goals.map((goal) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${(goal.progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    goal.description,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRecentActivitySection(LearnerViewModel viewModel) {
    final history = viewModel.learningHistory;

    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📚 Activité Récente',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...history.take(5).map((activity) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                _getActivityIcon(activity['activityType'] as String?),
                color: Colors.deepPurple,
              ),
              title: Text(
                _getActivityTitle(activity),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _getActivitySubtitle(activity),
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Text(
                _formatTimestamp(activity['timestamp'] as String?),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLearningRecommendationsSection(LearnerViewModel viewModel) {
    final recommendations = viewModel.learningRecommendations;

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💡 Recommandations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...recommendations.take(3).map((recommendation) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                child: Icon(
                  _getRecommendationIcon(recommendation.type),
                  color: Colors.deepPurple,
                ),
              ),
              title: Text(
                recommendation.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                recommendation.description,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.deepPurple),
                onPressed: () {
                  // Handle recommendation action
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPerformanceAnalyticsSection(LearnerViewModel viewModel) {
    final analytics = viewModel.performanceAnalytics;

    if (analytics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📈 Analyse de Performance',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAnalyticsItem(
                      'Précision',
                      '${(analytics['accuracy'] ?? 0.0).toStringAsFixed(1)}%',
                      Icons.adjust,
                      Colors.green,
                    ),
                    _buildAnalyticsItem(
                      'Vitesse',
                      '${(analytics['speed'] ?? 0.0).toStringAsFixed(1)} min',
                      Icons.speed,
                      Colors.blue,
                    ),
                    _buildAnalyticsItem(
                      'Consistance',
                      '${(analytics['consistency'] ?? 0.0).toStringAsFixed(1)}%',
                      Icons.trending_up,
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  IconData _getActivityIcon(String? activityType) {
    switch (activityType) {
      case 'lesson_completion':
        return Icons.menu_book;
      case 'course_completion':
        return Icons.school;
      case 'quiz_completion':
        return Icons.quiz;
      default:
        return Icons.star;
    }
  }

  String _getActivityTitle(Map<String, dynamic> activity) {
    final activityType = activity['activityType'] as String?;
    switch (activityType) {
      case 'lesson_completion':
        return 'Leçon terminée';
      case 'course_completion':
        return 'Cours terminé';
      case 'quiz_completion':
        return 'Quiz terminé';
      default:
        return 'Activité';
    }
  }

  String _getActivitySubtitle(Map<String, dynamic> activity) {
    final score = activity['score'] as int?;
    final timeSpent = activity['timeSpentMinutes'] as int?;

    if (score != null && timeSpent != null) {
      return 'Score: $score • Temps: ${timeSpent}min';
    } else if (score != null) {
      return 'Score: $score';
    } else if (timeSpent != null) {
      return 'Temps: ${timeSpent}min';
    } else {
      return 'Activité terminée';
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}j';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'Maintenant';
      }
    } catch (e) {
      return '';
    }
  }

  IconData _getRecommendationIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.lesson:
        return Icons.menu_book;
      case RecommendationType.course:
        return Icons.school;
      case RecommendationType.exercise:
        return Icons.fitness_center;
      case RecommendationType.practice:
        return Icons.play_circle;
      case RecommendationType.review:
        return Icons.refresh;
      case RecommendationType.assessment:
        return Icons.assessment;
      case RecommendationType.challenge:
        return Icons.emoji_events;
    }
  }
}
