import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../database/unified_database_service.dart';

/// Guest Limit Service - Daily Content Access Limits
///
/// ✅ Enforces daily limits for guest (unauthenticated) users:
/// - 5 lessons per day
/// - 5 readings per day
/// - 5 quizzes per day
///
/// Uses device ID to track limits across app restarts
/// Resets automatically at midnight (local timezone)
class GuestLimitService {
  final UnifiedDatabaseService _database = UnifiedDatabaseService.instance;

  static const int maxLessonsPerDay = 5;
  static const int maxReadingsPerDay = 5;
  static const int maxQuizzesPerDay = 5;

  static String? _cachedDeviceId;

  /// Get unique device ID for guest tracking
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _cachedDeviceId = 'android_${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _cachedDeviceId = 'ios_${iosInfo.identifierForVendor}';
      } else {
        // Fallback for other platforms
        _cachedDeviceId = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
      }

      return _cachedDeviceId!;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting device ID: $e');
      }
      // Fallback to timestamp-based ID
      _cachedDeviceId = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
      return _cachedDeviceId!;
    }
  }

  /// Get today's date string (YYYY-MM-DD)
  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get or create daily limits record for today
  Future<Map<String, dynamic>> _getTodayLimits() async {
    final deviceId = await getDeviceId();
    final today = _getTodayDateString();
    final db = await _database.database;

    final results = await db.query(
      'daily_limits',
      where: 'device_id = ? AND limit_date = ?',
      whereArgs: [deviceId, today],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return results.first;
    }

    // Create new record for today
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('daily_limits', {
      'device_id': deviceId,
      'limit_date': today,
      'lessons_count': 0,
      'readings_count': 0,
      'quizzes_count': 0,
      'created_at': now,
    });

    return {
      'device_id': deviceId,
      'limit_date': today,
      'lessons_count': 0,
      'readings_count': 0,
      'quizzes_count': 0,
      'created_at': now,
    };
  }

  /// Check if guest can access a lesson
  Future<bool> canAccessLesson() async {
    try {
      final limits = await _getTodayLimits();
      final lessonsCount = limits['lessons_count'] as int;
      return lessonsCount < maxLessonsPerDay;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking lesson limit: $e');
      }
      return false;
    }
  }

  /// Check if guest can access a reading
  Future<bool> canAccessReading() async {
    try {
      final limits = await _getTodayLimits();
      final readingsCount = limits['readings_count'] as int;
      return readingsCount < maxReadingsPerDay;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking reading limit: $e');
      }
      return false;
    }
  }

  /// Check if guest can access a quiz
  Future<bool> canAccessQuiz() async {
    try {
      final limits = await _getTodayLimits();
      final quizzesCount = limits['quizzes_count'] as int;
      return quizzesCount < maxQuizzesPerDay;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking quiz limit: $e');
      }
      return false;
    }
  }

  /// Increment lesson count (call when guest accesses a lesson)
  Future<void> incrementLessonCount() async {
    try {
      final deviceId = await getDeviceId();
      final today = _getTodayDateString();
      final db = await _database.database;

      await _getTodayLimits(); // Ensure record exists

      await db.rawUpdate(
        'UPDATE daily_limits SET lessons_count = lessons_count + 1 WHERE device_id = ? AND limit_date = ?',
        [deviceId, today],
      );

      if (kDebugMode) {
        final updated = await _getTodayLimits();
        debugPrint(
          '📊 Lesson count incremented: ${updated['lessons_count']}/$maxLessonsPerDay',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error incrementing lesson count: $e');
      }
    }
  }

  /// Increment reading count
  Future<void> incrementReadingCount() async {
    try {
      final deviceId = await getDeviceId();
      final today = _getTodayDateString();
      final db = await _database.database;

      await _getTodayLimits(); // Ensure record exists

      await db.rawUpdate(
        'UPDATE daily_limits SET readings_count = readings_count + 1 WHERE device_id = ? AND limit_date = ?',
        [deviceId, today],
      );

      if (kDebugMode) {
        final updated = await _getTodayLimits();
        debugPrint(
          '📊 Reading count incremented: ${updated['readings_count']}/$maxReadingsPerDay',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error incrementing reading count: $e');
      }
    }
  }

  /// Increment quiz count
  Future<void> incrementQuizCount() async {
    try {
      final deviceId = await getDeviceId();
      final today = _getTodayDateString();
      final db = await _database.database;

      await _getTodayLimits(); // Ensure record exists

      await db.rawUpdate(
        'UPDATE daily_limits SET quizzes_count = quizzes_count + 1 WHERE device_id = ? AND limit_date = ?',
        [deviceId, today],
      );

      if (kDebugMode) {
        final updated = await _getTodayLimits();
        debugPrint(
          '📊 Quiz count incremented: ${updated['quizzes_count']}/$maxQuizzesPerDay',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error incrementing quiz count: $e');
      }
    }
  }

  /// Get remaining counts for today
  Future<Map<String, int>> getRemainingCounts() async {
    try {
      final limits = await _getTodayLimits();

      return {
        'lessons': maxLessonsPerDay - (limits['lessons_count'] as int),
        'readings': maxReadingsPerDay - (limits['readings_count'] as int),
        'quizzes': maxQuizzesPerDay - (limits['quizzes_count'] as int),
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting remaining counts: $e');
      }
      return {'lessons': 0, 'readings': 0, 'quizzes': 0};
    }
  }

  /// Get current counts for today
  Future<Map<String, int>> getCurrentCounts() async {
    try {
      final limits = await _getTodayLimits();

      return {
        'lessons': limits['lessons_count'] as int,
        'readings': limits['readings_count'] as int,
        'quizzes': limits['quizzes_count'] as int,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting current counts: $e');
      }
      return {'lessons': 0, 'readings': 0, 'quizzes': 0};
    }
  }

  /// Check if any limit has been reached
  Future<bool> hasReachedAnyLimit() async {
    try {
      final limits = await _getTodayLimits();

      return (limits['lessons_count'] as int) >= maxLessonsPerDay ||
          (limits['readings_count'] as int) >= maxReadingsPerDay ||
          (limits['quizzes_count'] as int) >= maxQuizzesPerDay;
    } catch (e) {
      return false;
    }
  }

  /// Clean up old limit records (older than 7 days)
  /// Call this periodically to keep database clean
  Future<void> cleanupOldLimits() async {
    try {
      final db = await _database.database;
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final cutoffDate =
          '${sevenDaysAgo.year}-${sevenDaysAgo.month.toString().padLeft(2, '0')}-${sevenDaysAgo.day.toString().padLeft(2, '0')}';

      final deleted = await db.delete(
        'daily_limits',
        where: 'limit_date < ?',
        whereArgs: [cutoffDate],
      );

      if (kDebugMode && deleted > 0) {
        print('🧹 Cleaned up $deleted old limit records');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cleaning up old limits: $e');
      }
    }
  }

  /// Get guest access summary
  Future<Map<String, dynamic>> getAccessSummary() async {
    final current = await getCurrentCounts();
    final remaining = await getRemainingCounts();

    return {
      'current': current,
      'remaining': remaining,
      'limits': {
        'lessons': maxLessonsPerDay,
        'readings': maxReadingsPerDay,
        'quizzes': maxQuizzesPerDay,
      },
      'date': _getTodayDateString(),
      'device_id': await getDeviceId(),
      'has_reached_any_limit': await hasReachedAnyLimit(),
    };
  }
}
