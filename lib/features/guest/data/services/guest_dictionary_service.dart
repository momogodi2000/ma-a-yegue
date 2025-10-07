import 'package:flutter/material.dart';
import '../../../../core/database/sqlite_database_helper.dart';

/// Dictionary service for guest users accessing local SQLite database
class GuestDictionaryService {
  /// Get available languages for guests
  static Future<List<Map<String, dynamic>>> getAvailableLanguages() async {
    try {
      final languages = await SQLiteDatabaseHelper.getLanguages();
      return languages
          .map((lang) => {
                'id': lang['language_id'],
                'name': lang['language_name'],
                'family': lang['language_family'],
                'region': lang['region'],
                'speakers': lang['speakers_count'],
                'description': lang['description'],
                'iso_code': lang['iso_code'],
              })
          .toList();
    } catch (e) {
      debugPrint('Error loading languages: $e');
      return [];
    }
  }

  /// Get categories for dictionary
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final categories = await SQLiteDatabaseHelper.getCategories();
      return categories
          .map((cat) => {
                'id': cat['category_id'],
                'name': cat['category_name'],
                'description': cat['description'],
              })
          .toList();
    } catch (e) {
      debugPrint('Error loading categories: $e');
      return [];
    }
  }

  /// Get basic words for guests (limited to 25 words max)
  static Future<List<Map<String, dynamic>>> getBasicWords({
    String? languageId,
    String? categoryId,
    int limit = 25,
  }) async {
    try {
      List<Map<String, dynamic>> words;
      
      if (categoryId != null) {
        words = await SQLiteDatabaseHelper.getTranslationsByCategory(
          categoryId,
          languageId: languageId,
          limit: limit,
        );
      } else {
        words = await SQLiteDatabaseHelper.getBasicWords(
          languageId: languageId,
          limit: limit,
        );
      }

      return words
          .map((word) => {
                'id': word['translation_id'],
                'french': word['french_text'],
                'translation': word['translation'],
                'language': word['language_id'],
                'category': word['category_id'],
                'pronunciation': word['pronunciation'],
                'usage_notes': word['usage_notes'],
                'difficulty': word['difficulty_level'],
              })
          .toList();
    } catch (e) {
      debugPrint('Error loading words: $e');
      return [];
    }
  }

  /// Search words in the dictionary (limited for guests)
  static Future<List<Map<String, dynamic>>> searchWords(
    String query, {
    String? languageId,
    int limit = 10,
  }) async {
    try {
      if (query.trim().isEmpty) return [];
      
      final words = await SQLiteDatabaseHelper.searchTranslations(
        query,
        languageId: languageId,
        limit: limit,
      );

      return words
          .map((word) => {
                'id': word['translation_id'],
                'french': word['french_text'],
                'translation': word['translation'],
                'language': word['language_id'],
                'category': word['category_id'],
                'pronunciation': word['pronunciation'],
                'usage_notes': word['usage_notes'],
                'difficulty': word['difficulty_level'],
              })
          .toList();
    } catch (e) {
      debugPrint('Error searching words: $e');
      return [];
    }
  }

  /// Get word of the day for guests
  static Future<Map<String, dynamic>?> getWordOfTheDay({
    String? languageId,
  }) async {
    try {
      final word = await SQLiteDatabaseHelper.getWordOfTheDay(
        languageId: languageId,
      );

      if (word == null) return null;

      return {
        'id': word['translation_id'],
        'french': word['french_text'],
        'translation': word['translation'],
        'language': word['language_id'],
        'category': word['category_id'],
        'pronunciation': word['pronunciation'],
        'usage_notes': word['usage_notes'],
        'difficulty': word['difficulty_level'],
      };
    } catch (e) {
      debugPrint('Error getting word of the day: $e');
      return null;
    }
  }

  /// Get words by category for guests
  static Future<List<Map<String, dynamic>>> getWordsByCategory(
    String categoryId, {
    String? languageId,
    int limit = 15,
  }) async {
    try {
      final words = await SQLiteDatabaseHelper.getTranslationsByCategory(
        categoryId,
        languageId: languageId,
        limit: limit,
      );

      return words
          .map((word) => {
                'id': word['translation_id'],
                'french': word['french_text'],
                'translation': word['translation'],
                'language': word['language_id'],
                'category': word['category_id'],
                'pronunciation': word['pronunciation'],
                'usage_notes': word['usage_notes'],
                'difficulty': word['difficulty_level'],
              })
          .toList();
    } catch (e) {
      debugPrint('Error loading words by category: $e');
      return [];
    }
  }

  /// Get popular categories with word counts
  static Future<List<Map<String, dynamic>>> getPopularCategories({
    String? languageId,
    int limit = 8,
  }) async {
    try {
      final categories = await SQLiteDatabaseHelper.getPopularCategories(
        languageId: languageId,
        limit: limit,
      );

      return categories
          .map((cat) => {
                'id': cat['category_id'],
                'name': cat['category_name'],
                'description': cat['description'],
                'word_count': cat['word_count'] ?? 0,
              })
          .toList();
    } catch (e) {
      debugPrint('Error loading popular categories: $e');
      return [];
    }
  }

  /// Get basic statistics for guests
  static Future<Map<String, int>> getDictionaryStats() async {
    try {
      return await SQLiteDatabaseHelper.getContentStats();
    } catch (e) {
      debugPrint('Error getting dictionary stats: $e');
      return {
        'languages': 0,
        'translations': 0,
        'lessons': 0,
        'categories': 0,
      };
    }
  }

  /// Get demo lessons for guests (limited)
  static Future<List<Map<String, dynamic>>> getDemoLessons({
    String? languageId,
    int limit = 3,
  }) async {
    try {
      final lessons = await SQLiteDatabaseHelper.getDemoLessons(
        languageId: languageId,
        limit: limit,
      );

      return lessons
          .map((lesson) => {
                'id': lesson['lesson_id'],
                'title': lesson['title'],
                'content': lesson['content'],
                'language': lesson['language_id'],
                'level': lesson['level'],
                'order_index': lesson['order_index'],
                'audio_url': lesson['audio_url'],
                'video_url': lesson['video_url'],
                'created_date': lesson['created_date'],
              })
          .toList();
    } catch (e) {
      debugPrint('Error loading demo lessons: $e');
      return [];
    }
  }

  /// Get a specific lesson by ID (for guests)
  static Future<Map<String, dynamic>?> getLessonById(int lessonId) async {
    try {
      final lesson = await SQLiteDatabaseHelper.getLessonById(lessonId);
      
      if (lesson == null) return null;

      return {
        'id': lesson['lesson_id'],
        'title': lesson['title'],
        'content': lesson['content'],
        'language': lesson['language_id'],
        'level': lesson['level'],
        'order_index': lesson['order_index'],
        'audio_url': lesson['audio_url'],
        'video_url': lesson['video_url'],
        'created_date': lesson['created_date'],
      };
    } catch (e) {
      debugPrint('Error loading lesson: $e');
      return null;
    }
  }

  /// Get featured content for guest dashboard
  static Future<Map<String, dynamic>> getFeaturedContent({
    String? languageId,
  }) async {
    try {
      // Get content in parallel
      final results = await Future.wait([
        getWordOfTheDay(languageId: languageId),
        getBasicWords(languageId: languageId, limit: 10),
        getDemoLessons(languageId: languageId, limit: 3),
        getPopularCategories(languageId: languageId, limit: 6),
      ]);

      return {
        'word_of_the_day': results[0],
        'featured_words': results[1],
        'demo_lessons': results[2],
        'popular_categories': results[3],
      };
    } catch (e) {
      debugPrint('Error loading featured content: $e');
      return {
        'word_of_the_day': null,
        'featured_words': <Map<String, dynamic>>[],
        'demo_lessons': <Map<String, dynamic>>[],
        'popular_categories': <Map<String, dynamic>>[],
      };
    }
  }
}