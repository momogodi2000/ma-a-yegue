import 'package:flutter/foundation.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/usecases/get_chapters_usecase.dart';

/// ViewModel for Lesson functionality
class LessonViewModel extends ChangeNotifier {
  final GetLessonUseCase getLessonUseCase;
  final GetLessonsByChapterUseCase getLessonsByChapterUseCase;

  LessonViewModel({
    required this.getLessonUseCase,
    required this.getLessonsByChapterUseCase,
  });

  // State
  Lesson? _currentLesson;
  List<Lesson> _lessons = const <Lesson>[];
  bool _isLoading = false;
  String? _error;

  // Getters
  Lesson? get currentLesson => _currentLesson;
  List<Lesson> get lessons => _lessons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get lesson by ID
  Future<void> getLessonById(String lessonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final lesson = await getLessonUseCase(lessonId);
      if (lesson != null) {
        // Convert LessonEntity to Lesson if needed
        _currentLesson = Lesson(
          id: lesson.id,
          courseId: lesson.chapterId,
          title: lesson.title,
          description: lesson.description,
          order: lesson.order,
          type: _mapLessonType(lesson.category),
          status: LessonStatus.available,
          estimatedDuration: lesson.duration,
          thumbnailUrl: lesson.thumbnailUrl ?? '',
          contents: const [],
          createdAt: lesson.createdAt,
          updatedAt: lesson.updatedAt ?? lesson.createdAt,
        );
      } else {
        _error = 'Lesson not found';
      }
    } catch (e) {
      _error = 'Failed to load lesson: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get lessons by course
  Future<void> getLessonsByCourse(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final lessons = await getLessonsByChapterUseCase(courseId);
      _lessons = lessons
          .map(
            (lesson) => Lesson(
              id: lesson.id,
              courseId: lesson.chapterId,
              title: lesson.title,
              description: lesson.description,
              order: lesson.order,
              type: _mapLessonType(lesson.category),
              status: LessonStatus.available,
              estimatedDuration: lesson.duration,
              thumbnailUrl: lesson.thumbnailUrl ?? '',
              contents: const [],
              createdAt: lesson.createdAt,
              updatedAt: lesson.updatedAt ?? lesson.createdAt,
            ),
          )
          .toList();
    } catch (e) {
      _error = 'Failed to load lessons: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get next lesson
  Future<Lesson?> getNextLesson(String courseId, int currentOrder) async {
    try {
      final lessons = await getLessonsByChapterUseCase(courseId);
      final nextLesson = lessons
          .where((lesson) => lesson.order > currentOrder)
          .firstOrNull;
      if (nextLesson != null) {
        return Lesson(
          id: nextLesson.id,
          courseId: nextLesson.chapterId,
          title: nextLesson.title,
          description: nextLesson.description,
          order: nextLesson.order,
          type: _mapLessonType(nextLesson.category),
          status: LessonStatus.available,
          estimatedDuration: nextLesson.duration,
          thumbnailUrl: nextLesson.thumbnailUrl ?? '',
          contents: const [],
          createdAt: nextLesson.createdAt,
          updatedAt: nextLesson.updatedAt ?? nextLesson.createdAt,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get previous lesson
  Future<Lesson?> getPreviousLesson(String courseId, int currentOrder) async {
    try {
      final lessons = await getLessonsByChapterUseCase(courseId);
      final previousLesson = lessons
          .where((lesson) => lesson.order < currentOrder)
          .lastOrNull;
      if (previousLesson != null) {
        return Lesson(
          id: previousLesson.id,
          courseId: previousLesson.chapterId,
          title: previousLesson.title,
          description: previousLesson.description,
          order: previousLesson.order,
          type: _mapLessonType(previousLesson.category),
          status: LessonStatus.available,
          estimatedDuration: previousLesson.duration,
          thumbnailUrl: previousLesson.thumbnailUrl ?? '',
          contents: const [],
          createdAt: previousLesson.createdAt,
          updatedAt: previousLesson.updatedAt ?? previousLesson.createdAt,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Mark lesson as completed
  Future<void> markLessonAsCompleted(String lessonId, String userId) async {
    try {
      // Update current lesson if it's the one being marked as completed
      if (_currentLesson?.id == lessonId) {
        _currentLesson = _currentLesson!.copyWith(
          status: LessonStatus.completed,
        );
        notifyListeners();
      }
      // TODO: Implement actual completion logic
    } catch (e) {
      _error = 'Failed to mark lesson as completed: $e';
      notifyListeners();
    }
  }

  LessonType _mapLessonType(String category) {
    switch (category.toLowerCase()) {
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
}
