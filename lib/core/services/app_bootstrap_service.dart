import 'package:flutter/foundation.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/default_lessons_service.dart';

/// Service to bootstrap the application with initial data
class AppBootstrapService {
  final FirebaseService _firebaseService;
  final GeminiAIService _aiService;
  late final DefaultLessonsService _lessonsService;

  AppBootstrapService(this._firebaseService, this._aiService) {
    _lessonsService = DefaultLessonsService(_firebaseService, _aiService);
  }

  /// Initialize the application with default data
  Future<void> initializeApp() async {
    try {
      // Check if we need to initialize default lessons
      final needsLessons = await _lessonsService.needsDefaultLessons('ewondo');
      
      if (needsLessons) {
        debugPrint('🚀 Initializing default lessons...');
        await _lessonsService.initializeDefaultLessons();
        debugPrint('✅ Default lessons initialized successfully');
      } else {
        debugPrint('ℹ️ Default lessons already exist');
      }

      // Get language statistics
      final languages = await _lessonsService.getLanguagesWithLessonCounts();
      debugPrint('📊 Available languages:');
      for (final lang in languages) {
        debugPrint('   ${lang['name']}: ${lang['lessonCount']} lessons');
      }

    } catch (e) {
      debugPrint('❌ Error during app initialization: $e');
      // Don't rethrow - app should still work without default lessons
    }
  }

  /// Initialize default lessons for a specific language
  Future<bool> initializeLessonsForLanguage(String languageCode) async {
    try {
      final needsLessons = await _lessonsService.needsDefaultLessons(languageCode);
      
      if (needsLessons) {
        // This would trigger initialization for that specific language
        // For now, we initialize all languages together
        await _lessonsService.initializeDefaultLessons();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error initializing lessons for $languageCode: $e');
      return false;
    }
  }

  /// Get available languages with their lesson counts
  Future<List<Map<String, dynamic>>> getAvailableLanguages() async {
    try {
      return await _lessonsService.getLanguagesWithLessonCounts();
    } catch (e) {
      debugPrint('❌ Error getting available languages: $e');
      return [];
    }
  }
}