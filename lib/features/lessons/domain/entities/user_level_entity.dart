import 'package:equatable/equatable.dart';

/// User level entity representing the learner's proficiency level
class UserLevelEntity extends Equatable {
  final String id;
  final String userId;
  final String languageCode;
  final LearningLevel currentLevel;
  final int currentPoints;
  final int pointsToNextLevel;
  final double completionPercentage;
  final DateTime levelAchievedAt;
  final DateTime? lastAssessmentDate;
  final List<String> completedLessons;
  final List<String> unlockedCourses;
  final Map<String, dynamic> skillScores; // e.g., {"vocabulary": 85, "grammar": 70}
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserLevelEntity({
    required this.id,
    required this.userId,
    required this.languageCode,
    required this.currentLevel,
    required this.currentPoints,
    required this.pointsToNextLevel,
    required this.completionPercentage,
    required this.levelAchievedAt,
    this.lastAssessmentDate,
    required this.completedLessons,
    required this.unlockedCourses,
    required this.skillScores,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if user can level up
  bool get canLevelUp => currentPoints >= pointsToNextLevel;

  /// Get next level
  LearningLevel? get nextLevel {
    switch (currentLevel) {
      case LearningLevel.beginner:
        return LearningLevel.intermediate;
      case LearningLevel.intermediate:
        return LearningLevel.advanced;
      case LearningLevel.advanced:
        return LearningLevel.expert;
      case LearningLevel.expert:
        return null; // Already at max level
    }
  }

  /// Get level progress (0.0 to 1.0)
  double get levelProgress {
    if (pointsToNextLevel == 0) return 1.0;
    return (currentPoints / pointsToNextLevel).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        languageCode,
        currentLevel,
        currentPoints,
        pointsToNextLevel,
        completionPercentage,
        levelAchievedAt,
        lastAssessmentDate,
        completedLessons,
        unlockedCourses,
        skillScores,
        createdAt,
        updatedAt,
      ];

  UserLevelEntity copyWith({
    String? id,
    String? userId,
    String? languageCode,
    LearningLevel? currentLevel,
    int? currentPoints,
    int? pointsToNextLevel,
    double? completionPercentage,
    DateTime? levelAchievedAt,
    DateTime? lastAssessmentDate,
    List<String>? completedLessons,
    List<String>? unlockedCourses,
    Map<String, dynamic>? skillScores,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserLevelEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      languageCode: languageCode ?? this.languageCode,
      currentLevel: currentLevel ?? this.currentLevel,
      currentPoints: currentPoints ?? this.currentPoints,
      pointsToNextLevel: pointsToNextLevel ?? this.pointsToNextLevel,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      levelAchievedAt: levelAchievedAt ?? this.levelAchievedAt,
      lastAssessmentDate: lastAssessmentDate ?? this.lastAssessmentDate,
      completedLessons: completedLessons ?? this.completedLessons,
      unlockedCourses: unlockedCourses ?? this.unlockedCourses,
      skillScores: skillScores ?? this.skillScores,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Learning level enum
enum LearningLevel {
  beginner,
  intermediate,
  advanced,
  expert;

  /// Get display name
  String get displayName {
    switch (this) {
      case LearningLevel.beginner:
        return 'Débutant';
      case LearningLevel.intermediate:
        return 'Intermédiaire';
      case LearningLevel.advanced:
        return 'Avancé';
      case LearningLevel.expert:
        return 'Expert';
    }
  }

  /// Get level description
  String get description {
    switch (this) {
      case LearningLevel.beginner:
        return 'Découvrez les bases de la langue';
      case LearningLevel.intermediate:
        return 'Renforcez vos compétences linguistiques';
      case LearningLevel.advanced:
        return 'Maîtrisez les concepts complexes';
      case LearningLevel.expert:
        return 'Perfectionnez votre maîtrise de la langue';
    }
  }

  /// Get points required to reach this level from beginner
  int get requiredPoints {
    switch (this) {
      case LearningLevel.beginner:
        return 0;
      case LearningLevel.intermediate:
        return 1000;
      case LearningLevel.advanced:
        return 3000;
      case LearningLevel.expert:
        return 7000;
    }
  }

  /// Get color for UI representation
  String get colorHex {
    switch (this) {
      case LearningLevel.beginner:
        return '#4CAF50'; // Green
      case LearningLevel.intermediate:
        return '#2196F3'; // Blue
      case LearningLevel.advanced:
        return '#FF9800'; // Orange
      case LearningLevel.expert:
        return '#9C27B0'; // Purple
    }
  }

  /// Get icon name
  String get icon {
    switch (this) {
      case LearningLevel.beginner:
        return 'school';
      case LearningLevel.intermediate:
        return 'trending_up';
      case LearningLevel.advanced:
        return 'stars';
      case LearningLevel.expert:
        return 'emoji_events';
    }
  }

  /// Parse from string
  static LearningLevel fromString(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
      case 'débutant':
        return LearningLevel.beginner;
      case 'intermediate':
      case 'intermédiaire':
        return LearningLevel.intermediate;
      case 'advanced':
      case 'avancé':
        return LearningLevel.advanced;
      case 'expert':
        return LearningLevel.expert;
      default:
        return LearningLevel.beginner;
    }
  }
}

/// Level requirements and configuration
class LevelRequirements {
  /// Points required for each level
  static const Map<LearningLevel, int> pointsRequired = {
    LearningLevel.beginner: 0,
    LearningLevel.intermediate: 1000,
    LearningLevel.advanced: 3000,
    LearningLevel.expert: 7000,
  };

  /// Minimum lessons to complete before level assessment
  static const Map<LearningLevel, int> minimumLessons = {
    LearningLevel.beginner: 5,
    LearningLevel.intermediate: 15,
    LearningLevel.advanced: 30,
    LearningLevel.expert: 50,
  };

  /// Minimum assessment score to pass (percentage)
  static const Map<LearningLevel, double> minimumAssessmentScore = {
    LearningLevel.beginner: 60.0,
    LearningLevel.intermediate: 70.0,
    LearningLevel.advanced: 80.0,
    LearningLevel.expert: 90.0,
  };

  /// Get points for next level
  static int getPointsToNextLevel(LearningLevel currentLevel) {
    switch (currentLevel) {
      case LearningLevel.beginner:
        return pointsRequired[LearningLevel.intermediate]!;
      case LearningLevel.intermediate:
        return pointsRequired[LearningLevel.advanced]!;
      case LearningLevel.advanced:
        return pointsRequired[LearningLevel.expert]!;
      case LearningLevel.expert:
        return 0; // Max level reached
    }
  }

  /// Calculate level from points
  static LearningLevel getLevelFromPoints(int points) {
    if (points >= pointsRequired[LearningLevel.expert]!) {
      return LearningLevel.expert;
    } else if (points >= pointsRequired[LearningLevel.advanced]!) {
      return LearningLevel.advanced;
    } else if (points >= pointsRequired[LearningLevel.intermediate]!) {
      return LearningLevel.intermediate;
    } else {
      return LearningLevel.beginner;
    }
  }
}
