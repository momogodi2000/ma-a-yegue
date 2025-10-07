import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:maa_yegue/core/constants/app_dimensions.dart';
import 'package:maa_yegue/features/analytics/data/models/student_analytics_models.dart';

/// Chart widgets for analytics dashboard
class AnalyticsCharts {
  /// Performance Trend Chart - Shows quiz scores over time
  static Widget buildPerformanceChart(
    BuildContext context,
    PerformanceMetrics metrics,
  ) {
    // Mock data for demonstration - in real app this would come from historical data
    final List<FlSpot> spots = [
      const FlSpot(0, 65),
      const FlSpot(1, 70),
      const FlSpot(2, 68),
      const FlSpot(3, 75),
      const FlSpot(4, 78),
      const FlSpot(5, 82),
      const FlSpot(6, 85), // Current score
    ];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.blue),
                const SizedBox(width: AppDimensions.spacingSmall),
                Text(
                  'Performance Trend',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = [
                            'Week 1',
                            'Week 2',
                            'Week 3',
                            'Week 4',
                            'Week 5',
                            'Week 6',
                            'Current',
                          ];
                          if (value.toInt() < titles.length) {
                            return Text(
                              titles[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  minX: 0,
                  maxX: 6,
                  minY: 50,
                  maxY: 100,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                Text(
                  '+${metrics.improvementRate.toStringAsFixed(1)}% improvement trend',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Learning Progress Chart - Shows courses and lessons completion
  static Widget buildProgressChart(
    BuildContext context,
    LearningProgress progress,
  ) {
    final data = [
      ProgressData(
        'Enrolled',
        progress.enrolledCourses.toDouble(),
        Colors.blue,
      ),
      ProgressData(
        'Completed',
        progress.completedCourses.toDouble(),
        Colors.green,
      ),
    ];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Colors.orange),
                const SizedBox(width: AppDimensions.spacingSmall),
                Text(
                  'Course Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: data.map((item) {
                    return PieChartSectionData(
                      value: item.value,
                      title: '${item.value.toInt()}',
                      color: item.color,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 12, height: 12, color: Colors.blue),
                const SizedBox(width: AppDimensions.spacingSmall),
                const Text('Enrolled'),
                const SizedBox(width: AppDimensions.spacingMedium),
                Container(width: 12, height: 12, color: Colors.green),
                const SizedBox(width: AppDimensions.spacingSmall),
                const Text('Completed'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Learning Patterns Chart - Shows study time distribution
  static Widget buildStudyPatternsChart(
    BuildContext context,
    LearningPatterns patterns,
  ) {
    // Mock hourly data for demonstration
    final List<BarChartGroupData> barGroups = List.generate(24, (hour) {
      double value = 0;
      if (hour >= 8 && hour <= 22) {
        // Study hours
        // Simulate study pattern with peak at preferred hour
        final distance = (hour - patterns.preferredStudyHour).abs();
        value = (10 - distance) * 2.0;
        if (value < 0) value = 0;
      }
      return BarChartGroupData(
        x: hour,
        barRods: [
          BarChartRodData(
            toY: value,
            color: hour == patterns.preferredStudyHour
                ? Colors.purple
                : Colors.blue.withValues(alpha: 0.7),
            width: 8,
          ),
        ],
      );
    });

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
                  'Study Time Distribution',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 4 == 0) {
                            return Text('${value.toInt()}:00');
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}m');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Center(
              child: Text(
                'Peak study time: ${patterns.preferredStudyHour}:00',
                style: const TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Content Type Preferences Chart - Shows preferred learning content
  static Widget buildContentPreferencesChart(
    BuildContext context,
    LearningPatterns patterns,
  ) {
    final data = patterns.contentTypePreferences.entries.map((entry) {
      return ContentPreferenceData(
        entry.key,
        entry.value.toDouble(),
        _getContentColor(entry.key),
      );
    }).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.category, color: Colors.teal),
                const SizedBox(width: AppDimensions.spacingSmall),
                Text(
                  'Content Preferences',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            SizedBox(
              height: 200,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  dataSets: [
                    RadarDataSet(
                      dataEntries: data
                          .map((item) => RadarEntry(value: item.percentage))
                          .toList(),
                      borderColor: Colors.teal,
                      fillColor: Colors.teal.withValues(alpha: 0.1),
                      borderWidth: 2,
                      entryRadius: 3,
                    ),
                  ],
                  radarBorderData: const BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                  titlePositionPercentageOffset: 0.2,
                  titleTextStyle: const TextStyle(fontSize: 12),
                  getTitle: (index, angle) {
                    return RadarChartTitle(
                      text: data[index].contentType,
                      angle: angle,
                    );
                  },
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(fontSize: 10),
                  tickBorderData: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Wrap(
              spacing: AppDimensions.spacingSmall,
              runSpacing: AppDimensions.spacingSmall,
              children: data.map((item) {
                return Chip(
                  avatar: CircleAvatar(backgroundColor: item.color, radius: 8),
                  label: Text(
                    '${item.contentType}: ${item.percentage.toInt()}%',
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Achievement Progress Chart - Shows leveling progress
  static Widget buildAchievementProgressChart(
    BuildContext context,
    AchievementsData achievements,
  ) {
    final progress = achievements.nextLevelProgress / 100.0;

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
                  'Level Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Center(
              child: SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.amber,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Level ${achievements.level}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        Text(
                          '${achievements.nextLevelProgress}%',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: AppDimensions.spacingSmall),
                Text(
                  '${achievements.totalPoints} total points',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Color _getContentColor(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'video':
        return Colors.red;
      case 'audio':
        return Colors.blue;
      case 'text':
        return Colors.green;
      case 'quiz':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

/// Helper data classes for charts
class ProgressData {
  final String label;
  final double value;
  final Color color;

  const ProgressData(this.label, this.value, this.color);
}

class ContentPreferenceData {
  final String contentType;
  final double percentage;
  final Color color;

  const ContentPreferenceData(this.contentType, this.percentage, this.color);
}
