import 'package:flutter/material.dart';
import 'package:maa_yegue/features/lessons/data/services/progress_tracking_service.dart';
import 'package:maa_yegue/features/quiz/presentation/providers/quiz_provider.dart';

/// Main learner dashboard showing progress, stats, and achievements
class LearnerDashboardView extends StatefulWidget {
  final ProgressTrackingService progressService;
  final QuizProvider quizProvider;
  final String languageCode;
  final VoidCallback? onLessonSelected;
  final VoidCallback? onQuizSelected;

  const LearnerDashboardView({
    Key? key,
    required this.progressService,
    required this.quizProvider,
    required this.languageCode,
    this.onLessonSelected,
    this.onQuizSelected,
  }) : super(key: key);

  @override
  State<LearnerDashboardView> createState() => _LearnerDashboardViewState();
}

class _LearnerDashboardViewState extends State<LearnerDashboardView> {
  bool _isLoading = true;
  Map<String, dynamic>? _userStats;
  Map<String, dynamic>? _quizStats;
  List<Map<String, dynamic>>? _recentActivity;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);

      // Load user progress stats (mock data for now)
      final userStats = await _getMockUserStats();

      // Load quiz statistics
      final quizStats = await widget.quizProvider.getQuizStatistics(
        'current_user',
      );

      // Load recent activity (mock data for now)
      final recentActivity = await _getRecentActivity();

      setState(() {
        _userStats = userStats;
        _quizStats = quizStats;
        _recentActivity = recentActivity;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load dashboard: $e';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getMockUserStats() async {
    // Mock user statistics - in real app, this would come from the service
    return {
      'currentLevel': 3,
      'totalXP': 285,
      'lessonsCompleted': 7,
      'totalLessons': 12,
      'currentStreak': 5,
      'totalTimeSpent': 1440, // minutes
      'skillsLearned': ['vocabulary', 'pronunciation'],
    };
  }

  Future<List<Map<String, dynamic>>> _getRecentActivity() async {
    // Mock recent activity data
    return [
      {
        'type': 'lesson_completed',
        'title': 'Completed Vocabulary Lesson',
        'description': 'Basic greetings in Yemba',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'points': 25,
      },
      {
        'type': 'quiz_passed',
        'title': 'Passed Pronunciation Quiz',
        'description': 'Score: 85%',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        'points': 50,
      },
      {
        'type': 'milestone_achieved',
        'title': 'Reached Level 3!',
        'description': 'Completed 10 lessons',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'points': 100,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
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
                onPressed: _loadDashboardData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Learning Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section with level badge
              _buildWelcomeSection(),

              const SizedBox(height: 24),

              // Quick stats cards
              _buildStatsCards(),

              const SizedBox(height: 24),

              // Progress visualization
              _buildProgressSection(),

              const SizedBox(height: 24),

              // Recent activity
              _buildRecentActivity(),

              const SizedBox(height: 24),

              // Quick actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final level = _userStats?['currentLevel'] ?? 1;
    final xp = _userStats?['totalXP'] ?? 0;
    final nextLevelXP = level * 100; // Simple calculation

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Level badge
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lv.$level',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Welcome text and XP
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep up the great work learning ${widget.languageCode.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                // XP progress bar
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (xp % 100) / 100, // XP progress within level
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$xp / $nextLevelXP XP to next level',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final lessonsCompleted = _userStats?['lessonsCompleted'] ?? 0;
    final totalLessons = _userStats?['totalLessons'] ?? 10;
    final quizAverage = _quizStats?['averageScore'] ?? 0.0;
    final streakDays = _userStats?['currentStreak'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.book,
            value: '$lessonsCompleted/$totalLessons',
            label: 'Lessons',
            color: Colors.green,
            progress: lessonsCompleted / totalLessons,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.quiz,
            value: '${quizAverage.toStringAsFixed(0)}%',
            label: 'Quiz Avg',
            color: Colors.orange,
            progress: quizAverage / 100,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department,
            value: '$streakDays',
            label: 'Day Streak',
            color: Colors.red,
            progress: (streakDays % 7) / 7, // Weekly progress
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    double? progress,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    // Mock skill progress data
    final skills = [
      {'name': 'Vocabulary', 'progress': 0.75, 'level': 3},
      {'name': 'Grammar', 'progress': 0.6, 'level': 2},
      {'name': 'Pronunciation', 'progress': 0.45, 'level': 2},
      {'name': 'Conversation', 'progress': 0.3, 'level': 1},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skill Progress',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...skills.map(
          (skill) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      skill['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Level ${skill['level']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: skill['progress'] as double,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...(_recentActivity ?? []).map(
          (activity) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getActivityColor(
                  activity['type'] as String,
                ).withValues(alpha: 0.2),
                child: Icon(
                  _getActivityIcon(activity['type'] as String),
                  color: _getActivityColor(activity['type'] as String),
                ),
              ),
              title: Text(activity['title'] as String),
              subtitle: Text(activity['description'] as String),
              trailing: Text(
                '+${activity['points']} XP',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'lesson_completed':
        return Colors.green;
      case 'quiz_passed':
        return Colors.blue;
      case 'milestone_achieved':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'lesson_completed':
        return Icons.check_circle;
      case 'quiz_passed':
        return Icons.quiz;
      case 'milestone_achieved':
        return Icons.emoji_events;
      default:
        return Icons.info;
    }
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.play_arrow,
                label: 'Continue Lesson',
                onPressed: widget.onLessonSelected,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.quiz,
                label: 'Take Quiz',
                onPressed: widget.onQuizSelected,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
