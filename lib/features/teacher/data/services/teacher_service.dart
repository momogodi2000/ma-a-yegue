import 'package:flutter/foundation.dart';
import '../../../../core/database/unified_database_service.dart';
import 'dart:convert';

/// Service for teacher users
///
/// Teachers can:
/// - Create and edit lessons
/// - Create and edit quizzes
/// - Add dictionary words/translations
/// - View student statistics (if applicable)
/// - Manage their own content
class TeacherService {
  static final _db = UnifiedDatabaseService.instance;

  /// Create a new lesson
  static Future<Map<String, dynamic>> createLesson({
    required String teacherId,
    required String languageId,
    required String title,
    required String content,
    required String level,
    String? audioUrl,
    String? videoUrl,
    String status = 'draft',
  }) async {
    try {
      final lessonId = await _db.createLesson({
        'creator_id': teacherId,
        'language_id': languageId,
        'title': title,
        'content': content,
        'level': level,
        'audio_url': audioUrl,
        'video_url': videoUrl,
        'status': status,
      });

      debugPrint('✅ Lesson created by teacher $teacherId: $title');

      return {
        'success': true,
        'lesson_id': lessonId,
        'message': 'Leçon créée avec succès',
      };
    } catch (e) {
      debugPrint('Error creating lesson: $e');
      return {
        'success': false,
        'error': 'Erreur lors de la création de la leçon',
      };
    }
  }

  /// Create a new quiz
  static Future<Map<String, dynamic>> createQuiz({
    required String teacherId,
    required String languageId,
    required String title,
    String? description,
    String? difficultyLevel,
    String? categoryId,
  }) async {
    try {
      final quizId = await _db.createQuiz(
        creatorId: teacherId,
        languageId: languageId,
        title: title,
        description: description,
        difficultyLevel: difficultyLevel,
        categoryId: categoryId,
      );

      debugPrint('✅ Quiz created by teacher $teacherId: $title');

      return {
        'success': true,
        'quiz_id': quizId,
        'message': 'Quiz créé avec succès',
      };
    } catch (e) {
      debugPrint('Error creating quiz: $e');
      return {'success': false, 'error': 'Erreur lors de la création du quiz'};
    }
  }

  /// Add question to quiz
  static Future<Map<String, dynamic>> addQuizQuestion({
    required int quizId,
    required String questionText,
    required String questionType,
    required String correctAnswer,
    List<String>? options,
    int points = 1,
    String? explanation,
    int orderIndex = 0,
  }) async {
    try {
      final questionId = await _db.addQuizQuestion(
        quizId: quizId,
        questionText: questionText,
        questionType: questionType,
        correctAnswer: correctAnswer,
        options: options != null ? jsonEncode(options) : null,
        points: points,
        explanation: explanation,
        orderIndex: orderIndex,
      );

      debugPrint('✅ Question added to quiz #$quizId');

      return {
        'success': true,
        'question_id': questionId,
        'message': 'Question ajoutée avec succès',
      };
    } catch (e) {
      debugPrint('Error adding quiz question: $e');
      return {
        'success': false,
        'error': 'Erreur lors de l\'ajout de la question',
      };
    }
  }

  /// Add a new word/translation
  static Future<Map<String, dynamic>> addTranslation({
    required String teacherId,
    required String languageId,
    required String frenchText,
    required String translation,
    String? categoryId,
    String? pronunciation,
    String? usageNotes,
    String? difficultyLevel,
  }) async {
    try {
      final translationId = await _db.createTranslation({
        'creator_id': teacherId,
        'language_id': languageId,
        'french_text': frenchText,
        'translation': translation,
        'category_id': categoryId,
        'pronunciation': pronunciation,
        'usage_notes': usageNotes,
        'difficulty_level': difficultyLevel ?? 'beginner',
      });

      debugPrint(
        '✅ Translation added by teacher $teacherId: $frenchText -> $translation',
      );

      return {
        'success': true,
        'translation_id': translationId,
        'message': 'Traduction ajoutée avec succès',
      };
    } catch (e) {
      debugPrint('Error adding translation: $e');
      return {
        'success': false,
        'error': 'Erreur lors de l\'ajout de la traduction',
      };
    }
  }

  /// Get all content created by teacher
  static Future<List<Map<String, dynamic>>> getCreatedContent({
    required String teacherId,
    String? contentType,
    String? status,
  }) async {
    try {
      return await _db.getUserCreatedContent(
        teacherId,
        contentType: contentType,
        status: status,
      );
    } catch (e) {
      debugPrint('Error getting created content: $e');
      return [];
    }
  }

  /// Get created lessons
  static Future<List<Map<String, dynamic>>> getCreatedLessons({
    required String teacherId,
    String? status,
  }) async {
    try {
      return await _db.getUserCreatedContent(
        teacherId,
        contentType: 'lesson',
        status: status,
      );
    } catch (e) {
      debugPrint('Error getting created lessons: $e');
      return [];
    }
  }

  /// Get created quizzes
  static Future<List<Map<String, dynamic>>> getCreatedQuizzes({
    required String teacherId,
    String? status,
  }) async {
    try {
      return await _db.getUserCreatedContent(
        teacherId,
        contentType: 'quiz',
        status: status,
      );
    } catch (e) {
      debugPrint('Error getting created quizzes: $e');
      return [];
    }
  }

  /// Get created translations
  static Future<List<Map<String, dynamic>>> getCreatedTranslations({
    required String teacherId,
    String? status,
  }) async {
    try {
      return await _db.getUserCreatedContent(
        teacherId,
        contentType: 'translation',
        status: status,
      );
    } catch (e) {
      debugPrint('Error getting created translations: $e');
      return [];
    }
  }

  /// Publish content
  static Future<Map<String, dynamic>> publishContent({
    required int contentId,
  }) async {
    try {
      await _db.updateContentStatus(contentId: contentId, status: 'published');

      debugPrint('✅ Content #$contentId published');

      return {'success': true, 'message': 'Contenu publié avec succès'};
    } catch (e) {
      debugPrint('Error publishing content: $e');
      return {'success': false, 'error': 'Erreur lors de la publication'};
    }
  }

  /// Archive content
  static Future<Map<String, dynamic>> archiveContent({
    required int contentId,
  }) async {
    try {
      await _db.updateContentStatus(contentId: contentId, status: 'archived');

      debugPrint('✅ Content #$contentId archived');

      return {'success': true, 'message': 'Contenu archivé avec succès'};
    } catch (e) {
      debugPrint('Error archiving content: $e');
      return {'success': false, 'error': 'Erreur lors de l\'archivage'};
    }
  }

  /// Delete content
  static Future<Map<String, dynamic>> deleteContent({
    required int contentId,
  }) async {
    try {
      await _db.deleteUserContent(contentId);

      debugPrint('✅ Content #$contentId deleted');

      return {'success': true, 'message': 'Contenu supprimé avec succès'};
    } catch (e) {
      debugPrint('Error deleting content: $e');
      return {'success': false, 'error': 'Erreur lors de la suppression'};
    }
  }

  /// Get teacher statistics (content created, etc.)
  static Future<Map<String, dynamic>> getTeacherStatistics(
    String teacherId,
  ) async {
    try {
      final allContent = await _db.getUserCreatedContent(teacherId);

      final lessons = allContent
          .where((c) => c['content_type'] == 'lesson')
          .length;
      final quizzes = allContent
          .where((c) => c['content_type'] == 'quiz')
          .length;
      final translations = allContent
          .where((c) => c['content_type'] == 'translation')
          .length;

      final published = allContent
          .where((c) => c['status'] == 'published')
          .length;
      final drafts = allContent.where((c) => c['status'] == 'draft').length;
      final archived = allContent
          .where((c) => c['status'] == 'archived')
          .length;

      return {
        'total_content': allContent.length,
        'lessons_created': lessons,
        'quizzes_created': quizzes,
        'translations_created': translations,
        'published_count': published,
        'draft_count': drafts,
        'archived_count': archived,
      };
    } catch (e) {
      debugPrint('Error getting teacher statistics: $e');
      return {};
    }
  }

  /// Get available languages for content creation
  static Future<List<Map<String, dynamic>>> getAvailableLanguages() async {
    try {
      return await _db.getAllLanguages();
    } catch (e) {
      debugPrint('Error getting languages: $e');
      return [];
    }
  }

  /// Get available categories for content creation
  static Future<List<Map<String, dynamic>>> getAvailableCategories() async {
    try {
      return await _db.getAllCategories();
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  /// Validate lesson data before creation
  static Map<String, dynamic> validateLessonData({
    required String title,
    required String content,
    required String languageId,
    required String level,
  }) {
    final errors = <String>[];

    if (title.trim().isEmpty) {
      errors.add('Le titre est requis');
    }
    if (content.trim().isEmpty) {
      errors.add('Le contenu est requis');
    }
    if (languageId.trim().isEmpty) {
      errors.add('La langue est requise');
    }
    if (!['beginner', 'intermediate', 'advanced'].contains(level)) {
      errors.add('Niveau invalide');
    }

    return {'isValid': errors.isEmpty, 'errors': errors};
  }

  /// Validate quiz data before creation
  static Map<String, dynamic> validateQuizData({
    required String title,
    required String languageId,
  }) {
    final errors = <String>[];

    if (title.trim().isEmpty) {
      errors.add('Le titre est requis');
    }
    if (languageId.trim().isEmpty) {
      errors.add('La langue est requise');
    }

    return {'isValid': errors.isEmpty, 'errors': errors};
  }

  /// Validate translation data before creation
  static Map<String, dynamic> validateTranslationData({
    required String frenchText,
    required String translation,
    required String languageId,
  }) {
    final errors = <String>[];

    if (frenchText.trim().isEmpty) {
      errors.add('Le texte en français est requis');
    }
    if (translation.trim().isEmpty) {
      errors.add('La traduction est requise');
    }
    if (languageId.trim().isEmpty) {
      errors.add('La langue est requise');
    }

    return {'isValid': errors.isEmpty, 'errors': errors};
  }
}
