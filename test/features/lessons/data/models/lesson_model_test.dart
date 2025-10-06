import 'package:flutter_test/flutter_test.dart';
import 'package:maa_yegue/features/lessons/data/models/lesson_model.dart';
import 'package:maa_yegue/features/lessons/data/models/lesson_content_model.dart';
import 'package:maa_yegue/features/lessons/domain/entities/lesson.dart';
import 'package:maa_yegue/features/lessons/domain/entities/lesson_content.dart';

void main() {
  group('LessonModel', () {
    final tLessonModel = LessonModel(
      id: 'lesson-1',
      courseId: 'course-1',
      title: 'Introduction to Ewondo',
      description: 'Learn basic greetings in Ewondo',
      order: 1,
      type: LessonType.vocabulary,
      status: LessonStatus.available,
      estimatedDuration: 15,
      thumbnailUrl: 'https://example.com/thumbnail.jpg',
      contents: [
        LessonContentModel(
          id: 'content-1',
          lessonId: 'lesson-1',
          type: ContentType.text,
          content: 'Welcome to Ewondo lessons',
          metadata: const {'difficulty': 'beginner'},
          order: 1,
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        ),
        LessonContentModel(
          id: 'content-2',
          lessonId: 'lesson-1',
          type: ContentType.audio,
          content: 'audio_url.mp3',
          audioUrl: 'audio_url.mp3',
          metadata: const {'duration': 30},
          order: 2,
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        ),
      ],
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
    );

    group('fromJson', () {
      test('should return a valid LessonModel when JSON is valid', () {
        // arrange
        final json = {
          'id': 'lesson-1',
          'courseId': 'course-1',
          'title': 'Introduction to Ewondo',
          'description': 'Learn basic greetings in Ewondo',
          'order': 1,
          'type': 0, // LessonType.vocabulary
          'status': 1, // LessonStatus.available
          'estimatedDuration': 15,
          'thumbnailUrl': 'https://example.com/thumbnail.jpg',
          'contents': [
            {
              'id': 'content-1',
              'lessonId': 'lesson-1',
              'type': 0, // ContentType.text
              'content': 'Welcome to Ewondo lessons',
              'metadata': {'difficulty': 'beginner'},
              'order': 1,
              'createdAt': '2024-01-01T00:00:00.000Z',
              'updatedAt': '2024-01-01T00:00:00.000Z',
            },
            {
              'id': 'content-2',
              'lessonId': 'lesson-1',
              'type': 1, // ContentType.audio
              'content': 'audio_url.mp3',
              'audioUrl': 'audio_url.mp3',
              'metadata': {'duration': 30},
              'order': 2,
              'createdAt': '2024-01-01T00:00:00.000Z',
              'updatedAt': '2024-01-01T00:00:00.000Z',
            },
          ],
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        // act
        final result = LessonModel.fromJson(json);

        // assert
        expect(result.id, 'lesson-1');
        expect(result.courseId, 'course-1');
        expect(result.title, 'Introduction to Ewondo');
        expect(result.description, 'Learn basic greetings in Ewondo');
        expect(result.order, 1);
        expect(result.type, LessonType.vocabulary);
        expect(result.status, LessonStatus.available);
        expect(result.estimatedDuration, 15);
        expect(result.thumbnailUrl, 'https://example.com/thumbnail.jpg');
        expect(result.contents.length, 2);
        expect(result.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
        expect(result.updatedAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
      });

      test('should handle empty contents array', () {
        // arrange
        final json = {
          'id': 'lesson-1',
          'courseId': 'course-1',
          'title': 'Test Lesson',
          'description': 'Test Description',
          'order': 1,
          'type': 0,
          'status': 1,
          'estimatedDuration': 10,
          'thumbnailUrl': 'https://example.com/thumbnail.jpg',
          'contents': [],
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        // act
        final result = LessonModel.fromJson(json);

        // assert
        expect(result.contents, []);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // act
        final result = tLessonModel.toJson();

        // assert
        expect(result['id'], 'lesson-1');
        expect(result['courseId'], 'course-1');
        expect(result['title'], 'Introduction to Ewondo');
        expect(result['description'], 'Learn basic greetings in Ewondo');
        expect(result['order'], 1);
        expect(result['type'], 0); // LessonType.vocabulary index
        expect(result['status'], 1); // LessonStatus.available index
        expect(result['estimatedDuration'], 15);
        expect(result['thumbnailUrl'], 'https://example.com/thumbnail.jpg');
        expect(result['contents'], isA<List>());
        expect(result['createdAt'], '2024-01-01T00:00:00.000Z');
        expect(result['updatedAt'], '2024-01-01T00:00:00.000Z');
      });
    });

    group('toEntity', () {
      test('should return a valid Lesson entity', () {
        // act
        final result = tLessonModel.toEntity();

        // assert
        expect(result, isA<Lesson>());
        expect(result.id, 'lesson-1');
        expect(result.courseId, 'course-1');
        expect(result.title, 'Introduction to Ewondo');
        expect(result.description, 'Learn basic greetings in Ewondo');
        expect(result.order, 1);
        expect(result.type, LessonType.vocabulary);
        expect(result.status, LessonStatus.available);
        expect(result.estimatedDuration, 15);
        expect(result.thumbnailUrl, 'https://example.com/thumbnail.jpg');
        expect(result.contents.length, 2);
      });
    });

    group('fromEntity', () {
      test('should create LessonModel from Lesson entity', () {
        // arrange
        final lesson = Lesson(
          id: 'entity-lesson-1',
          courseId: 'entity-course-1',
          title: 'Entity Lesson',
          description: 'Entity Description',
          order: 2,
          type: LessonType.grammar,
          status: LessonStatus.inProgress,
          estimatedDuration: 20,
          thumbnailUrl: 'https://entity.com/thumbnail.jpg',
          contents: const [],
          createdAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
        );

        // act
        final result = LessonModel.fromEntity(lesson);

        // assert
        expect(result.id, 'entity-lesson-1');
        expect(result.courseId, 'entity-course-1');
        expect(result.title, 'Entity Lesson');
        expect(result.description, 'Entity Description');
        expect(result.order, 2);
        expect(result.type, LessonType.grammar);
        expect(result.status, LessonStatus.inProgress);
        expect(result.estimatedDuration, 20);
        expect(result.thumbnailUrl, 'https://entity.com/thumbnail.jpg');
        expect(result.contents, []);
      });
    });

    group('copyWith', () {
      test('should return a new LessonModel with updated fields', () {
        // act
        final result = tLessonModel.copyWith(
          title: 'Updated Lesson Title',
          status: LessonStatus.completed,
          order: 2,
        );

        // assert
        expect(result.id, 'lesson-1'); // unchanged
        expect(result.title, 'Updated Lesson Title');
        expect(result.status, LessonStatus.completed);
        expect(result.order, 2);
        expect(
          result.description,
          'Learn basic greetings in Ewondo',
        ); // unchanged
        expect(result.courseId, 'course-1'); // unchanged
      });

      test('should return the same LessonModel when no fields are updated', () {
        // act
        final result = tLessonModel.copyWith();

        // assert
        expect(result.id, tLessonModel.id);
        expect(result.title, tLessonModel.title);
        expect(result.description, tLessonModel.description);
        expect(result.order, tLessonModel.order);
        expect(result.type, tLessonModel.type);
        expect(result.status, tLessonModel.status);
      });
    });

    group('status checks', () {
      test('should correctly identify completed status', () {
        // arrange
        final completedLesson = tLessonModel.copyWith(
          status: LessonStatus.completed,
        );

        // assert
        expect(completedLesson.isCompleted, true);
        expect(completedLesson.isInProgress, false);
        expect(completedLesson.isLocked, false);
      });

      test('should correctly identify in-progress status', () {
        // arrange
        final inProgressLesson = tLessonModel.copyWith(
          status: LessonStatus.inProgress,
        );

        // assert
        expect(inProgressLesson.isCompleted, false);
        expect(inProgressLesson.isInProgress, true);
        expect(inProgressLesson.isLocked, false);
      });

      test('should correctly identify locked status', () {
        // arrange
        final lockedLesson = tLessonModel.copyWith(status: LessonStatus.locked);

        // assert
        expect(lockedLesson.isCompleted, false);
        expect(lockedLesson.isInProgress, false);
        expect(lockedLesson.isLocked, true);
      });
    });

    group('toMap', () {
      test('should return a map suitable for database operations', () {
        // act
        final result = tLessonModel.toMap();

        // assert
        expect(result['lesson_id'], 0); // int.tryParse('lesson-1') ?? 0
        expect(result['language_id'], 'course-1');
        expect(result['title'], 'Introduction to Ewondo');
        expect(result['description'], 'Learn basic greetings in Ewondo');
        expect(result['order_index'], 1);
        expect(result['type'], 'vocabulary');
        expect(result['status'], 'available');
        expect(result['estimated_duration'], 15);
        expect(result['thumbnail_url'], 'https://example.com/thumbnail.jpg');
        expect(result['created_at'], '2024-01-01T00:00:00.000Z');
        expect(result['updated_at'], '2024-01-01T00:00:00.000Z');
      });
    });
  });

  group('LessonContentModel', () {
    final tContentModel = LessonContentModel(
      id: 'content-1',
      lessonId: 'lesson-1',
      type: ContentType.text,
      content: 'Hello world',
      metadata: const {'difficulty': 'easy'},
      order: 1,
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
    );

    group('fromJson', () {
      test('should create LessonContentModel from JSON', () {
        // arrange
        final json = {
          'id': 'content-1',
          'lessonId': 'lesson-1',
          'type': 0, // ContentType.text
          'content': 'Hello world',
          'metadata': {'difficulty': 'easy'},
          'order': 1,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        // act
        final result = LessonContentModel.fromJson(json);

        // assert
        expect(result.id, 'content-1');
        expect(result.lessonId, 'lesson-1');
        expect(result.type, ContentType.text);
        expect(result.content, 'Hello world');
        expect(result.metadata, {'difficulty': 'easy'});
        expect(result.order, 1);
        expect(result.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
        expect(result.updatedAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
      });

      test('should handle different content types', () {
        // Test audio content
        final audioJson = {
          'id': 'audio-1',
          'lessonId': 'lesson-1',
          'type': 1, // ContentType.audio
          'content': 'audio_url.mp3',
          'audioUrl': 'audio_url.mp3',
          'metadata': {'duration': 30},
          'order': 1,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final audioResult = LessonContentModel.fromJson(audioJson);
        expect(audioResult.type, ContentType.audio);
        expect(audioResult.content, 'audio_url.mp3');
        expect(audioResult.audioUrl, 'audio_url.mp3');

        // Test video content
        final videoJson = {
          'id': 'video-1',
          'lessonId': 'lesson-1',
          'type': 3, // ContentType.video
          'content': 'video_url.mp4',
          'videoUrl': 'video_url.mp4',
          'metadata': {'duration': 120},
          'order': 2,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        };

        final videoResult = LessonContentModel.fromJson(videoJson);
        expect(videoResult.type, ContentType.video);
        expect(videoResult.content, 'video_url.mp4');
        expect(videoResult.videoUrl, 'video_url.mp4');
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // act
        final result = tContentModel.toJson();

        // assert
        expect(result['id'], 'content-1');
        expect(result['lessonId'], 'lesson-1');
        expect(result['type'], 0); // ContentType.text index
        expect(result['content'], 'Hello world');
        expect(result['metadata'], {'difficulty': 'easy'});
        expect(result['order'], 1);
        expect(result['createdAt'], '2024-01-01T00:00:00.000Z');
        expect(result['updatedAt'], '2024-01-01T00:00:00.000Z');
      });
    });

    group('toEntity', () {
      test('should return a valid LessonContent entity', () {
        // act
        final result = tContentModel.toEntity();

        // assert
        expect(result, isA<LessonContent>());
        expect(result.id, 'content-1');
        expect(result.lessonId, 'lesson-1');
        expect(result.type, ContentType.text);
        expect(result.content, 'Hello world');
        expect(result.metadata, {'difficulty': 'easy'});
        expect(result.order, 1);
      });
    });

    group('fromEntity', () {
      test('should create LessonContentModel from LessonContent entity', () {
        // arrange
        final content = LessonContent(
          id: 'entity-content-1',
          lessonId: 'entity-lesson-1',
          type: ContentType.image,
          content: 'Entity content',
          imageUrl: 'image_url.jpg',
          metadata: const {'caption': 'Test image'},
          order: 3,
          createdAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
        );

        // act
        final result = LessonContentModel.fromEntity(content);

        // assert
        expect(result.id, 'entity-content-1');
        expect(result.lessonId, 'entity-lesson-1');
        expect(result.type, ContentType.image);
        expect(result.content, 'Entity content');
        expect(result.imageUrl, 'image_url.jpg');
        expect(result.metadata, {'caption': 'Test image'});
        expect(result.order, 3);
      });
    });

    group('copyWith', () {
      test('should return a new LessonContentModel with updated fields', () {
        // act
        final result = tContentModel.copyWith(
          content: 'Updated content',
          type: ContentType.video,
          order: 2,
        );

        // assert
        expect(result.id, 'content-1'); // unchanged
        expect(result.content, 'Updated content');
        expect(result.type, ContentType.video);
        expect(result.order, 2);
        expect(result.lessonId, 'lesson-1'); // unchanged
      });
    });
  });
}
