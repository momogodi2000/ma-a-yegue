import 'package:flutter/foundation.dart';
import '../../../../core/database/unified_database_service.dart';

/// Service for student/learner users
///
/// Students have:
/// - Full access to dictionary (all words)
/// - Unlimited lessons access (if subscribed)
/// - Unlimited quiz access (if subscribed)
/// - Progress tracking
/// - Statistics and achievements
class StudentService {
  static final _db = UnifiedDatabaseService.instance;

  /// Check if student has active subscription
  static Future<bool> hasActiveSubscription(String userId) async {
    try {
      final user = await _db.getUserById(userId);
      if (user == null) return false;

      final subscriptionStatus = user['subscription_status'] as String?;
      if (subscriptionStatus == null || subscriptionStatus == 'free') {
        return false;
      }

      // Check if subscription is expired
      final expiresAt = user['subscription_expires_at'] as int?;
      if (expiresAt != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresAt);
        if (expiryDate.isBefore(DateTime.now())) {
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error checking subscription: $e');
      return false;
    }
  }

  /// Get all available lessons for student
  static Future<List<Map<String, dynamic>>> getAvailableLessons({
    required String userId,
    String? languageId,
    String? level,
  }) async {
    try {
      final hasSubscription = await hasActiveSubscription(userId);

      if (hasSubscription) {
        // Full access to all lessons
        return await _db.getLessonsByLanguage(
          languageId ?? 'EWO',
          level: level,
        );
      } else {
        // Limited access - first 3 lessons per language
        return await _db.getLessonsByLanguage(
          languageId ?? 'EWO',
          level: level,
          limit: 3,
        );
      }
    } catch (e) {
      debugPrint('Error getting lessons: $e');
      return [];
    }
  }

  /// Get all available quizzes for student
  static Future<List<Map<String, dynamic>>> getAvailableQuizzes({
    required String userId,
    String? languageId,
    String? difficultyLevel,
  }) async {
    try {
      final hasSubscription = await hasActiveSubscription(userId);

      if (hasSubscription) {
        // Full access to all quizzes
        return await _db.getQuizzesByLanguageAndDifficulty(
          languageId ?? 'EWO',
          difficultyLevel: difficultyLevel,
        );
      } else {
        // Limited access - first 2 quizzes per language
        return await _db.getQuizzesByLanguageAndDifficulty(
          languageId ?? 'EWO',
          difficultyLevel: difficultyLevel,
          limit: 2,
        );
      }
    } catch (e) {
      debugPrint('Error getting quizzes: $e');
      return [];
    }
  }

  /// Save lesson progress
  static Future<void> saveLessonProgress({
    required String userId,
    required int lessonId,
    required String status,
    int? timeSpent,
    double? score,
  }) async {
    try {
      await _db.saveProgress(
        userId: userId,
        contentType: 'lesson',
        contentId: lessonId,
        status: status,
        timeSpent: timeSpent,
        score: score,
      );

      // Update statistics if lesson completed
      if (status == 'completed') {
        await _db.incrementStatistic(userId, 'total_lessons_completed');
        if (timeSpent != null) {
          await _db.incrementStatistic(
            userId,
            'total_study_time',
            incrementBy: timeSpent,
          );
        }
      }

      debugPrint('✅ Lesson progress saved for user: $userId');
    } catch (e) {
      debugPrint('Error saving lesson progress: $e');
    }
  }

  /// Save quiz results
  static Future<void> saveQuizResults({
    required String userId,
    required int quizId,
    required double score,
    required int timeSpent,
  }) async {
    try {
      await _db.saveProgress(
        userId: userId,
        contentType: 'quiz',
        contentId: quizId,
        status: 'completed',
        score: score,
        timeSpent: timeSpent,
      );

      // Update statistics
      await _db.incrementStatistic(userId, 'total_quizzes_completed');
      await _db.incrementStatistic(
        userId,
        'total_study_time',
        incrementBy: timeSpent,
      );

      // Add experience points based on score
      final xpGained = (score * 10).round();
      await _db.incrementStatistic(
        userId,
        'experience_points',
        incrementBy: xpGained,
      );

      debugPrint('✅ Quiz results saved for user: $userId (Score: $score)');
    } catch (e) {
      debugPrint('Error saving quiz results: $e');
    }
  }

  /// Get student statistics
  static Future<Map<String, dynamic>> getStatistics(String userId) async {
    try {
      final stats = await _db.getUserStatistics(userId);
      return stats ??
          {
            'total_lessons_completed': 0,
            'total_quizzes_completed': 0,
            'total_words_learned': 0,
            'total_readings_completed': 0,
            'total_study_time': 0,
            'current_streak': 0,
            'longest_streak': 0,
            'level': 1,
            'experience_points': 0,
          };
    } catch (e) {
      debugPrint('Error getting statistics: $e');
      return {};
    }
  }

  /// Get student progress for all content
  static Future<List<Map<String, dynamic>>> getProgress(String userId) async {
    try {
      return await _db.getUserAllProgress(userId);
    } catch (e) {
      debugPrint('Error getting progress: $e');
      return [];
    }
  }

  /// Get student's favorites
  static Future<List<Map<String, dynamic>>> getFavorites({
    required String userId,
    String? contentType,
  }) async {
    try {
      return await _db.getUserFavorites(userId, contentType: contentType);
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }

  /// Add to favorites
  static Future<void> addToFavorites({
    required String userId,
    required String contentType,
    required int contentId,
  }) async {
    try {
      await _db.addFavorite(
        userId: userId,
        contentType: contentType,
        contentId: contentId,
      );
      debugPrint('✅ Added to favorites: $contentType #$contentId');
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
    }
  }

  /// Remove from favorites
  static Future<void> removeFromFavorites({
    required String userId,
    required String contentType,
    required int contentId,
  }) async {
    try {
      await _db.removeFavorite(
        userId: userId,
        contentType: contentType,
        contentId: contentId,
      );
      debugPrint('✅ Removed from favorites: $contentType #$contentId');
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
    }
  }

  /// Check if content is favorited
  static Future<bool> isFavorite({
    required String userId,
    required String contentType,
    required int contentId,
  }) async {
    try {
      return await _db.isFavorite(
        userId: userId,
        contentType: contentType,
        contentId: contentId,
      );
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
      return false;
    }
  }

  /// Mark word as learned
  static Future<void> markWordAsLearned({
    required String userId,
    required int wordId,
  }) async {
    try {
      await _db.saveProgress(
        userId: userId,
        contentType: 'translation',
        contentId: wordId,
        status: 'completed',
      );

      await _db.incrementStatistic(userId, 'total_words_learned');

      debugPrint('✅ Word marked as learned: #$wordId');
    } catch (e) {
      debugPrint('Error marking word as learned: $e');
    }
  }

  /// Update daily streak
  static Future<void> updateStreak(String userId) async {
    try {
      final stats = await _db.getUserStatistics(userId);
      if (stats == null) return;

      final lastActivityDate = stats['last_activity_date'] as String?;
      final currentStreak = stats['current_streak'] as int? ?? 0;
      final longestStreak = stats['longest_streak'] as int? ?? 0;

      final today = DateTime.now().toIso8601String().split('T')[0];

      if (lastActivityDate == null || lastActivityDate != today) {
        // Check if yesterday
        final yesterday = DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String()
            .split('T')[0];

        int newStreak;
        if (lastActivityDate == yesterday) {
          // Continue streak
          newStreak = currentStreak + 1;
        } else {
          // Reset streak
          newStreak = 1;
        }

        final newLongest = newStreak > longestStreak
            ? newStreak
            : longestStreak;

        await _db.upsertUserStatistics(userId, {
          'current_streak': newStreak,
          'longest_streak': newLongest,
          'last_activity_date': today,
        });

        debugPrint('✅ Streak updated: $newStreak days');
      }
    } catch (e) {
      debugPrint('Error updating streak: $e');
    }
  }

  /// Get subscription benefits message
  static Future<String> getSubscriptionMessage(String userId) async {
    try {
      final hasSubscription = await hasActiveSubscription(userId);

      if (hasSubscription) {
        final user = await _db.getUserById(userId);
        final expiresAt = user?['subscription_expires_at'] as int?;

        if (expiresAt != null) {
          final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresAt);
          final daysLeft = expiryDate.difference(DateTime.now()).inDays;
          return 'Abonnement actif - Expire dans $daysLeft jours';
        }

        return 'Abonnement actif';
      } else {
        return 'Abonnez-vous pour un accès illimité à tous les contenus!';
      }
    } catch (e) {
      debugPrint('Error getting subscription message: $e');
      return 'Statut d\'abonnement inconnu';
    }
  }
}
