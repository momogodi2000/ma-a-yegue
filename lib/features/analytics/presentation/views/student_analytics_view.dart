import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maa_yegue/core/constants/app_dimensions.dart';
import 'package:maa_yegue/features/analytics/presentation/viewmodels/student_analytics_viewmodel.dart';
import 'package:maa_yegue/features/analytics/data/services/student_analytics_service.dart';
import 'package:maa_yegue/features/analytics/data/models/student_analytics_models.dart';
import 'package:maa_yegue/features/analytics/presentation/widgets/analytics_charts.dart';
import 'package:maa_yegue/shared/widgets/theme_switcher_widget.dart';

/// Student Analytics Dashboard View
class StudentAnalyticsView extends StatefulWidget {
  const StudentAnalyticsView({Key? key}) : super(key: key);

  @override
  State<StudentAnalyticsView> createState() => _StudentAnalyticsViewState();
}

class _StudentAnalyticsViewState extends State<StudentAnalyticsView> {
  late StudentAnalyticsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = StudentAnalyticsViewModel(StudentAnalyticsService());
    // TODO: Get actual user ID from auth
    _viewModel.loadAnalytics('current_user_id');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<StudentAnalyticsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Learning Analytics'),
              actions: [
                IconButton(
                  onPressed: () =>
                      viewModel.refreshAnalytics('current_user_id'),
                  icon: const Icon(Icons.refresh),
                ),
                const ThemeSwitcherWidget(),
              ],
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.error != null
                ? _buildErrorView(viewModel.error!)
                : viewModel.analytics != null
                ? _buildAnalyticsView(viewModel.analytics!)
                : const Center(child: Text('No analytics data available')),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text(
              'Failed to load analytics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            ElevatedButton(
              onPressed: () => _viewModel.refreshAnalytics('current_user_id'),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsView(StudentAnalytics analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Learning Progress Overview
          _buildProgressOverview(analytics.learningProgress),

          const SizedBox(height: AppDimensions.spacingLarge),

          // Performance Metrics
          _buildPerformanceMetrics(analytics.performanceMetrics),

          const SizedBox(height: AppDimensions.spacingLarge),

          // Learning Patterns
          _buildLearningPatterns(analytics.learningPatterns),

          const SizedBox(height: AppDimensions.spacingLarge),

          // Achievements
          _buildAchievements(analytics.achievements),

          const SizedBox(height: AppDimensions.spacingLarge),

          // Interactive Charts
          _buildChartsSection(analytics),

          const SizedBox(height: AppDimensions.spacingLarge),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(LearningProgress progress) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.green),
                const SizedBox(width: AppDimensions.spacingSmall),
                Text(
                  'Learning Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLarge),

            // Progress Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Courses Enrolled',
                  progress.enrolledCourses.toString(),
                  Icons.school,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Courses Completed',
                  progress.completedCourses.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  'Lessons Done',
                  progress.completedLessons.toString(),
                  Icons.book,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Study Time',
                  '${progress.totalStudyTimeMinutes}min',
                  Icons.timer,
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingLarge),

            // Streaks
            Row(
              children: [
                Expanded(
                  child: _buildStreakCard(
                    'Current Streak',
                    progress.currentStreak,
                    Icons.local_fire_department,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: _buildStreakCard(
                    'Best Streak',
                    progress.longestStreak,
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(PerformanceMetrics metrics) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue),
                const SizedBox(width: AppDimensions.spacingSmall),
                Text(
                  'Performance Metrics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLarge),

            // Average Score
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Average Quiz Score',
                    '${metrics.averageQuizScore.toStringAsFixed(1)}%',
                    Icons.grade,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: _buildMetricCard(
                    'Quizzes Taken',
                    metrics.totalQuizzesTaken.toString(),
                    Icons.quiz,
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingLarge),

            // Improvement Rate
            if (metrics.improvementRate > 0)
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8), // green.shade50 equivalent
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.green),
                    const SizedBox(width: AppDimensions.spacingSmall),
                    Expanded(
                      child: Text(
                        'Improving at ${metrics.improvementRate.toStringAsFixed(1)}% per week!',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppDimensions.spacingLarge),

            // Strengths and Weaknesses
            if (metrics.strengths.isNotEmpty ||
                metrics.weaknesses.isNotEmpty) ...[
              const Text(
                'Learning Insights',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.spacingSmall),

              if (metrics.strengths.isNotEmpty)
                _buildInsightsList(
                  'Strengths',
                  metrics.strengths,
                  Colors.green,
                ),

              if (metrics.weaknesses.isNotEmpty)
                _buildInsightsList(
                  'Areas to Focus',
                  metrics.weaknesses,
                  Colors.orange,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLearningPatterns(LearningPatterns patterns) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.purple),
                const SizedBox(width: AppDimensions.spacingSmall),
                Text(
                  'Learning Patterns',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLarge),

            // Study Preferences
            Row(
              children: [
                Expanded(
                  child: _buildPatternCard(
                    'Best Study Time',
                    '${patterns.preferredStudyHour}:00',
                    Icons.access_time,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: _buildPatternCard(
                    'Best Study Day',
                    patterns.preferredStudyDay,
                    Icons.calendar_today,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingLarge),

            // Session Info
            Row(
              children: [
                Expanded(
                  child: _buildPatternCard(
                    'Avg Session',
                    '${patterns.averageSessionDuration}min',
                    Icons.timer,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: _buildPatternCard(
                    'Recommended',
                    '${patterns.recommendedStudyTime}min',
                    Icons.lightbulb,
                    Colors.amber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingLarge),

            // Content Preferences
            if (patterns.contentTypePreferences.isNotEmpty) ...[
              const Text(
                'Preferred Content Types',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.spacingSmall),
              Wrap(
                spacing: AppDimensions.spacingSmall,
                runSpacing: AppDimensions.spacingSmall,
                children: patterns.contentTypePreferences.entries.map((entry) {
                  return Chip(
                    label: Text('${entry.key}: ${entry.value}%'),
                    backgroundColor: Colors.blue.shade50,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(AchievementsData achievements) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: AppDimensions.spacingSmall),
                Text(
                  'Achievements & Badges',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLarge),

            // Level and Points
            Row(
              children: [
                Expanded(
                  child: _buildAchievementCard(
                    'Level ${achievements.level}',
                    '${achievements.nextLevelProgress}% to next',
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: _buildAchievementCard(
                    'Total Points',
                    achievements.totalPoints.toString(),
                    Icons.star_border,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingLarge),

            // Badges
            if (achievements.earnedBadges.isNotEmpty) ...[
              const Text(
                'Earned Badges',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.spacingSmall),
              Wrap(
                spacing: AppDimensions.spacingSmall,
                runSpacing: AppDimensions.spacingSmall,
                children: achievements.earnedBadges.map((badge) {
                  return Chip(
                    avatar: Text(badge.icon),
                    label: Text(badge.name),
                    backgroundColor: Colors.amber.shade50,
                  );
                }).toList(),
              ),
            ] else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Text('No badges earned yet. Keep learning!'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===== HELPER WIDGETS =====

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingTiny),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE), // red.shade50 equivalent
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFFCDD2),
        ), // red.shade200 equivalent
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppDimensions.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(title, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: _getBackgroundColor(color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingTiny),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: _getBackgroundColor(color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppDimensions.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                Text(title, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: _getBackgroundColor(color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppDimensions.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsList(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingTiny),
            child: Row(
              children: [
                Icon(
                  title == 'Strengths' ? Icons.check_circle : Icons.warning,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: AppDimensions.spacingSmall),
                Text(item),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
      ],
    );
  }

  Widget _buildChartsSection(StudentAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
          ),
          child: Text(
            'Visual Analytics',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLarge),

        // Performance Chart
        AnalyticsCharts.buildPerformanceChart(
          context,
          analytics.performanceMetrics,
        ),

        const SizedBox(height: AppDimensions.spacingLarge),

        // Progress and Patterns Charts in a row
        Row(
          children: [
            Expanded(
              child: AnalyticsCharts.buildProgressChart(
                context,
                analytics.learningProgress,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: AnalyticsCharts.buildStudyPatternsChart(
                context,
                analytics.learningPatterns,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.spacingLarge),

        // Content Preferences and Achievement Progress
        Row(
          children: [
            Expanded(
              child: AnalyticsCharts.buildContentPreferencesChart(
                context,
                analytics.learningPatterns,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: AnalyticsCharts.buildAchievementProgressChart(
                context,
                analytics.achievements,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getBackgroundColor(Color color) {
    if (color == Colors.green) return const Color(0xFFE8F5E8);
    if (color == Colors.blue) return const Color(0xFFE3F2FD);
    if (color == Colors.orange) return const Color(0xFFFFF3E0);
    if (color == Colors.purple) return const Color(0xFFF3E5F5);
    if (color == Colors.amber) return const Color(0xFFFFF8E1);
    return const Color(0xFFEEEEEE); // fallback gray
  }
}
