import 'package:equatable/equatable.dart';

/// Learner entity representing a student/learner in the system
class LearnerEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String currentLevel;
  final int totalExperiencePoints;
  final int currentStreak;
  final int longestStreak;
  final DateTime joinedAt;
  final DateTime lastActiveAt;
  final List<String> learningLanguages;
  final Map<String, LanguageProgress> languageProgress;
  final List<String> completedLessons;
  final List<String> completedCourses;
  final List<Achievement> achievements;
  final LearningPreferences preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LearnerEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.currentLevel,
    required this.totalExperiencePoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.joinedAt,
    required this.lastActiveAt,
    required this.learningLanguages,
    required this.languageProgress,
    required this.completedLessons,
    required this.completedCourses,
    required this.achievements,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get progress for a specific language
  LanguageProgress? getLanguageProgress(String languageCode) {
    return languageProgress[languageCode];
  }

  /// Check if learner has completed a lesson
  bool hasCompletedLesson(String lessonId) {
    return completedLessons.contains(lessonId);
  }

  /// Check if learner has completed a course
  bool hasCompletedCourse(String courseId) {
    return completedCourses.contains(courseId);
  }

  /// Get total lessons completed across all languages
  int get totalLessonsCompleted => completedLessons.length;

  /// Get total courses completed
  int get totalCoursesCompleted => completedCourses.length;

  /// Get level progress percentage
  double getLevelProgress(String languageCode) {
    final progress = getLanguageProgress(languageCode);
    if (progress == null) return 0.0;
    return progress.levelProgress;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    email,
    profileImageUrl,
    currentLevel,
    totalExperiencePoints,
    currentStreak,
    longestStreak,
    joinedAt,
    lastActiveAt,
    learningLanguages,
    languageProgress,
    completedLessons,
    completedCourses,
    achievements,
    preferences,
    createdAt,
    updatedAt,
  ];
}

/// Language-specific progress for a learner
class LanguageProgress extends Equatable {
  final String languageCode;
  final String languageName;
  final String currentLevel;
  final int experiencePoints;
  final int lessonsCompleted;
  final int coursesCompleted;
  final double accuracy;
  final int studyTimeMinutes;
  final DateTime lastStudiedAt;
  final List<String> completedLessons;
  final List<String> completedCourses;
  final Map<String, double>
  skillScores; // grammar, vocabulary, pronunciation, etc.

  const LanguageProgress({
    required this.languageCode,
    required this.languageName,
    required this.currentLevel,
    required this.experiencePoints,
    required this.lessonsCompleted,
    required this.coursesCompleted,
    required this.accuracy,
    required this.studyTimeMinutes,
    required this.lastStudiedAt,
    required this.completedLessons,
    required this.completedCourses,
    required this.skillScores,
  });

  /// Get overall level progress (0.0 to 1.0)
  double get levelProgress {
    // Calculate progress based on experience points
    // This is a simplified calculation - in reality, you'd have level thresholds
    return (experiencePoints % 1000) / 1000.0;
  }

  /// Get average skill score
  double get averageSkillScore {
    if (skillScores.isEmpty) return 0.0;
    final total = skillScores.values.fold(0.0, (sum, score) => sum + score);
    return total / skillScores.length;
  }

  @override
  List<Object?> get props => [
    languageCode,
    languageName,
    currentLevel,
    experiencePoints,
    lessonsCompleted,
    coursesCompleted,
    accuracy,
    studyTimeMinutes,
    lastStudiedAt,
    completedLessons,
    completedCourses,
    skillScores,
  ];
}

/// Achievement entity
class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final AchievementType type;
  final int points;
  final DateTime earnedAt;
  final bool isUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.type,
    required this.points,
    required this.earnedAt,
    required this.isUnlocked,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    iconUrl,
    type,
    points,
    earnedAt,
    isUnlocked,
  ];
}

/// Learning preferences for a learner
class LearningPreferences extends Equatable {
  final String preferredLanguage;
  final int dailyGoalMinutes;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final String difficultyPreference;
  final List<String> interestedTopics;
  final String studyTimePreference; // morning, afternoon, evening
  final bool adaptiveLearningEnabled;

  const LearningPreferences({
    required this.preferredLanguage,
    required this.dailyGoalMinutes,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.difficultyPreference,
    required this.interestedTopics,
    required this.studyTimePreference,
    required this.adaptiveLearningEnabled,
  });

  @override
  List<Object?> get props => [
    preferredLanguage,
    dailyGoalMinutes,
    notificationsEnabled,
    soundEnabled,
    difficultyPreference,
    interestedTopics,
    studyTimePreference,
    adaptiveLearningEnabled,
  ];
}

/// Achievement types
enum AchievementType {
  lessonCompletion,
  streak,
  accuracy,
  timeSpent,
  levelUp,
  courseCompletion,
  special,
}

/// Learning level enumeration
enum LearningLevel {
  beginner,
  elementary,
  intermediate,
  upperIntermediate,
  advanced,
  proficient,
}

/// Extension to get level display names
extension LearningLevelExtension on LearningLevel {
  String get displayName {
    switch (this) {
      case LearningLevel.beginner:
        return 'Débutant';
      case LearningLevel.elementary:
        return 'Élémentaire';
      case LearningLevel.intermediate:
        return 'Intermédiaire';
      case LearningLevel.upperIntermediate:
        return 'Intermédiaire Avancé';
      case LearningLevel.advanced:
        return 'Avancé';
      case LearningLevel.proficient:
        return 'Compétent';
    }
  }

  String get description {
    switch (this) {
      case LearningLevel.beginner:
        return 'Vous commencez à apprendre cette langue';
      case LearningLevel.elementary:
        return 'Vous connaissez les bases de la langue';
      case LearningLevel.intermediate:
        return 'Vous pouvez communiquer dans des situations familières';
      case LearningLevel.upperIntermediate:
        return 'Vous pouvez exprimer des idées complexes';
      case LearningLevel.advanced:
        return 'Vous maîtrisez la langue dans la plupart des contextes';
      case LearningLevel.proficient:
        return 'Vous maîtrisez la langue comme un locuteur natif';
    }
  }
}
