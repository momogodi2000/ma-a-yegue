import '../../domain/entities/learner_entity.dart';

/// Learner data model for local storage and API communication
class LearnerModel {
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
  final Map<String, LanguageProgressModel> languageProgress;
  final List<String> completedLessons;
  final List<String> completedCourses;
  final List<AchievementModel> achievements;
  final LearningPreferencesModel preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LearnerModel({
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

  /// Convert from JSON
  factory LearnerModel.fromJson(Map<String, dynamic> json) {
    return LearnerModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      currentLevel: json['currentLevel'] as String,
      totalExperiencePoints: json['totalExperiencePoints'] as int,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      learningLanguages: List<String>.from(json['learningLanguages'] as List),
      languageProgress: (json['languageProgress'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          LanguageProgressModel.fromJson(value as Map<String, dynamic>),
        ),
      ),
      completedLessons: List<String>.from(json['completedLessons'] as List),
      completedCourses: List<String>.from(json['completedCourses'] as List),
      achievements: (json['achievements'] as List)
          .map(
            (achievement) =>
                AchievementModel.fromJson(achievement as Map<String, dynamic>),
          )
          .toList(),
      preferences: LearningPreferencesModel.fromJson(
        json['preferences'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'currentLevel': currentLevel,
      'totalExperiencePoints': totalExperiencePoints,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'joinedAt': joinedAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'learningLanguages': learningLanguages,
      'languageProgress': languageProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'completedLessons': completedLessons,
      'completedCourses': completedCourses,
      'achievements': achievements
          .map((achievement) => achievement.toJson())
          .toList(),
      'preferences': preferences.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to entity
  LearnerEntity toEntity() {
    return LearnerEntity(
      id: id,
      userId: userId,
      name: name,
      email: email,
      profileImageUrl: profileImageUrl,
      currentLevel: currentLevel,
      totalExperiencePoints: totalExperiencePoints,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      joinedAt: joinedAt,
      lastActiveAt: lastActiveAt,
      learningLanguages: learningLanguages,
      languageProgress: languageProgress.map(
        (key, value) => MapEntry(key, value.toEntity()),
      ),
      completedLessons: completedLessons,
      completedCourses: completedCourses,
      achievements: achievements
          .map((achievement) => achievement.toEntity())
          .toList(),
      preferences: preferences.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from entity
  factory LearnerModel.fromEntity(LearnerEntity entity) {
    return LearnerModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      profileImageUrl: entity.profileImageUrl,
      currentLevel: entity.currentLevel,
      totalExperiencePoints: entity.totalExperiencePoints,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      joinedAt: entity.joinedAt,
      lastActiveAt: entity.lastActiveAt,
      learningLanguages: entity.learningLanguages,
      languageProgress: entity.languageProgress.map(
        (key, value) => MapEntry(key, LanguageProgressModel.fromEntity(value)),
      ),
      completedLessons: entity.completedLessons,
      completedCourses: entity.completedCourses,
      achievements: entity.achievements
          .map((achievement) => AchievementModel.fromEntity(achievement))
          .toList(),
      preferences: LearningPreferencesModel.fromEntity(entity.preferences),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

/// Language progress data model
class LanguageProgressModel {
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
  final Map<String, double> skillScores;

  const LanguageProgressModel({
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

  factory LanguageProgressModel.fromJson(Map<String, dynamic> json) {
    return LanguageProgressModel(
      languageCode: json['languageCode'] as String,
      languageName: json['languageName'] as String,
      currentLevel: json['currentLevel'] as String,
      experiencePoints: json['experiencePoints'] as int,
      lessonsCompleted: json['lessonsCompleted'] as int,
      coursesCompleted: json['coursesCompleted'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      studyTimeMinutes: json['studyTimeMinutes'] as int,
      lastStudiedAt: DateTime.parse(json['lastStudiedAt'] as String),
      completedLessons: List<String>.from(json['completedLessons'] as List),
      completedCourses: List<String>.from(json['completedCourses'] as List),
      skillScores: Map<String, double>.from(json['skillScores'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'languageName': languageName,
      'currentLevel': currentLevel,
      'experiencePoints': experiencePoints,
      'lessonsCompleted': lessonsCompleted,
      'coursesCompleted': coursesCompleted,
      'accuracy': accuracy,
      'studyTimeMinutes': studyTimeMinutes,
      'lastStudiedAt': lastStudiedAt.toIso8601String(),
      'completedLessons': completedLessons,
      'completedCourses': completedCourses,
      'skillScores': skillScores,
    };
  }

  LanguageProgress toEntity() {
    return LanguageProgress(
      languageCode: languageCode,
      languageName: languageName,
      currentLevel: currentLevel,
      experiencePoints: experiencePoints,
      lessonsCompleted: lessonsCompleted,
      coursesCompleted: coursesCompleted,
      accuracy: accuracy,
      studyTimeMinutes: studyTimeMinutes,
      lastStudiedAt: lastStudiedAt,
      completedLessons: completedLessons,
      completedCourses: completedCourses,
      skillScores: skillScores,
    );
  }

  factory LanguageProgressModel.fromEntity(LanguageProgress entity) {
    return LanguageProgressModel(
      languageCode: entity.languageCode,
      languageName: entity.languageName,
      currentLevel: entity.currentLevel,
      experiencePoints: entity.experiencePoints,
      lessonsCompleted: entity.lessonsCompleted,
      coursesCompleted: entity.coursesCompleted,
      accuracy: entity.accuracy,
      studyTimeMinutes: entity.studyTimeMinutes,
      lastStudiedAt: entity.lastStudiedAt,
      completedLessons: entity.completedLessons,
      completedCourses: entity.completedCourses,
      skillScores: entity.skillScores,
    );
  }
}

/// Achievement data model
class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final AchievementType type;
  final int points;
  final DateTime earnedAt;
  final bool isUnlocked;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.type,
    required this.points,
    required this.earnedAt,
    required this.isUnlocked,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      type: AchievementType.values.firstWhere((e) => e.name == json['type']),
      points: json['points'] as int,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      isUnlocked: json['isUnlocked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'type': type.name,
      'points': points,
      'earnedAt': earnedAt.toIso8601String(),
      'isUnlocked': isUnlocked,
    };
  }

  Achievement toEntity() {
    return Achievement(
      id: id,
      title: title,
      description: description,
      iconUrl: iconUrl,
      type: type,
      points: points,
      earnedAt: earnedAt,
      isUnlocked: isUnlocked,
    );
  }

  factory AchievementModel.fromEntity(Achievement entity) {
    return AchievementModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      iconUrl: entity.iconUrl,
      type: entity.type,
      points: entity.points,
      earnedAt: entity.earnedAt,
      isUnlocked: entity.isUnlocked,
    );
  }
}

/// Learning preferences data model
class LearningPreferencesModel {
  final String preferredLanguage;
  final int dailyGoalMinutes;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final String difficultyPreference;
  final List<String> interestedTopics;
  final String studyTimePreference;
  final bool adaptiveLearningEnabled;

  const LearningPreferencesModel({
    required this.preferredLanguage,
    required this.dailyGoalMinutes,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.difficultyPreference,
    required this.interestedTopics,
    required this.studyTimePreference,
    required this.adaptiveLearningEnabled,
  });

  factory LearningPreferencesModel.fromJson(Map<String, dynamic> json) {
    return LearningPreferencesModel(
      preferredLanguage: json['preferredLanguage'] as String,
      dailyGoalMinutes: json['dailyGoalMinutes'] as int,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      soundEnabled: json['soundEnabled'] as bool,
      difficultyPreference: json['difficultyPreference'] as String,
      interestedTopics: List<String>.from(json['interestedTopics'] as List),
      studyTimePreference: json['studyTimePreference'] as String,
      adaptiveLearningEnabled: json['adaptiveLearningEnabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredLanguage': preferredLanguage,
      'dailyGoalMinutes': dailyGoalMinutes,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'difficultyPreference': difficultyPreference,
      'interestedTopics': interestedTopics,
      'studyTimePreference': studyTimePreference,
      'adaptiveLearningEnabled': adaptiveLearningEnabled,
    };
  }

  LearningPreferences toEntity() {
    return LearningPreferences(
      preferredLanguage: preferredLanguage,
      dailyGoalMinutes: dailyGoalMinutes,
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
      difficultyPreference: difficultyPreference,
      interestedTopics: interestedTopics,
      studyTimePreference: studyTimePreference,
      adaptiveLearningEnabled: adaptiveLearningEnabled,
    );
  }

  factory LearningPreferencesModel.fromEntity(LearningPreferences entity) {
    return LearningPreferencesModel(
      preferredLanguage: entity.preferredLanguage,
      dailyGoalMinutes: entity.dailyGoalMinutes,
      notificationsEnabled: entity.notificationsEnabled,
      soundEnabled: entity.soundEnabled,
      difficultyPreference: entity.difficultyPreference,
      interestedTopics: entity.interestedTopics,
      studyTimePreference: entity.studyTimePreference,
      adaptiveLearningEnabled: entity.adaptiveLearningEnabled,
    );
  }
}
