/// Data models for student analytics
class StudentAnalytics {
  final String userId;
  final LearningProgress learningProgress;
  final PerformanceMetrics performanceMetrics;
  final LearningPatterns learningPatterns;
  final AchievementsData achievements;
  final DateTime lastUpdated;

  const StudentAnalytics({
    required this.userId,
    required this.learningProgress,
    required this.performanceMetrics,
    required this.learningPatterns,
    required this.achievements,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'learningProgress': learningProgress.toJson(),
    'performanceMetrics': performanceMetrics.toJson(),
    'learningPatterns': learningPatterns.toJson(),
    'achievements': achievements.toJson(),
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory StudentAnalytics.fromJson(Map<String, dynamic> json) {
    return StudentAnalytics(
      userId: json['userId'],
      learningProgress: LearningProgress.fromJson(json['learningProgress']),
      performanceMetrics: PerformanceMetrics.fromJson(json['performanceMetrics']),
      learningPatterns: LearningPatterns.fromJson(json['learningPatterns']),
      achievements: AchievementsData.fromJson(json['achievements']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

class LearningProgress {
  final int enrolledCourses;
  final int completedCourses;
  final int completedLessons;
  final int totalStudyTimeMinutes;
  final int currentStreak;
  final int longestStreak;

  const LearningProgress({
    required this.enrolledCourses,
    required this.completedCourses,
    required this.completedLessons,
    required this.totalStudyTimeMinutes,
    required this.currentStreak,
    required this.longestStreak,
  });

  Map<String, dynamic> toJson() => {
    'enrolledCourses': enrolledCourses,
    'completedCourses': completedCourses,
    'completedLessons': completedLessons,
    'totalStudyTimeMinutes': totalStudyTimeMinutes,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
  };

  factory LearningProgress.fromJson(Map<String, dynamic> json) {
    return LearningProgress(
      enrolledCourses: json['enrolledCourses'],
      completedCourses: json['completedCourses'],
      completedLessons: json['completedLessons'],
      totalStudyTimeMinutes: json['totalStudyTimeMinutes'],
      currentStreak: json['currentStreak'],
      longestStreak: json['longestStreak'],
    );
  }
}

class PerformanceMetrics {
  final double averageQuizScore;
  final int totalQuizzesTaken;
  final Map<String, dynamic> languagePerformance;
  final double improvementRate;
  final List<String> strengths;
  final List<String> weaknesses;

  const PerformanceMetrics({
    required this.averageQuizScore,
    required this.totalQuizzesTaken,
    required this.languagePerformance,
    required this.improvementRate,
    required this.strengths,
    required this.weaknesses,
  });

  Map<String, dynamic> toJson() => {
    'averageQuizScore': averageQuizScore,
    'totalQuizzesTaken': totalQuizzesTaken,
    'languagePerformance': languagePerformance,
    'improvementRate': improvementRate,
    'strengths': strengths,
    'weaknesses': weaknesses,
  };

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      averageQuizScore: json['averageQuizScore'],
      totalQuizzesTaken: json['totalQuizzesTaken'],
      languagePerformance: json['languagePerformance'],
      improvementRate: json['improvementRate'],
      strengths: List<String>.from(json['strengths']),
      weaknesses: List<String>.from(json['weaknesses']),
    );
  }
}

class LearningPatterns {
  final int preferredStudyHour;
  final String preferredStudyDay;
  final Map<String, int> contentTypePreferences;
  final int averageSessionDuration;
  final double consistencyScore;
  final int recommendedStudyTime;

  const LearningPatterns({
    required this.preferredStudyHour,
    required this.preferredStudyDay,
    required this.contentTypePreferences,
    required this.averageSessionDuration,
    required this.consistencyScore,
    required this.recommendedStudyTime,
  });

  Map<String, dynamic> toJson() => {
    'preferredStudyHour': preferredStudyHour,
    'preferredStudyDay': preferredStudyDay,
    'contentTypePreferences': contentTypePreferences,
    'averageSessionDuration': averageSessionDuration,
    'consistencyScore': consistencyScore,
    'recommendedStudyTime': recommendedStudyTime,
  };

  factory LearningPatterns.fromJson(Map<String, dynamic> json) {
    return LearningPatterns(
      preferredStudyHour: json['preferredStudyHour'],
      preferredStudyDay: json['preferredStudyDay'],
      contentTypePreferences: Map<String, int>.from(json['contentTypePreferences']),
      averageSessionDuration: json['averageSessionDuration'],
      consistencyScore: json['consistencyScore'],
      recommendedStudyTime: json['recommendedStudyTime'],
    );
  }
}

class AchievementsData {
  final List<Badge> earnedBadges;
  final int totalPoints;
  final int level;
  final int nextLevelProgress;

  const AchievementsData({
    required this.earnedBadges,
    required this.totalPoints,
    required this.level,
    required this.nextLevelProgress,
  });

  Map<String, dynamic> toJson() => {
    'earnedBadges': earnedBadges.map((b) => b.toJson()).toList(),
    'totalPoints': totalPoints,
    'level': level,
    'nextLevelProgress': nextLevelProgress,
  };

  factory AchievementsData.fromJson(Map<String, dynamic> json) {
    return AchievementsData(
      earnedBadges: (json['earnedBadges'] as List).map((b) => Badge.fromJson(b)).toList(),
      totalPoints: json['totalPoints'],
      level: json['level'],
      nextLevelProgress: json['nextLevelProgress'],
    );
  }
}

class Badge {
  final String name;
  final String icon;
  final DateTime earnedAt;

  const Badge({
    required this.name,
    required this.icon,
    required this.earnedAt,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'icon': icon,
    'earnedAt': earnedAt.toIso8601String(),
  };

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      name: json['name'],
      icon: json['icon'],
      earnedAt: DateTime.parse(json['earnedAt']),
    );
  }
}
