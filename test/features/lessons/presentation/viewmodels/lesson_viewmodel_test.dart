import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:maa_yegue/features/lessons/presentation/viewmodels/lesson_viewmodel.dart';
import 'package:maa_yegue/features/lessons/domain/usecases/get_chapters_usecase.dart';
import 'package:maa_yegue/features/lessons/domain/entities/lesson_entity.dart';

import 'lesson_viewmodel_test.mocks.dart';

// Generate mocks
@GenerateMocks([GetLessonUseCase, GetLessonsByChapterUseCase])
void main() {
  late LessonViewModel viewModel;
  late MockGetLessonUseCase mockGetLessonUseCase;
  late MockGetLessonsByChapterUseCase mockGetLessonsByChapterUseCase;

  final tLessonEntity = LessonEntity(
    id: 'lesson1',
    title: 'Test Lesson',
    description: 'Test Description',
    language: 'en',
    difficulty: 'beginner',
    chapterId: 'chapter1',
    order: 1,
    category: 'vocabulary',
    duration: 30,
    objectives: const ['Learn vocabulary'],
    isPremium: false,
    exercises: const [],
    metadata: const {},
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockGetLessonUseCase = MockGetLessonUseCase();
    mockGetLessonsByChapterUseCase = MockGetLessonsByChapterUseCase();
    
    viewModel = LessonViewModel(
      getLessonUseCase: mockGetLessonUseCase,
      getLessonsByChapterUseCase: mockGetLessonsByChapterUseCase,
    );
  });

  group('LessonViewModel', () {
    test('initial state should be correct', () {
      expect(viewModel.currentLesson, null);
      expect(viewModel.lessons, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
    });

    group('getLessonById', () {
      test('should load lesson successfully', () async {
        // arrange
        when(mockGetLessonUseCase('lesson1')).thenAnswer((_) async => tLessonEntity);

        // act
        await viewModel.getLessonById('lesson1');

        // assert
        expect(viewModel.currentLesson, isNotNull);
        expect(viewModel.currentLesson!.id, 'lesson1');
        expect(viewModel.isLoading, false);
        expect(viewModel.error, null);
      });

      test('should handle error when lesson not found', () async {
        // arrange
        when(mockGetLessonUseCase('nonexistent')).thenAnswer((_) async => null);

        // act
        await viewModel.getLessonById('nonexistent');

        // assert
        expect(viewModel.currentLesson, null);
        expect(viewModel.error, 'Lesson not found');
        expect(viewModel.isLoading, false);
      });
    });

    group('getLessonsByCourse', () {
      test('should load lessons successfully', () async {
        // arrange
        when(mockGetLessonsByChapterUseCase('course1'))
            .thenAnswer((_) async => [tLessonEntity]);

        // act
        await viewModel.getLessonsByCourse('course1');

        // assert
        expect(viewModel.lessons, isNotEmpty);
        expect(viewModel.lessons.length, 1);
        expect(viewModel.isLoading, false);
        expect(viewModel.error, null);
      });

      test('should handle error when loading lessons fails', () async {
        // arrange
        when(mockGetLessonsByChapterUseCase('course1'))
            .thenThrow(Exception('Network error'));

        // act
        await viewModel.getLessonsByCourse('course1');

        // assert
        expect(viewModel.lessons, isEmpty);
        expect(viewModel.error, contains('Failed to load lessons'));
        expect(viewModel.isLoading, false);
      });
    });

    group('getNextLesson', () {
      test('should return next lesson when available', () async {
        // arrange
        final lesson2 = LessonEntity(
          id: 'lesson2',
          title: 'Test Lesson 2',
          description: 'Test Description 2',
          language: 'en',
          difficulty: 'beginner',
          chapterId: 'chapter1',
          order: 2,
          category: 'vocabulary',
          duration: 30,
          objectives: const ['Learn vocabulary'],
          isPremium: false,
          exercises: const [],
          metadata: const {},
          createdAt: DateTime.now(),
        );
        
        final lessons = [tLessonEntity, lesson2];
        when(mockGetLessonsByChapterUseCase('course1'))
            .thenAnswer((_) async => lessons);

        // act
        final result = await viewModel.getNextLesson('course1', 1);

        // assert
        expect(result, isNotNull);
        expect(result!.id, 'lesson2');
      });

      test('should return null when no next lesson available', () async {
        // arrange
        when(mockGetLessonsByChapterUseCase('course1'))
            .thenAnswer((_) async => [tLessonEntity]);

        // act
        final result = await viewModel.getNextLesson('course1', 1);

        // assert
        expect(result, null);
      });
    });
  });
}