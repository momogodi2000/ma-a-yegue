import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:maa_yegue/features/teacher/data/services/teacher_service.dart';
import 'package:maa_yegue/core/database/unified_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Initialize FFI for SQLite
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('TeacherService Tests', () {
    late UnifiedDatabaseService db;
    late String teacherId;

    setUp(() async {
      db = UnifiedDatabaseService.instance;
      await db.deleteDatabase();

      // Create a teacher user
      teacherId = 'teacher-123';
      await db.upsertUser({
        'user_id': teacherId,
        'firebase_uid': teacherId,
        'email': 'teacher@example.com',
        'display_name': 'Test Teacher',
        'role': 'teacher',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
    });

    tearDown(() async {
      await db.close();
    });

    test('Teacher can create a lesson', () async {
      final result = await TeacherService.createLesson(
        teacherId: teacherId,
        languageId: 'EWO',
        title: 'Test Lesson',
        content: 'This is a test lesson content',
        level: 'beginner',
        status: 'draft',
      );

      expect(result['success'], isTrue);
      expect(result['lesson_id'], isNotNull);

      // Verify lesson was created
      final lessons = await TeacherService.getCreatedLessons(
        teacherId: teacherId,
        status: 'draft',
      );

      expect(lessons.length, greaterThan(0));
      expect(lessons.first['title'], equals('Test Lesson'));
    });

    test('Teacher can create a quiz', () async {
      final result = await TeacherService.createQuiz(
        teacherId: teacherId,
        languageId: 'DUA',
        title: 'Test Quiz',
        description: 'This is a test quiz',
        difficultyLevel: 'beginner',
      );

      expect(result['success'], isTrue);
      expect(result['quiz_id'], isNotNull);

      // Verify quiz was created
      final quizzes = await TeacherService.getCreatedQuizzes(
        teacherId: teacherId,
      );

      expect(quizzes.length, greaterThan(0));
    });

    test('Teacher can add quiz questions', () async {
      // First create a quiz
      final quizResult = await TeacherService.createQuiz(
        teacherId: teacherId,
        languageId: 'FUL',
        title: 'Quiz with Questions',
      );

      final quizId = quizResult['quiz_id'] as int;

      // Add questions
      final questionResult = await TeacherService.addQuizQuestion(
        quizId: quizId,
        questionText: 'What is "Hello" in Fulfulde?',
        questionType: 'multiple_choice',
        correctAnswer: 'Jam waali',
        options: ['Jam waali', 'Mbolo', 'Kweni', 'Mwa boma'],
        points: 10,
        explanation: 'Jam waali is the standard greeting in Fulfulde',
      );

      expect(questionResult['success'], isTrue);
      expect(questionResult['question_id'], isNotNull);

      // Verify questions were added
      final questions = await db.getQuizQuestions(
        quizId,
        isFromCameroonDb: false,
      );
      expect(questions.length, equals(1));
      expect(
        questions.first['question_text'],
        equals('What is "Hello" in Fulfulde?'),
      );
    });

    test('Teacher can publish content', () async {
      // Create a lesson
      final lessonResult = await TeacherService.createLesson(
        teacherId: teacherId,
        languageId: 'BAS',
        title: 'Lesson to Publish',
        content: 'Content',
        level: 'intermediate',
        status: 'draft',
      );

      final contentId = lessonResult['lesson_id'] as int;

      // Publish it
      final publishResult = await TeacherService.publishContent(
        contentId: contentId,
      );

      expect(publishResult['success'], isTrue);

      // Verify it's published
      final publishedLessons = await TeacherService.getCreatedLessons(
        teacherId: teacherId,
        status: 'published',
      );

      expect(publishedLessons.length, equals(1));
    });

    test('Teacher can view their statistics', () async {
      // Create multiple content items
      await TeacherService.createLesson(
        teacherId: teacherId,
        languageId: 'EWO',
        title: 'Lesson 1',
        content: 'Content 1',
        level: 'beginner',
      );

      await TeacherService.createQuiz(
        teacherId: teacherId,
        languageId: 'DUA',
        title: 'Quiz 1',
      );

      await TeacherService.createLesson(
        teacherId: teacherId,
        languageId: 'FEF',
        title: 'Lesson 2',
        content: 'Content 2',
        level: 'intermediate',
        status: 'published',
      );

      // Get statistics
      final stats = await TeacherService.getTeacherStatistics(teacherId);

      expect(stats['total_content'], greaterThanOrEqualTo(3));
      expect(stats['lessons_created'], greaterThanOrEqualTo(2));
      expect(stats['quizzes_created'], greaterThanOrEqualTo(1));
      expect(stats['draft_count'], greaterThanOrEqualTo(2));
      expect(stats['published_count'], greaterThanOrEqualTo(1));
    });

    test('Teacher validation works correctly', () async {
      // Valid lesson data
      final validLesson = TeacherService.validateLessonData(
        title: 'Valid Lesson',
        content: 'Valid content',
        languageId: 'EWO',
        level: 'beginner',
      );
      expect(validLesson['isValid'], isTrue);
      expect(validLesson['errors'], isEmpty);

      // Invalid lesson data (empty title)
      final invalidLesson = TeacherService.validateLessonData(
        title: '',
        content: 'Content',
        languageId: 'EWO',
        level: 'beginner',
      );
      expect(invalidLesson['isValid'], isFalse);
      expect(invalidLesson['errors'], isNotEmpty);
    });
  });
}
