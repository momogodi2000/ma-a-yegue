import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../../core/database/unified_database_service.dart';

/// Service for tracking and enforcing guest user daily limits
///
/// Guest users have daily limits:
/// - 5 lessons per day
/// - 5 readings per day
/// - 5 quizzes per day
class GuestLimitService {
  static final _db = UnifiedDatabaseService.instance;
  static const int maxDailyLessons = 5;
  static const int maxDailyReadings = 5;
  static const int maxDailyQuizzes = 5;

  /// Get device ID for tracking guest usage
  static Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      }
      return 'unknown';
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      return 'unknown';
    }
  }

  /// Get today's usage limits for a guest user
  static Future<Map<String, int>> getTodayUsage() async {
    try {
      final deviceId = await _getDeviceId();
      final limits = await _db.getTodayLimits(deviceId: deviceId);

      if (limits == null) {
        return {'lessons': 0, 'readings': 0, 'quizzes': 0};
      }

      return {
        'lessons': limits['lessons_count'] as int? ?? 0,
        'readings': limits['readings_count'] as int? ?? 0,
        'quizzes': limits['quizzes_count'] as int? ?? 0,
      };
    } catch (e) {
      debugPrint('Error getting today usage: $e');
      return {'lessons': 0, 'readings': 0, 'quizzes': 0};
    }
  }

  /// Get remaining limits for today
  static Future<Map<String, int>> getRemainingLimits() async {
    try {
      final usage = await getTodayUsage();

      return {
        'lessons': maxDailyLessons - (usage['lessons'] ?? 0),
        'readings': maxDailyReadings - (usage['readings'] ?? 0),
        'quizzes': maxDailyQuizzes - (usage['quizzes'] ?? 0),
      };
    } catch (e) {
      debugPrint('Error getting remaining limits: $e');
      return {
        'lessons': maxDailyLessons,
        'readings': maxDailyReadings,
        'quizzes': maxDailyQuizzes,
      };
    }
  }

  /// Check if guest can access a lesson
  static Future<bool> canAccessLesson() async {
    try {
      final deviceId = await _getDeviceId();
      final hasReached = await _db.hasReachedDailyLimit(
        limitType: 'lessons',
        maxLimit: maxDailyLessons,
        deviceId: deviceId,
      );
      return !hasReached;
    } catch (e) {
      debugPrint('Error checking lesson access: $e');
      return false;
    }
  }

  /// Check if guest can access a reading
  static Future<bool> canAccessReading() async {
    try {
      final deviceId = await _getDeviceId();
      final hasReached = await _db.hasReachedDailyLimit(
        limitType: 'readings',
        maxLimit: maxDailyReadings,
        deviceId: deviceId,
      );
      return !hasReached;
    } catch (e) {
      debugPrint('Error checking reading access: $e');
      return false;
    }
  }

  /// Check if guest can access a quiz
  static Future<bool> canAccessQuiz() async {
    try {
      final deviceId = await _getDeviceId();
      final hasReached = await _db.hasReachedDailyLimit(
        limitType: 'quizzes',
        maxLimit: maxDailyQuizzes,
        deviceId: deviceId,
      );
      return !hasReached;
    } catch (e) {
      debugPrint('Error checking quiz access: $e');
      return false;
    }
  }

  /// Increment lesson count
  static Future<void> incrementLessonCount() async {
    try {
      final deviceId = await _getDeviceId();
      await _db.incrementDailyLimit(limitType: 'lessons', deviceId: deviceId);
      debugPrint('✅ Lesson count incremented for device: $deviceId');
    } catch (e) {
      debugPrint('Error incrementing lesson count: $e');
    }
  }

  /// Increment reading count
  static Future<void> incrementReadingCount() async {
    try {
      final deviceId = await _getDeviceId();
      await _db.incrementDailyLimit(limitType: 'readings', deviceId: deviceId);
      debugPrint('✅ Reading count incremented for device: $deviceId');
    } catch (e) {
      debugPrint('Error incrementing reading count: $e');
    }
  }

  /// Increment quiz count
  static Future<void> incrementQuizCount() async {
    try {
      final deviceId = await _getDeviceId();
      await _db.incrementDailyLimit(limitType: 'quizzes', deviceId: deviceId);
      debugPrint('✅ Quiz count incremented for device: $deviceId');
    } catch (e) {
      debugPrint('Error incrementing quiz count: $e');
    }
  }

  /// Get formatted limit message
  static Future<String> getLimitMessage(String contentType) async {
    try {
      final remaining = await getRemainingLimits();
      final String type;
      final int remainingCount;

      switch (contentType.toLowerCase()) {
        case 'lesson':
          type = 'leçons';
          remainingCount = remaining['lessons'] ?? 0;
          break;
        case 'reading':
          type = 'lectures';
          remainingCount = remaining['readings'] ?? 0;
          break;
        case 'quiz':
          type = 'quiz';
          remainingCount = remaining['quizzes'] ?? 0;
          break;
        default:
          return 'Limite inconnue';
      }

      if (remainingCount == 0) {
        return 'Limite journalière atteinte pour les $type. Créez un compte pour un accès illimité!';
      } else if (remainingCount == 1) {
        return 'Il vous reste $remainingCount $type aujourd\'hui';
      } else {
        return 'Il vous reste $remainingCount $type aujourd\'hui';
      }
    } catch (e) {
      debugPrint('Error getting limit message: $e');
      return 'Erreur lors de la vérification des limites';
    }
  }

  /// Check if limit reached and get appropriate message
  static Future<Map<String, dynamic>> checkAccessWithMessage(
    String contentType,
  ) async {
    try {
      bool canAccess;

      switch (contentType.toLowerCase()) {
        case 'lesson':
          canAccess = await canAccessLesson();
          break;
        case 'reading':
          canAccess = await canAccessReading();
          break;
        case 'quiz':
          canAccess = await canAccessQuiz();
          break;
        default:
          canAccess = false;
      }

      final message = await getLimitMessage(contentType);

      return {'canAccess': canAccess, 'message': message};
    } catch (e) {
      debugPrint('Error checking access with message: $e');
      return {
        'canAccess': false,
        'message': 'Erreur lors de la vérification de l\'accès',
      };
    }
  }

  /// Reset all limits (for testing purposes)
  static Future<void> resetLimitsForTesting() async {
    try {
      // This would require a method in UnifiedDatabaseService to delete today's limits
      debugPrint('⚠️ Resetting limits for testing...');
      // Implementation would go here
    } catch (e) {
      debugPrint('Error resetting limits: $e');
    }
  }
}
