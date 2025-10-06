import 'package:equatable/equatable.dart';
import 'user_level_entity.dart';

/// Comprehensive progress tracking entity for a user's learning journey
class LearningProgressEntity extends Equatable {
  final String id;
  final String userId;
  final String languageCode;
  
  // Overall progress
  final int totalLessonsCompleted;
  final int totalCoursesCompleted;
  final int totalPoints;
  final int totalTimeSpentMinutes;
  final LearningLevel currentLevel;
  
  // Streaks and consistency
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStudyDate;
  final List<DateTime> studyDates; // For tracking study history
  
  // Skill breakdown
  final Map<String, SkillProgress> skillProgress;
  
  // Recent activity
  final List<String> recentlyCompletedLessons;
  final List<String> inProgressLessons;
  final List<String> recommendedLessons;
  
  // Achievements and milestones
  final List<String> unlockedAchievements;
  final List<Milestone> completedMilestones;
  
  // Performance metrics
  final double averageQuizScore;
  final int totalQuizzesTaken;
  final int totalCorrectAnswers;
  final int totalAnswers;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;

  const LearningProgressEntity({
    required this.id,
    required this.userId,
    required this.languageCode,
    required this.totalLessonsCompleted,
    required this.totalCoursesCompleted,
    required this.totalPoints,
    required this.totalTimeSpentMinutes,
    required this.currentLevel,
    required this.currentStreak,
    required this.longestStreak,
    this.lastStudyDate,
    required this.studyDates,
    required this.skillProgress,
    required this.recentlyCompletedLessons,
    required this.inProgressLessons,
    required this.recommendedLessons,
    required this.unlockedAchievements,
    required this.completedMilestones,
    required this.averageQuizScore,
    required this.totalQuizzesTaken,
    required this.totalCorrectAnswers,
    required this.totalAnswers,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
  });

  /// Calculate overall accuracy percentage
  double get accuracy {
    if (totalAnswers == 0) return 0.0;
    return (totalCorrectAnswers / totalAnswers) * 100;
  }

  /// Check if user studied today
  bool get studiedToday {
    if (lastStudyDate == null) return false;
    final now = DateTime.now();
    return lastStudyDate!.year == now.year &&
        lastStudyDate!.month == now.month &&
        lastStudyDate!.day == now.day;
  }

  /// Get total hours studied
  double get totalHoursStudied => totalTimeSpentMinutes / 60.0;

  /// Get study frequency (days per week)
  double get studyFrequency {
    if (studyDates.length < 2) return studyDates.length.toDouble();
    
    final oldestDate = studyDates.first;
    final newestDate = studyDates.last;
    final daysDifference = newestDate.difference(oldestDate).inDays;
    
    if (daysDifference == 0) return studyDates.length.toDouble();
    
    final weeks = daysDifference / 7.0;
    return studyDates.length / weeks;
  }

  /// Get completion rate (percentage of started lessons that are completed)
  double get completionRate {
    final totalStarted = totalLessonsCompleted + inProgressLessons.length;
    if (totalStarted == 0) return 0.0;
    return (totalLessonsCompleted / totalStarted) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        languageCode,
        totalLessonsCompleted,
        totalCoursesCompleted,
        totalPoints,
        totalTimeSpentMinutes,
        currentLevel,
        currentStreak,
        longestStreak,
        lastStudyDate,
        studyDates,
        skillProgress,
        recentlyCompletedLessons,
        inProgressLessons,
        recommendedLessons,
        unlockedAchievements,
        completedMilestones,
        averageQuizScore,
        totalQuizzesTaken,
        totalCorrectAnswers,
        totalAnswers,
        createdAt,
        updatedAt,
        lastSyncedAt,
      ];

  LearningProgressEntity copyWith({
    String? id,
    String? userId,
    String? languageCode,
    int? totalLessonsCompleted,
    int? totalCoursesCompleted,
    int? totalPoints,
    int? totalTimeSpentMinutes,
    LearningLevel? currentLevel,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastStudyDate,
    List<DateTime>? studyDates,
    Map<String, SkillProgress>? skillProgress,
    List<String>? recentlyCompletedLessons,
    List<String>? inProgressLessons,
    List<String>? recommendedLessons,
    List<String>? unlockedAchievements,
    List<Milestone>? completedMilestones,
    double? averageQuizScore,
    int? totalQuizzesTaken,
    int? totalCorrectAnswers,
    int? totalAnswers,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
  }) {
    return LearningProgressEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      languageCode: languageCode ?? this.languageCode,
      totalLessonsCompleted: totalLessonsCompleted ?? this.totalLessonsCompleted,
      totalCoursesCompleted: totalCoursesCompleted ?? this.totalCoursesCompleted,
      totalPoints: totalPoints ?? this.totalPoints,
      totalTimeSpentMinutes: totalTimeSpentMinutes ?? this.totalTimeSpentMinutes,
      currentLevel: currentLevel ?? this.currentLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      studyDates: studyDates ?? this.studyDates,
      skillProgress: skillProgress ?? this.skillProgress,
      recentlyCompletedLessons: recentlyCompletedLessons ?? this.recentlyCompletedLessons,
      inProgressLessons: inProgressLessons ?? this.inProgressLessons,
      recommendedLessons: recommendedLessons ?? this.recommendedLessons,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      completedMilestones: completedMilestones ?? this.completedMilestones,
      averageQuizScore: averageQuizScore ?? this.averageQuizScore,
      totalQuizzesTaken: totalQuizzesTaken ?? this.totalQuizzesTaken,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalAnswers: totalAnswers ?? this.totalAnswers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

/// Skill progress for specific language skills
class SkillProgress extends Equatable {
  final String skillName; // e.g., 'vocabulary', 'grammar', 'pronunciation', 'listening'
  final double proficiency; // 0-100
  final int lessonsCompleted;
  final int exercisesCompleted;
  final DateTime lastPracticed;

  const SkillProgress({
    required this.skillName,
    required this.proficiency,
    required this.lessonsCompleted,
    required this.exercisesCompleted,
    required this.lastPracticed,
  });

  /// Get proficiency level as enum
  SkillLevel get level {
    if (proficiency >= 90) return SkillLevel.expert;
    if (proficiency >= 70) return SkillLevel.advanced;
    if (proficiency >= 40) return SkillLevel.intermediate;
    return SkillLevel.beginner;
  }

  @override
  List<Object?> get props => [
        skillName,
        proficiency,
        lessonsCompleted,
        exercisesCompleted,
        lastPracticed,
      ];

  SkillProgress copyWith({
    String? skillName,
    double? proficiency,
    int? lessonsCompleted,
    int? exercisesCompleted,
    DateTime? lastPracticed,
  }) {
    return SkillProgress(
      skillName: skillName ?? this.skillName,
      proficiency: proficiency ?? this.proficiency,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
      lastPracticed: lastPracticed ?? this.lastPracticed,
    );
  }
}

/// Skill level enum
enum SkillLevel {
  beginner,
  intermediate,
  advanced,
  expert;

  String get displayName {
    switch (this) {
      case SkillLevel.beginner:
        return 'Débutant';
      case SkillLevel.intermediate:
        return 'Intermédiaire';
      case SkillLevel.advanced:
        return 'Avancé';
      case SkillLevel.expert:
        return 'Expert';
    }
  }
}

/// Milestone entity
class Milestone extends Equatable {
  final String id;
  final String name;
  final String description;
  final MilestoneType type;
  final int targetValue;
  final int currentValue;
  final DateTime? completedAt;
  final String? rewardDescription;
  final int rewardPoints;

  const Milestone({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    this.completedAt,
    this.rewardDescription,
    required this.rewardPoints,
  });

  bool get isCompleted => currentValue >= targetValue;
  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        targetValue,
        currentValue,
        completedAt,
        rewardDescription,
        rewardPoints,
      ];
}

/// Milestone type enum
enum MilestoneType {
  lessonsCompleted,
  coursesCompleted,
  pointsEarned,
  streakDays,
  quizzesPassed,
  timeStudied,
  skillMastered;

  String get displayName {
    switch (this) {
      case MilestoneType.lessonsCompleted:
        return 'Leçons terminées';
      case MilestoneType.coursesCompleted:
        return 'Cours terminés';
      case MilestoneType.pointsEarned:
        return 'Points gagnés';
      case MilestoneType.streakDays:
        return 'Jours consécutifs';
      case MilestoneType.quizzesPassed:
        return 'Quiz réussis';
      case MilestoneType.timeStudied:
        return 'Temps d\'étude';
      case MilestoneType.skillMastered:
        return 'Compétence maîtrisée';
    }
  }
}
