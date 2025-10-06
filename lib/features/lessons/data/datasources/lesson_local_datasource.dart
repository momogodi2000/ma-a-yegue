import 'package:sqflite/sqflite.dart';
import '../../../../core/database/cameroon_languages_database_helper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/lesson.dart';
import '../models/lesson_model.dart';

/// Abstract data source for lesson operations
abstract class LessonDataSource {
  Future<List<LessonModel>> getLessonsByCourse(String courseId);
  Future<LessonModel> getLessonById(String lessonId);
  Future<LessonModel?> getNextLesson(String courseId, int currentOrder);
  Future<LessonModel?> getPreviousLesson(String courseId, int currentOrder);
  Future<bool> updateLessonStatus(String lessonId, LessonStatus status);
  Future<bool> completeLesson(String lessonId);
  Future<bool> resetLesson(String lessonId);
  Future<LessonModel> createLesson(LessonModel lesson);
  Future<LessonModel> updateLesson(String lessonId, LessonModel lesson);
  Future<bool> deleteLesson(String lessonId);
}

/// Local data source implementation using SQLite
class LessonLocalDataSource implements LessonDataSource {
  Future<void> initialize() async {
    // SQLite initialization is handled by DatabaseHelper
    // No additional initialization needed for this data source
  }

  @override
  Future<List<LessonModel>> getLessonsByCourse(String courseId) async {
    try {
      // courseId maps to language_id in the database
      final lessonsData =
          await CameroonLanguagesDatabaseHelper.getLessonsByLanguage(courseId);
      return lessonsData.map((data) => _mapDbToLessonModel(data)).toList();
    } catch (e) {
      throw CacheFailure('Failed to get lessons: $e');
    }
  }

  @override
  Future<LessonModel> getLessonById(String lessonId) async {
    try {
      final lessonData = await CameroonLanguagesDatabaseHelper.getLessonById(
          int.parse(lessonId));
      if (lessonData == null) {
        throw CacheFailure('Lesson not found: $lessonId');
      }
      return _mapDbToLessonModel(lessonData);
    } catch (e) {
      throw CacheFailure('Failed to get lesson: $e');
    }
  }

  @override
  Future<LessonModel?> getNextLesson(String courseId, int currentOrder) async {
    try {
      // Get all lessons for the course and find the next one
      final lessons = await getLessonsByCourse(courseId);
      final nextLesson =
          lessons.where((lesson) => lesson.order > currentOrder).toList();
      if (nextLesson.isEmpty) return null;
      return nextLesson.first;
    } catch (e) {
      throw CacheFailure('Failed to get next lesson: $e');
    }
  }

  @override
  Future<LessonModel?> getPreviousLesson(
      String courseId, int currentOrder) async {
    try {
      // Get all lessons for the course and find the previous one
      final lessons = await getLessonsByCourse(courseId);
      final previousLesson =
          lessons.where((lesson) => lesson.order < currentOrder).toList();
      if (previousLesson.isEmpty) return null;
      return previousLesson.last;
    } catch (e) {
      throw CacheFailure('Failed to get previous lesson: $e');
    }
  }

  @override
  Future<bool> updateLessonStatus(String lessonId, LessonStatus status) async {
    try {
      // Lessons are read-only content. Status updates should be handled through progress tracking.
      // This method exists for interface compatibility but doesn't modify lesson data.
      return true;
    } catch (e) {
      throw CacheFailure('Failed to update lesson status: $e');
    }
  }

  @override
  Future<bool> completeLesson(String lessonId) async {
    try {
      return await updateLessonStatus(lessonId, LessonStatus.completed);
    } catch (e) {
      throw CacheFailure('Failed to complete lesson: $e');
    }
  }

  @override
  Future<bool> resetLesson(String lessonId) async {
    try {
      return await updateLessonStatus(lessonId, LessonStatus.available);
    } catch (e) {
      throw CacheFailure('Failed to reset lesson: $e');
    }
  }

  @override
  Future<LessonModel> createLesson(LessonModel lesson) async {
    try {
      final db = await CameroonLanguagesDatabaseHelper.database;
      final lessonMap = {
        'language_id': lesson.courseId,
        'title': lesson.title,
        'content': lesson.description, // Using description as content
        'level': 'beginner', // Default level for new lessons
        'order_index': lesson.order,
        'audio_url': '', // Empty for now, can be updated later
        'video_url': '', // Empty for now, can be updated later
        'created_date': DateTime.now().toIso8601String(),
      };

      final id = await db.insert(
        'lessons',
        lessonMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Return the created lesson with the generated ID
      return lesson.copyWith(id: id.toString());
    } catch (e) {
      throw CacheFailure('Failed to create lesson: $e');
    }
  }

  @override
  Future<LessonModel> updateLesson(String lessonId, LessonModel lesson) async {
    try {
      final db = await CameroonLanguagesDatabaseHelper.database;
      final lessonMap = {
        'language_id': lesson.courseId,
        'title': lesson.title,
        'content': lesson.description,
        'level': 'beginner', // Default level for updated lessons
        'order_index': lesson.order,
        'audio_url': '', // Empty for now
        'video_url': '', // Empty for now
      };

      await db.update(
        'lessons',
        lessonMap,
        where: 'lesson_id = ?',
        whereArgs: [int.parse(lessonId)],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Return the updated lesson
      return lesson.copyWith(id: lessonId);
    } catch (e) {
      throw CacheFailure('Failed to update lesson: $e');
    }
  }

  @override
  Future<bool> deleteLesson(String lessonId) async {
    try {
      final db = await CameroonLanguagesDatabaseHelper.database;
      final rowsDeleted = await db.delete(
        'lessons',
        where: 'lesson_id = ?',
        whereArgs: [int.parse(lessonId)],
      );
      return rowsDeleted > 0;
    } catch (e) {
      throw CacheFailure('Failed to delete lesson: $e');
    }
  }

  /// Map database data to LessonModel
  LessonModel _mapDbToLessonModel(Map<String, dynamic> data) {
    return LessonModel(
      id: data['id'].toString(),
      courseId: data['language_id'].toString(),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      order: data['order'] ?? 0,
      type: _mapStringToLessonType(data['type'] ?? 'vocabulary'),
      status: _mapStringToLessonStatus(data['status'] ?? 'available'),
      estimatedDuration: data['estimated_duration'] ?? 15,
      thumbnailUrl: data['thumbnail_url'] ?? '',
      contents: const [], // Will be loaded separately if needed
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  /// Map string to LessonType enum
  LessonType _mapStringToLessonType(String type) {
    switch (type.toLowerCase()) {
      case 'vocabulary':
        return LessonType.vocabulary;
      case 'grammar':
        return LessonType.grammar;
      case 'conversation':
        return LessonType.conversation;
      case 'pronunciation':
        return LessonType.pronunciation;
      case 'culture':
        return LessonType.culture;
      case 'assessment':
        return LessonType.assessment;
      default:
        return LessonType.vocabulary;
    }
  }

  /// Map string to LessonStatus enum
  LessonStatus _mapStringToLessonStatus(String status) {
    switch (status.toLowerCase()) {
      case 'locked':
        return LessonStatus.locked;
      case 'available':
        return LessonStatus.available;
      case 'in_progress':
        return LessonStatus.inProgress;
      case 'completed':
        return LessonStatus.completed;
      default:
        return LessonStatus.available;
    }
  }
}
