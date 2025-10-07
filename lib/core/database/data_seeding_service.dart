import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'unified_database_service.dart';

/// Service for seeding the main app database with initial Cameroon languages data
class DataSeedingService {
  static final _dbService = UnifiedDatabaseService.instance;
  static const String _seededKey = 'cameroon_languages_seeded';

  /// Check if the database has already been seeded
  static Future<bool> isSeeded() async {
    final seededValue = await _dbService.getMetadata(_seededKey);
    return seededValue == 'true';
  }

  /// Mark the database as seeded
  static Future<void> markAsSeeded() async {
    await _dbService.setMetadata(_seededKey, 'true');
  }

  /// Seed the main database with Cameroon languages data
  static Future<void> seedDatabase() async {
    // Check if already seeded
    if (await isSeeded()) {
      debugPrint('Database already seeded with Cameroon languages data');
      return;
    }

    debugPrint('Seeding database with Cameroon languages data...');

    try {
      // Get data from Cameroon languages database
      final translations = await _dbService.getTranslationsByLanguage('EWO');
      final lessons = await _dbService.getLessonsByLanguage('EWO');

      // Dictionary entries and lessons are already in the Cameroon database
      // No need to duplicate them in the main database
      // They are accessible via the attached database

      // Mark as seeded
      await markAsSeeded();

      debugPrint(
        'Successfully verified database with ${translations.length} translations and ${lessons.length} lessons',
      );
    } catch (e) {
      debugPrint('Error seeding database: $e');
      rethrow;
    }
  }

  /// Get seeding statistics
  static Future<Map<String, int>> getSeedingStats() async {
    final db = await _dbService.database;

    final dictionaryCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM cameroon.translations'),
        ) ??
        0;

    final lessonCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM cameroon.lessons'),
        ) ??
        0;

    return {
      'dictionaryEntries': dictionaryCount,
      'lessons': lessonCount,
      'lessonContents': 0,
    };
  }

  /// Clear seeded data (for testing or reset)
  static Future<void> clearSeededData() async {
    // Cameroon database is read-only from assets
    // Only clear the seeded marker
    await _dbService.setMetadata(_seededKey, 'false');
  }
}
