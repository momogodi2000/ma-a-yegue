import 'package:flutter/foundation.dart';
import '../../../core/database/unified_database_service.dart';

/// Service to bootstrap the application with initial data
///
/// NOTE: Lessons are now loaded from the Python-generated SQLite database
/// (docs/database-scripts/create_cameroon_db.py) instead of being
/// dynamically generated with AI.
class AppBootstrapService {
  final UnifiedDatabaseService _database = UnifiedDatabaseService.instance;

  AppBootstrapService();

  /// Initialize the application with initial data
  Future<void> initializeApp() async {
    try {
      // Check database status
      final db = await _database.database;

      // Check if lessons exist in attached database
      final lessonCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM cameroon_languages.lessons',
      );

      final count = lessonCount.first['count'] as int? ?? 0;

      if (count > 0) {
        debugPrint('✅ Database loaded with $count lessons');
      } else {
        debugPrint(
          '⚠️ No lessons found in database. Run Python script: docs/database-scripts/create_cameroon_db.py',
        );
      }

      // Get language statistics
      final languages = await db.rawQuery('''
        SELECT language_code, language_name, COUNT(*) as lesson_count
        FROM cameroon_languages.lessons
        GROUP BY language_code, language_name
      ''');

      debugPrint('📊 Available languages:');
      for (final lang in languages) {
        debugPrint(
          '   ${lang['language_name']}: ${lang['lesson_count']} lessons',
        );
      }
    } catch (e) {
      debugPrint('❌ Error during app initialization: $e');
      // Don't rethrow - app should still work
    }
  }

  /// Initialize default lessons for a specific language (deprecated - use Python script)
  Future<bool> initializeLessonsForLanguage(String languageCode) async {
    debugPrint(
      '⚠️ initializeLessonsForLanguage is deprecated. Use Python script instead.',
    );
    return false;
  }

  /// Get available languages with their lesson counts
  Future<List<Map<String, dynamic>>> getAvailableLanguages() async {
    try {
      final db = await _database.database;
      final results = await db.rawQuery('''
        SELECT language_code, language_name, COUNT(*) as lesson_count
        FROM cameroon_languages.lessons
        GROUP BY language_code, language_name
      ''');

      return results
          .map(
            (row) => {
              'code': row['language_code'],
              'name': row['language_name'],
              'lessonCount': row['lesson_count'],
            },
          )
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting available languages: $e');
      return [];
    }
  }

  /// Get lesson counts by language
  Future<Map<String, int>> getLanguageLessonCounts() async {
    try {
      final db = await _database.database;
      final results = await db.rawQuery('''
        SELECT language_code, COUNT(*) as count
        FROM cameroon_languages.lessons
        GROUP BY language_code
      ''');

      final counts = <String, int>{};
      for (final row in results) {
        counts[row['language_code'] as String] = row['count'] as int? ?? 0;
      }
      return counts;
    } catch (e) {
      debugPrint('Error getting lesson counts: $e');
      return {};
    }
  }
}
