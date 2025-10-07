import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'unified_database_service.dart';

/// Database Query Optimizer
///
/// Provides optimized query methods and caching strategies for better performance
class DatabaseQueryOptimizer {
  static final _db = UnifiedDatabaseService.instance;
  
  // Cache for frequently accessed data
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheValidity = Duration(minutes: 5);

  // ==================== CACHED QUERIES ====================

  /// Get all languages with caching
  static Future<List<Map<String, dynamic>>> getCachedLanguages() async {
    const cacheKey = 'all_languages';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as List<Map<String, dynamic>>;
    }

    final languages = await _db.getAllLanguages();
    _setCache(cacheKey, languages);
    return languages;
  }

  /// Get all categories with caching
  static Future<List<Map<String, dynamic>>> getCachedCategories() async {
    const cacheKey = 'all_categories';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as List<Map<String, dynamic>>;
    }

    final categories = await _db.getAllCategories();
    _setCache(cacheKey, categories);
    return categories;
  }

  /// Get user statistics with caching
  static Future<Map<String, dynamic>?> getCachedUserStatistics(
    String userId,
  ) async {
    final cacheKey = 'user_stats_$userId';
    
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey] as Map<String, dynamic>?;
    }

    final stats = await _db.getUserStatistics(userId);
    _setCache(cacheKey, stats);
    return stats;
  }

  /// Invalidate user statistics cache (call after updates)
  static void invalidateUserStatsCache(String userId) {
    _cache.remove('user_stats_$userId');
    _cacheTimestamps.remove('user_stats_$userId');
  }

  /// Invalidate all caches
  static void invalidateAllCaches() {
    _cache.clear();
    _cacheTimestamps.clear();
    debugPrint('🔄 All caches invalidated');
  }

  // ==================== BATCH OPERATIONS ====================

  /// Batch insert translations (for teachers/admin)
  static Future<List<int>> batchInsertTranslations(
    List<Map<String, dynamic>> translations,
  ) async {
    final db = await _db.database;
    final batch = db.batch();
    final ids = <int>[];

    for (var translation in translations) {
      batch.rawInsert(
        '''
        INSERT INTO user_created_content 
        (creator_id, content_type, title, content_data, language_id, status, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          translation['creator_id'],
          'translation',
          translation['french_text'],
          translation['translation'],
          translation['language_id'],
          'published',
          DateTime.now().millisecondsSinceEpoch,
          DateTime.now().millisecondsSinceEpoch,
        ],
      );
    }

    final results = await batch.commit();
    debugPrint('✅ Batch inserted ${translations.length} translations');
    return results.cast<int>();
  }

  /// Batch update progress for multiple items
  static Future<void> batchUpdateProgress(
    String userId,
    List<Map<String, dynamic>> progressItems,
  ) async {
    final db = await _db.database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (var item in progressItems) {
      batch.insert(
        'user_progress',
        {
          'user_id': userId,
          'content_type': item['content_type'],
          'content_id': item['content_id'],
          'status': item['status'],
          'score': item['score'],
          'time_spent': item['time_spent'],
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
    debugPrint('✅ Batch updated progress for ${progressItems.length} items');
  }

  // ==================== OPTIMIZED QUERIES ====================

  /// Get user dashboard data with single query
  static Future<Map<String, dynamic>> getUserDashboardData(String userId) async {
    final db = await _db.database;

    // Single complex query to get everything at once
    final result = await db.rawQuery(
      '''
      SELECT 
        u.user_id,
        u.display_name,
        u.email,
        u.role,
        u.subscription_status,
        s.total_lessons_completed,
        s.total_quizzes_completed,
        s.total_words_learned,
        s.current_streak,
        s.experience_points,
        s.level,
        COUNT(DISTINCT p.progress_id) as total_activities,
        COUNT(DISTINCT f.favorite_id) as total_favorites
      FROM users u
      LEFT JOIN user_statistics s ON u.user_id = s.user_id
      LEFT JOIN user_progress p ON u.user_id = p.user_id
      LEFT JOIN favorites f ON u.user_id = f.user_id
      WHERE u.user_id = ?
      GROUP BY u.user_id
    ''',
      [userId],
    );

    return result.isNotEmpty ? result.first : {};
  }

  /// Get lesson with progress in single query
  static Future<Map<String, dynamic>?> getLessonWithProgress({
    required String userId,
    required int lessonId,
  }) async {
    final db = await _db.database;

    final result = await db.rawQuery(
      '''
      SELECT 
        l.lesson_id,
        l.title,
        l.content,
        l.language_id,
        l.level,
        l.order_index,
        l.audio_url,
        l.video_url,
        p.status,
        p.score,
        p.time_spent,
        p.attempts,
        f.favorite_id IS NOT NULL as is_favorite
      FROM cameroon.lessons l
      LEFT JOIN user_progress p ON 
        p.user_id = ? AND 
        p.content_type = 'lesson' AND 
        p.content_id = l.lesson_id
      LEFT JOIN favorites f ON 
        f.user_id = ? AND 
        f.content_type = 'lesson' AND 
        f.content_id = l.lesson_id
      WHERE l.lesson_id = ?
    ''',
      [userId, userId, lessonId],
    );

    return result.isNotEmpty ? result.first : null;
  }

  /// Get user's recently accessed content
  static Future<List<Map<String, dynamic>>> getRecentlyAccessedContent({
    required String userId,
    int limit = 10,
  }) async {
    final db = await _db.database;

    return await db.query(
      'user_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
      limit: limit,
    );
  }

  /// Search translations with optimized query
  static Future<List<Map<String, dynamic>>> searchTranslationsOptimized({
    required String searchTerm,
    String? languageId,
    String? categoryId,
    String? difficultyLevel,
    int limit = 50,
  }) async {
    final db = await _db.database;
    
    final conditions = <String>[];
    final args = <dynamic>[];

    // Full-text search on multiple fields
    conditions.add('(french_text LIKE ? OR translation LIKE ?)');
    args.add('%$searchTerm%');
    args.add('%$searchTerm%');

    if (languageId != null) {
      conditions.add('language_id = ?');
      args.add(languageId);
    }

    if (categoryId != null) {
      conditions.add('category_id = ?');
      args.add(categoryId);
    }

    if (difficultyLevel != null) {
      conditions.add('difficulty_level = ?');
      args.add(difficultyLevel);
    }

    final whereClause = conditions.join(' AND ');

    return await db.rawQuery(
      '''
      SELECT * FROM cameroon.translations
      WHERE $whereClause
      ORDER BY 
        CASE 
          WHEN french_text LIKE ? THEN 1
          WHEN translation LIKE ? THEN 2
          ELSE 3
        END,
        french_text ASC
      LIMIT ?
    ''',
      [...args, '$searchTerm%', '$searchTerm%', limit],
    );
  }

  // ==================== PAGINATION ====================

  /// Get paginated lessons
  static Future<List<Map<String, dynamic>>> getPaginatedLessons({
    required String languageId,
    String? level,
    int page = 1,
    int pageSize = 20,
  }) async {
    final db = await _db.database;
    final offset = (page - 1) * pageSize;

    String whereClause = 'language_id = ?';
    List<dynamic> args = [languageId];

    if (level != null) {
      whereClause += ' AND level = ?';
      args.add(level);
    }

    return await db.rawQuery(
      '''
      SELECT * FROM cameroon.lessons
      WHERE $whereClause
      ORDER BY order_index ASC
      LIMIT ? OFFSET ?
    ''',
      [...args, pageSize, offset],
    );
  }

  /// Get total count for pagination
  static Future<int> getTotalLessonsCount({
    required String languageId,
    String? level,
  }) async {
    final db = await _db.database;

    String whereClause = 'language_id = ?';
    List<dynamic> args = [languageId];

    if (level != null) {
      whereClause += ' AND level = ?';
      args.add(level);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM cameroon.lessons WHERE $whereClause',
      args,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== ANALYTICS ====================

  /// Get leaderboard data efficiently
  static Future<List<Map<String, dynamic>>> getLeaderboard({
    String metric = 'experience_points',
    int limit = 50,
  }) async {
    final db = await _db.database;

    return await db.rawQuery(
      '''
      SELECT 
        u.user_id,
        u.display_name,
        u.email,
        s.$metric as score,
        s.level,
        s.current_streak,
        s.total_lessons_completed,
        s.total_quizzes_completed
      FROM users u
      INNER JOIN user_statistics s ON u.user_id = s.user_id
      WHERE u.role IN ('student', 'teacher')
      ORDER BY s.$metric DESC
      LIMIT ?
    ''',
      [limit],
    );
  }

  /// Get activity heatmap data
  static Future<List<Map<String, dynamic>>> getActivityHeatmap({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _db.database;

    final startMillis = startDate.millisecondsSinceEpoch;
    final endMillis = endDate.millisecondsSinceEpoch;

    return await db.rawQuery(
      '''
      SELECT 
        DATE(created_at / 1000, 'unixepoch') as date,
        COUNT(*) as activity_count,
        SUM(time_spent) as total_time
      FROM user_progress
      WHERE user_id = ? 
        AND created_at BETWEEN ? AND ?
      GROUP BY DATE(created_at / 1000, 'unixepoch')
      ORDER BY date DESC
    ''',
      [userId, startMillis, endMillis],
    );
  }

  // ==================== CACHE MANAGEMENT ====================

  static bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) return false;
    
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;

    final age = DateTime.now().difference(timestamp);
    return age < _cacheValidity;
  }

  static void _setCache(String key, dynamic value) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cached_items': _cache.length,
      'cache_keys': _cache.keys.toList(),
      'oldest_cache': _cacheTimestamps.values.isEmpty
          ? null
          : _cacheTimestamps.values
              .reduce((a, b) => a.isBefore(b) ? a : b)
              .toIso8601String(),
    };
  }

  /// Warm up cache with frequently accessed data
  static Future<void> warmUpCache() async {
    debugPrint('🔥 Warming up cache...');
    
    try {
      await Future.wait([
        getCachedLanguages(),
        getCachedCategories(),
      ]);
      
      debugPrint('✅ Cache warmed up: ${_cache.length} items');
    } catch (e) {
      debugPrint('⚠️ Cache warmup failed: $e');
    }
  }

  // ==================== QUERY PROFILING ====================

  /// Profile a query execution time
  static Future<T> profileQuery<T>(
    String queryName,
    Future<T> Function() query,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await query();
      stopwatch.stop();
      
      if (kDebugMode) {
        debugPrint('⏱️ Query "$queryName" took ${stopwatch.elapsedMilliseconds}ms');
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ Query "$queryName" failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      rethrow;
    }
  }

  // ==================== INDEX RECOMMENDATIONS ====================

  /// Analyze and suggest indexes based on query patterns
  static Future<List<String>> analyzeIndexes() async {
    final db = await _db.database;
    final suggestions = <String>[];

    try {
      // Check if all recommended indexes exist
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND sql IS NOT NULL",
      );

      final existingIndexes = indexes.map((i) => i['name'] as String).toSet();

      final recommendedIndexes = {
        'idx_users_firebase_uid',
        'idx_users_role',
        'idx_users_email',
        'idx_daily_limits_date',
        'idx_user_progress_user',
        'idx_user_progress_content',
        'idx_user_statistics_user',
        'idx_favorites_user',
        'idx_payments_user',
        'idx_subscriptions_user',
      };

      for (var recommended in recommendedIndexes) {
        if (!existingIndexes.contains(recommended)) {
          suggestions.add('Missing index: $recommended');
        }
      }

      if (suggestions.isEmpty) {
        debugPrint('✅ All recommended indexes present');
      } else {
        debugPrint('⚠️ Missing indexes: ${suggestions.length}');
      }
    } catch (e) {
      debugPrint('Error analyzing indexes: $e');
    }

    return suggestions;
  }

  // ==================== VACUUM AND OPTIMIZE ====================

  /// Vacuum database to reclaim space and optimize
  static Future<void> vacuumDatabase() async {
    try {
      final db = await _db.database;
      await db.execute('VACUUM');
      debugPrint('✅ Database vacuumed');
    } catch (e) {
      debugPrint('Error vacuuming database: $e');
    }
  }

  /// Analyze database for optimization opportunities
  static Future<void> analyzeDatabase() async {
    try {
      final db = await _db.database;
      await db.execute('ANALYZE');
      debugPrint('✅ Database analyzed');
    } catch (e) {
      debugPrint('Error analyzing database: $e');
    }
  }

  /// Get database size
  static Future<int> getDatabaseSize() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery('SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('Error getting database size: $e');
      return 0;
    }
  }

  /// Get database statistics
  static Future<Map<String, dynamic>> getDatabaseStatistics() async {
    final db = await _db.database;

    try {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
      );

      final tableStats = <Map<String, dynamic>>[];

      for (var table in tables) {
        final tableName = table['name'] as String;
        
        final count = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
        final rowCount = Sqflite.firstIntValue(count) ?? 0;

        tableStats.add({
          'table': tableName,
          'rows': rowCount,
        });
      }

      return {
        'tables': tables.length,
        'table_stats': tableStats,
        'size_bytes': await getDatabaseSize(),
      };
    } catch (e) {
      debugPrint('Error getting database statistics: $e');
      return {};
    }
  }
}
