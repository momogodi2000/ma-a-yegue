import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite database helper for accessing the local Cameroon languages database
class SQLiteDatabaseHelper {
  static const String _databaseName = 'cameroon_languages.db';
  static Database? _database;

  /// Get singleton database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database by copying from assets
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    // Check if database exists
    bool exists = await databaseExists(path);

    if (!exists) {
      // Copy from assets
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from assets
      ByteData data = await rootBundle.load('assets/databases/$_databaseName');
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes);
    }

    return await openDatabase(path, readOnly: true);
  }

  /// Get all languages from the database
  static Future<List<Map<String, dynamic>>> getLanguages() async {
    final db = await database;
    return await db.query('languages');
  }

  /// Get all categories from the database
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  /// Get translations by language
  static Future<List<Map<String, dynamic>>> getTranslationsByLanguage(
    String languageId, {
    int? limit,
    String? category,
    String? difficultyLevel,
  }) async {
    final db = await database;
    String whereClause = 'language_id = ?';
    List<dynamic> whereArgs = [languageId];

    if (category != null) {
      whereClause += ' AND category_id = ?';
      whereArgs.add(category);
    }

    if (difficultyLevel != null) {
      whereClause += ' AND difficulty_level = ?';
      whereArgs.add(difficultyLevel);
    }

    return await db.query(
      'translations',
      where: whereClause,
      whereArgs: whereArgs,
      limit: limit,
      orderBy: 'french_text ASC',
    );
  }

  /// Get translations by category
  static Future<List<Map<String, dynamic>>> getTranslationsByCategory(
    String categoryId, {
    int? limit,
    String? languageId,
  }) async {
    final db = await database;
    String whereClause = 'category_id = ?';
    List<dynamic> whereArgs = [categoryId];

    if (languageId != null) {
      whereClause += ' AND language_id = ?';
      whereArgs.add(languageId);
    }

    return await db.query(
      'translations',
      where: whereClause,
      whereArgs: whereArgs,
      limit: limit,
      orderBy: 'french_text ASC',
    );
  }

  /// Search translations by French text
  static Future<List<Map<String, dynamic>>> searchTranslations(
    String query, {
    String? languageId,
    int? limit,
  }) async {
    final db = await database;
    String whereClause = 'french_text LIKE ?';
    List<dynamic> whereArgs = ['%$query%'];

    if (languageId != null) {
      whereClause += ' AND language_id = ?';
      whereArgs.add(languageId);
    }

    return await db.query(
      'translations',
      where: whereClause,
      whereArgs: whereArgs,
      limit: limit ?? 50,
      orderBy: 'french_text ASC',
    );
  }

  /// Get lessons by language
  static Future<List<Map<String, dynamic>>> getLessonsByLanguage(
    String languageId, {
    int? limit,
    String? level,
  }) async {
    final db = await database;
    String whereClause = 'language_id = ?';
    List<dynamic> whereArgs = [languageId];

    if (level != null) {
      whereClause += ' AND level = ?';
      whereArgs.add(level);
    }

    return await db.query(
      'lessons',
      where: whereClause,
      whereArgs: whereArgs,
      limit: limit,
      orderBy: 'order_index ASC',
    );
  }

  /// Get a specific lesson by ID
  static Future<Map<String, dynamic>?> getLessonById(int lessonId) async {
    final db = await database;
    final results = await db.query(
      'lessons',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get basic words for guest users (limited to beginners)
  static Future<List<Map<String, dynamic>>> getBasicWords({
    String? languageId,
    int limit = 25,
  }) async {
    final db = await database;
    String whereClause = 'difficulty_level = ?';
    List<dynamic> whereArgs = ['beginner'];

    if (languageId != null) {
      whereClause += ' AND language_id = ?';
      whereArgs.add(languageId);
    }

    return await db.query(
      'translations',
      where: whereClause,
      whereArgs: whereArgs,
      limit: limit,
      orderBy: 'RANDOM()',
    );
  }

  /// Get demo lessons for guest users
  static Future<List<Map<String, dynamic>>> getDemoLessons({
    String? languageId,
    int limit = 3,
  }) async {
    final db = await database;
    String whereClause = 'level = ?';
    List<dynamic> whereArgs = ['beginner'];

    if (languageId != null) {
      whereClause += ' AND language_id = ?';
      whereArgs.add(languageId);
    }

    return await db.query(
      'lessons',
      where: whereClause,
      whereArgs: whereArgs,
      limit: limit,
      orderBy: 'order_index ASC',
    );
  }

  /// Get statistics about the database content
  static Future<Map<String, int>> getContentStats() async {
    final db = await database;
    
    final languageCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM languages'),
    ) ?? 0;
    
    final translationCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM translations'),
    ) ?? 0;
    
    final lessonCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM lessons'),
    ) ?? 0;
    
    final categoryCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categories'),
    ) ?? 0;

    return {
      'languages': languageCount,
      'translations': translationCount,
      'lessons': lessonCount,
      'categories': categoryCount,
    };
  }

  /// Get popular categories with translation counts
  static Future<List<Map<String, dynamic>>> getPopularCategories({
    String? languageId,
    int limit = 10,
  }) async {
    final db = await database;
    String query = '''
      SELECT c.category_id, c.category_name, c.description, COUNT(t.translation_id) as word_count
      FROM categories c
      LEFT JOIN translations t ON c.category_id = t.category_id
    ''';
    
    List<dynamic> whereArgs = [];
    if (languageId != null) {
      query += ' WHERE t.language_id = ?';
      whereArgs.add(languageId);
    }
    
    query += '''
      GROUP BY c.category_id, c.category_name, c.description
      ORDER BY word_count DESC
      LIMIT $limit
    ''';

    return await db.rawQuery(query, whereArgs);
  }

  /// Get random word of the day
  static Future<Map<String, dynamic>?> getWordOfTheDay({
    String? languageId,
  }) async {
    final db = await database;
    String whereClause = 'difficulty_level = ?';
    List<dynamic> whereArgs = ['beginner'];

    if (languageId != null) {
      whereClause += ' AND language_id = ?';
      whereArgs.add(languageId);
    }

    final results = await db.query(
      'translations',
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
      orderBy: 'RANDOM()',
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Close the database connection
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}