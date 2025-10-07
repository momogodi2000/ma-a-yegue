import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maa_yegue/features/lessons/domain/entities/user_level_entity.dart';

/// Service for managing user levels and adaptive learning paths
class LevelManagementService {
  final Database _database;
  final FirebaseFirestore _firestore;

  LevelManagementService(this._database, this._firestore);

  /// Get user's current level for a language
  Future<UserLevelEntity?> getUserLevel(
    String userId,
    String languageCode,
  ) async {
    try {
      // Try to get from SQLite first
      final results = await _database.query(
        'user_levels',
        where: 'user_id = ? AND language_code = ?',
        whereArgs: [userId, languageCode],
        limit: 1,
      );

      if (results.isNotEmpty) {
        return _mapToUserLevel(results.first);
      }

      // If not in SQLite, try Firebase
      final doc = await _firestore
          .collection('user_levels')
          .doc('${userId}_$languageCode')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final level = UserLevelEntity(
          id: doc.id,
          userId: userId,
          languageCode: languageCode,
          currentLevel: LearningLevel.fromString(
            data['currentLevel'] ?? 'beginner',
          ),
          currentPoints: data['currentPoints'] ?? 0,
          pointsToNextLevel: data['pointsToNextLevel'] ?? 1000,
          completionPercentage: (data['completionPercentage'] ?? 0.0)
              .toDouble(),
          levelAchievedAt: DateTime.parse(data['levelAchievedAt']),
          lastAssessmentDate: data['lastAssessmentDate'] != null
              ? DateTime.parse(data['lastAssessmentDate'])
              : null,
          completedLessons: List<String>.from(data['completedLessons'] ?? []),
          unlockedCourses: List<String>.from(data['unlockedCourses'] ?? []),
          skillScores: Map<String, dynamic>.from(data['skillScores'] ?? {}),
          createdAt: DateTime.parse(data['createdAt']),
          updatedAt: DateTime.parse(data['updatedAt']),
        );

        // Cache in SQLite for offline access
        await _saveUserLevelToSQLite(level);

        return level;
      }

      return null;
    } catch (e) {
      debugPrint('Error getting user level: $e');
      return null;
    }
  }

  /// Initialize user level (for new users)
  Future<UserLevelEntity> initializeUserLevel(
    String userId,
    String languageCode, {
    LearningLevel? initialLevel,
  }) async {
    final level = UserLevelEntity(
      id: '${userId}_$languageCode',
      userId: userId,
      languageCode: languageCode,
      currentLevel: initialLevel ?? LearningLevel.beginner,
      currentPoints: 0,
      pointsToNextLevel: LevelRequirements.getPointsToNextLevel(
        initialLevel ?? LearningLevel.beginner,
      ),
      completionPercentage: 0.0,
      levelAchievedAt: DateTime.now(),
      completedLessons: const [],
      unlockedCourses: _getInitialUnlockedCourses(
        initialLevel ?? LearningLevel.beginner,
      ),
      skillScores: _initializeSkillScores(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to both SQLite and Firebase
    await Future.wait([
      _saveUserLevelToSQLite(level),
      _saveUserLevelToFirebase(level),
    ]);

    return level;
  }

  /// Add points to user and check for level up
  Future<UserLevelEntity> addPoints(
    String userId,
    String languageCode,
    int points, {
    String? skillCategory,
  }) async {
    var userLevel = await getUserLevel(userId, languageCode);

    userLevel ??= await initializeUserLevel(userId, languageCode);

    final newPoints = userLevel.currentPoints + points;
    var updatedLevel = userLevel.copyWith(
      currentPoints: newPoints,
      updatedAt: DateTime.now(),
    );

    // Update skill score if category provided
    if (skillCategory != null) {
      final skillScores = Map<String, dynamic>.from(userLevel.skillScores);
      final currentScore = (skillScores[skillCategory] ?? 0) as int;
      skillScores[skillCategory] = currentScore + points;
      updatedLevel = updatedLevel.copyWith(skillScores: skillScores);
    }

    // Check if user can level up
    if (updatedLevel.canLevelUp && updatedLevel.nextLevel != null) {
      updatedLevel = await _levelUp(updatedLevel);
    }

    // Save updates
    await Future.wait([
      _saveUserLevelToSQLite(updatedLevel),
      _saveUserLevelToFirebase(updatedLevel),
    ]);

    return updatedLevel;
  }

  /// Mark lesson as completed
  Future<UserLevelEntity> completedLesson(
    String userId,
    String languageCode,
    String lessonId,
    int earnedPoints,
  ) async {
    var userLevel = await getUserLevel(userId, languageCode);

    userLevel ??= await initializeUserLevel(userId, languageCode);

    final completedLessons = List<String>.from(userLevel.completedLessons);
    if (!completedLessons.contains(lessonId)) {
      completedLessons.add(lessonId);
    }

    var updatedLevel = userLevel.copyWith(
      completedLessons: completedLessons,
      currentPoints: userLevel.currentPoints + earnedPoints,
      updatedAt: DateTime.now(),
    );

    // Check if user can level up
    if (updatedLevel.canLevelUp && updatedLevel.nextLevel != null) {
      // Check if minimum lessons requirement met
      final minLessons =
          LevelRequirements.minimumLessons[updatedLevel.currentLevel] ?? 0;
      if (completedLessons.length >= minLessons) {
        updatedLevel = await _levelUp(updatedLevel);
      }
    }

    // Save updates
    await Future.wait([
      _saveUserLevelToSQLite(updatedLevel),
      _saveUserLevelToFirebase(updatedLevel),
    ]);

    return updatedLevel;
  }

  /// Get recommended lessons based on user level
  Future<List<String>> getRecommendedLessons(
    String userId,
    String languageCode, {
    int limit = 10,
  }) async {
    final userLevel = await getUserLevel(userId, languageCode);

    if (userLevel == null) {
      return [];
    }

    // Get lessons from Firebase that match user's level
    final lessonsSnapshot = await _firestore
        .collection('lessons')
        .where('languageCode', isEqualTo: languageCode)
        .where('difficulty', isEqualTo: userLevel.currentLevel.name)
        .where('isPublished', isEqualTo: true)
        .limit(limit)
        .get();

    final recommendedIds = <String>[];

    for (final doc in lessonsSnapshot.docs) {
      // Skip already completed lessons
      if (!userLevel.completedLessons.contains(doc.id)) {
        recommendedIds.add(doc.id);
      }
    }

    return recommendedIds;
  }

  /// Check if lesson is unlocked for user
  Future<bool> isLessonUnlocked(
    String userId,
    String languageCode,
    String lessonId,
  ) async {
    final userLevel = await getUserLevel(userId, languageCode);

    if (userLevel == null) {
      return false;
    }

    // Get lesson details
    final lessonDoc = await _firestore
        .collection('lessons')
        .doc(lessonId)
        .get();

    if (!lessonDoc.exists) {
      return false;
    }

    final lessonData = lessonDoc.data()!;
    final lessonLevel = LearningLevel.fromString(
      lessonData['difficulty'] ?? 'beginner',
    );
    final prerequisites = List<String>.from(lessonData['prerequisites'] ?? []);

    // Check if user's level is high enough
    if (lessonLevel.index > userLevel.currentLevel.index) {
      return false;
    }

    // Check if all prerequisites are completed
    for (final prereq in prerequisites) {
      if (!userLevel.completedLessons.contains(prereq)) {
        return false;
      }
    }

    return true;
  }

  /// Level up the user
  Future<UserLevelEntity> _levelUp(UserLevelEntity currentLevel) async {
    final nextLevel = currentLevel.nextLevel;

    if (nextLevel == null) {
      return currentLevel; // Already at max level
    }

    final newUnlockedCourses = List<String>.from(currentLevel.unlockedCourses);
    newUnlockedCourses.addAll(_getCoursesForLevel(nextLevel));

    return currentLevel.copyWith(
      currentLevel: nextLevel,
      levelAchievedAt: DateTime.now(),
      pointsToNextLevel: LevelRequirements.getPointsToNextLevel(nextLevel),
      unlockedCourses: newUnlockedCourses,
      updatedAt: DateTime.now(),
    );
  }

  /// Get initial unlocked courses for a level
  List<String> _getInitialUnlockedCourses(LearningLevel level) {
    // In a real app, this would query the database
    // For now, return based on level
    switch (level) {
      case LearningLevel.beginner:
        return ['beginner_basics', 'beginner_greetings'];
      case LearningLevel.intermediate:
        return ['intermediate_conversation', 'intermediate_grammar'];
      case LearningLevel.advanced:
        return ['advanced_literature', 'advanced_business'];
      case LearningLevel.expert:
        return ['expert_specialization', 'expert_cultural_immersion'];
    }
  }

  /// Get courses for a specific level
  List<String> _getCoursesForLevel(LearningLevel level) {
    return _getInitialUnlockedCourses(level);
  }

  /// Initialize skill scores
  Map<String, dynamic> _initializeSkillScores() {
    return {
      'vocabulary': 0,
      'grammar': 0,
      'pronunciation': 0,
      'listening': 0,
      'speaking': 0,
      'reading': 0,
      'writing': 0,
    };
  }

  /// Save user level to SQLite
  Future<void> _saveUserLevelToSQLite(UserLevelEntity level) async {
    await _database.insert('user_levels', {
      'id': level.id,
      'user_id': level.userId,
      'language_code': level.languageCode,
      'current_level': level.currentLevel.name,
      'current_points': level.currentPoints,
      'points_to_next_level': level.pointsToNextLevel,
      'completion_percentage': level.completionPercentage,
      'level_achieved_at': level.levelAchievedAt.toIso8601String(),
      'last_assessment_date': level.lastAssessmentDate?.toIso8601String(),
      'completed_lessons': level.completedLessons.join(','),
      'unlocked_courses': level.unlockedCourses.join(','),
      'skill_scores': level.skillScores.toString(),
      'created_at': level.createdAt.toIso8601String(),
      'updated_at': level.updatedAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Save user level to Firebase
  Future<void> _saveUserLevelToFirebase(UserLevelEntity level) async {
    await _firestore.collection('user_levels').doc(level.id).set({
      'userId': level.userId,
      'languageCode': level.languageCode,
      'currentLevel': level.currentLevel.name,
      'currentPoints': level.currentPoints,
      'pointsToNextLevel': level.pointsToNextLevel,
      'completionPercentage': level.completionPercentage,
      'levelAchievedAt': level.levelAchievedAt.toIso8601String(),
      'lastAssessmentDate': level.lastAssessmentDate?.toIso8601String(),
      'completedLessons': level.completedLessons,
      'unlockedCourses': level.unlockedCourses,
      'skillScores': level.skillScores,
      'createdAt': level.createdAt.toIso8601String(),
      'updatedAt': level.updatedAt.toIso8601String(),
    });
  }

  /// Map database row to UserLevelEntity
  UserLevelEntity _mapToUserLevel(Map<String, dynamic> map) {
    return UserLevelEntity(
      id: map['id'],
      userId: map['user_id'],
      languageCode: map['language_code'],
      currentLevel: LearningLevel.fromString(map['current_level']),
      currentPoints: map['current_points'],
      pointsToNextLevel: map['points_to_next_level'],
      completionPercentage: map['completion_percentage'],
      levelAchievedAt: DateTime.parse(map['level_achieved_at']),
      lastAssessmentDate: map['last_assessment_date'] != null
          ? DateTime.parse(map['last_assessment_date'])
          : null,
      completedLessons: (map['completed_lessons'] as String).split(','),
      unlockedCourses: (map['unlocked_courses'] as String).split(','),
      skillScores: const {}, // Parse from string if needed
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
