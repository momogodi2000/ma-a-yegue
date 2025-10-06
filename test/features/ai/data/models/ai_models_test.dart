import 'package:flutter_test/flutter_test.dart';
import 'package:maa_yegue/features/ai/data/models/ai_models.dart';
import 'package:maa_yegue/features/ai/domain/entities/ai_entities.dart';

void main() {
  group('AiModels', () {
    group('ConversationModel', () {
      final tConversationModel = ConversationModel(
        id: 'conversation-1',
        userId: 'user-1',
        title: 'Ewondo Greetings',
        messages: [
          MessageModel(
            id: 'msg-1',
            conversationId: 'conversation-1',
            sender: 'user',
            content: 'Hello, how do you say hello in Ewondo?',
            timestamp: DateTime.parse('2024-01-01T10:00:00.000Z'),
          ),
          MessageModel(
            id: 'msg-2',
            conversationId: 'conversation-1',
            sender: 'ai',
            content: 'In Ewondo, hello is "Mbote"',
            timestamp: DateTime.parse('2024-01-01T10:01:00.000Z'),
          ),
        ],
        createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-01T10:01:00.000Z'),
      );

      test('should create ConversationModel from JSON', () {
        // arrange
        final json = {
          'id': 'conversation-1',
          'userId': 'user-1',
          'title': 'Ewondo Greetings',
          'messages': [
            {
              'id': 'msg-1',
              'conversationId': 'conversation-1',
              'sender': 'user',
              'content': 'Hello, how do you say hello in Ewondo?',
              'timestamp': '2024-01-01T10:00:00.000Z',
            },
            {
              'id': 'msg-2',
              'conversationId': 'conversation-1',
              'sender': 'ai',
              'content': 'In Ewondo, hello is "Mbote"',
              'timestamp': '2024-01-01T10:01:00.000Z',
            },
          ],
          'createdAt': '2024-01-01T10:00:00.000Z',
          'updatedAt': '2024-01-01T10:01:00.000Z',
        };

        // act
        final result = ConversationModel.fromJson(json);

        // assert
        expect(result.id, 'conversation-1');
        expect(result.userId, 'user-1');
        expect(result.title, 'Ewondo Greetings');
        expect(result.messages.length, 2);
        expect(result.createdAt, isA<DateTime>());
        expect(result.updatedAt, isA<DateTime>());
      });

      test('should convert to JSON correctly', () {
        // act
        final result = tConversationModel.toJson();

        // assert
        expect(result['id'], 'conversation-1');
        expect(result['userId'], 'user-1');
        expect(result['title'], 'Ewondo Greetings');
        expect(result['messages'], isA<List>());
        expect(result['createdAt'], isA<String>());
        expect(result['updatedAt'], isA<String>());
      });

      test('should convert to entity correctly', () {
        // act
        final result = tConversationModel;

        // assert
        expect(result, isA<ConversationEntity>());
        expect(result.id, 'conversation-1');
        expect(result.userId, 'user-1');
        expect(result.title, 'Ewondo Greetings');
        expect(result.messages.length, 2);
        expect(result.createdAt, isA<DateTime>());
        expect(result.updatedAt, isA<DateTime>());
      });

      test('should handle empty messages list', () {
        // arrange
        final json = {
          'id': 'conversation-1',
          'userId': 'user-1',
          'title': 'Empty Conversation',
          'messages': [],
          'createdAt': '2024-01-01T10:00:00.000Z',
          'updatedAt': '2024-01-01T10:00:00.000Z',
        };

        // act
        final result = ConversationModel.fromJson(json);

        // assert
        expect(result.messages, []);
      });

      test('should handle copyWith correctly', () {
        // act
        final result = tConversationModel.copyWith(title: 'Updated Title');

        // assert
        expect(result.id, 'conversation-1');
        expect(result.userId, 'user-1');
        expect(result.title, 'Updated Title');
        expect(result.messages, tConversationModel.messages);
      });
    });

    group('MessageModel', () {
      final tMessageModel = MessageModel(
        id: 'msg-1',
        conversationId: 'conversation-1',
        sender: 'user',
        content: 'Hello, how are you?',
        timestamp: DateTime.parse('2024-01-01T10:00:00.000Z'),
      );

      test('should create MessageModel from JSON', () {
        // arrange
        final json = {
          'id': 'msg-1',
          'conversationId': 'conversation-1',
          'sender': 'user',
          'content': 'Hello, how are you?',
          'timestamp': '2024-01-01T10:00:00.000Z',
        };

        // act
        final result = MessageModel.fromMap(json);

        // assert
        expect(result.id, 'msg-1');
        expect(result.conversationId, 'conversation-1');
        expect(result.sender, 'user');
        expect(result.content, 'Hello, how are you?');
        expect(result.timestamp, isA<DateTime>());
      });

      test('should convert to JSON correctly', () {
        // act
        final result = tMessageModel.toJson();

        // assert
        expect(result['id'], 'msg-1');
        expect(result['conversationId'], 'conversation-1');
        expect(result['sender'], 'user');
        expect(result['content'], 'Hello, how are you?');
        expect(result['timestamp'], isA<String>());
      });

      test('should convert to entity correctly', () {
        // act
        final result = tMessageModel;

        // assert
        expect(result, isA<MessageEntity>());
        expect(result.id, 'msg-1');
        expect(result.conversationId, 'conversation-1');
        expect(result.sender, 'user');
        expect(result.content, 'Hello, how are you?');
        expect(result.timestamp, isA<DateTime>());
      });

      test('should handle different message senders', () {
        // Test AI message
        final aiMessage = MessageModel(
          id: 'msg-2',
          conversationId: 'conversation-1',
          sender: 'ai',
          content: 'I am doing well, thank you!',
          timestamp: DateTime.parse('2024-01-01T10:01:00.000Z'),
        );

        expect(aiMessage.sender, 'ai');

        // Test system message
        final systemMessage = MessageModel(
          id: 'msg-3',
          conversationId: 'conversation-1',
          sender: 'system',
          content: 'System message',
          timestamp: DateTime.parse('2024-01-01T10:02:00.000Z'),
        );

        expect(systemMessage.sender, 'system');
      });
    });

    group('AiResponseModel', () {
      final tAiResponseModel = AiResponseModel(
        content: 'In Ewondo, hello is "Mbote"',
        timestamp: DateTime.parse('2024-01-01T10:01:00.000Z'),
      );

      test('should create AiResponseModel from JSON', () {
        // arrange
        final json = {
          'content': 'In Ewondo, hello is "Mbote"',
          'timestamp': '2024-01-01T10:01:00.000Z',
        };

        // act
        final result = AiResponseModel.fromMap(json);

        // assert
        expect(result.content, 'In Ewondo, hello is "Mbote"');
        expect(result.timestamp, isA<DateTime>());
      });

      test('should convert to entity correctly', () {
        // act
        final result = tAiResponseModel;

        // assert
        expect(result, isA<AiResponseModel>());
        expect(result.content, 'In Ewondo, hello is "Mbote"');
        expect(result.timestamp, isA<DateTime>());
      });
    });

    group('AiTranslationModel', () {
      final tTranslationModel = AiTranslationModel(
        id: 'translation-1',
        userId: 'user-1',
        sourceText: 'Hello',
        sourceLanguage: 'en',
        targetText: 'Mbote',
        targetLanguage: 'ewondo',
        confidence: 0.92,
        createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
      );

      test('should create AiTranslationModel from JSON', () {
        // arrange
        final json = {
          'id': 'translation-1',
          'userId': 'user-1',
          'sourceText': 'Hello',
          'sourceLanguage': 'en',
          'targetText': 'Mbote',
          'targetLanguage': 'ewondo',
          'confidence': 0.92,
          'createdAt': '2024-01-01T10:00:00.000Z',
        };

        // act
        final result = AiTranslationModel.fromJson(json);

        // assert
        expect(result.id, 'translation-1');
        expect(result.userId, 'user-1');
        expect(result.sourceText, 'Hello');
        expect(result.targetText, 'Mbote');
        expect(result.sourceLanguage, 'en');
        expect(result.targetLanguage, 'ewondo');
        expect(result.confidence, 0.92);
        expect(result.createdAt, isA<DateTime>());
      });

      test('should convert to JSON correctly', () {
        // act
        final result = tTranslationModel.toJson();

        // assert
        expect(result['id'], 'translation-1');
        expect(result['userId'], 'user-1');
        expect(result['sourceText'], 'Hello');
        expect(result['targetText'], 'Mbote');
        expect(result['sourceLanguage'], 'en');
        expect(result['targetLanguage'], 'ewondo');
        expect(result['confidence'], 0.92);
        expect(result['createdAt'], isA<String>());
      });

      test('should convert to entity correctly', () {
        // act
        final result = tTranslationModel;

        // assert
        expect(result, isA<TranslationEntity>());
        expect(result.id, 'translation-1');
        expect(result.userId, 'user-1');
        expect(result.sourceText, 'Hello');
        expect(result.targetText, 'Mbote');
        expect(result.sourceLanguage, 'en');
        expect(result.targetLanguage, 'ewondo');
        expect(result.confidence, 0.92);
        expect(result.createdAt, isA<DateTime>());
      });

      test('should handle bidirectional translation', () {
        // arrange
        final reverseTranslation = AiTranslationModel(
          id: 'translation-2',
          userId: 'user-1',
          sourceText: 'Mbote',
          sourceLanguage: 'ewondo',
          targetText: 'Hello',
          targetLanguage: 'en',
          confidence: 0.88,
          createdAt: DateTime.parse('2024-01-01T10:01:00.000Z'),
        );

        // act
        final result = reverseTranslation;

        // assert
        expect(result.sourceLanguage, 'ewondo');
        expect(result.targetLanguage, 'en');
        expect(result.sourceText, 'Mbote');
        expect(result.targetText, 'Hello');
      });
    });

    group('PronunciationAssessmentModel', () {
      final tPronunciationModel = PronunciationAssessmentModel(
        id: 'assessment-1',
        userId: 'user-1',
        word: 'Mbote',
        language: 'ewondo',
        audioUrl: 'https://example.com/audio.mp3',
        score: 0.90,
        feedback:
            'Good pronunciation! Slight emphasis needed on the first syllable.',
        issues: [],
        assessedAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
      );

      test('should create PronunciationAssessmentModel from JSON', () {
        // arrange
        final json = {
          'id': 'assessment-1',
          'userId': 'user-1',
          'word': 'Mbote',
          'language': 'ewondo',
          'audioUrl': 'https://example.com/audio.mp3',
          'score': 0.90,
          'feedback':
              'Good pronunciation! Slight emphasis needed on the first syllable.',
          'issues': [],
          'assessedAt': '2024-01-01T10:00:00.000Z',
        };

        // act
        final result = PronunciationAssessmentModel.fromJson(json);

        // assert
        expect(result.id, 'assessment-1');
        expect(result.userId, 'user-1');
        expect(result.word, 'Mbote');
        expect(result.language, 'ewondo');
        expect(result.audioUrl, 'https://example.com/audio.mp3');
        expect(result.score, 0.90);
        expect(
          result.feedback,
          'Good pronunciation! Slight emphasis needed on the first syllable.',
        );
        expect(result.issues, []);
        expect(result.assessedAt, isA<DateTime>());
      });

      test('should convert to JSON correctly', () {
        // act
        final result = tPronunciationModel.toJson();

        // assert
        expect(result['id'], 'assessment-1');
        expect(result['userId'], 'user-1');
        expect(result['word'], 'Mbote');
        expect(result['language'], 'ewondo');
        expect(result['audioUrl'], 'https://example.com/audio.mp3');
        expect(result['score'], 0.90);
        expect(
          result['feedback'],
          'Good pronunciation! Slight emphasis needed on the first syllable.',
        );
        expect(result['issues'], []);
        expect(result['assessedAt'], isA<String>());
      });

      test('should convert to entity correctly', () {
        // act
        final result = tPronunciationModel;

        // assert
        expect(result, isA<PronunciationAssessmentEntity>());
        expect(result.id, 'assessment-1');
        expect(result.userId, 'user-1');
        expect(result.word, 'Mbote');
        expect(result.language, 'ewondo');
        expect(result.audioUrl, 'https://example.com/audio.mp3');
        expect(result.score, 0.90);
        expect(
          result.feedback,
          'Good pronunciation! Slight emphasis needed on the first syllable.',
        );
        expect(result.issues, []);
        expect(result.assessedAt, isA<DateTime>());
      });
    });

    group('ContentGenerationModel', () {
      final tContentGenerationModel = ContentGenerationModel(
        id: 'generation-1',
        userId: 'user-1',
        type: 'lesson',
        topic: 'Greetings in Ewondo',
        language: 'ewondo',
        difficulty: 'beginner',
        generatedContent: 'Here is a lesson about greetings in Ewondo...',
        tags: ['greetings', 'basic'],
        generatedAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
      );

      test('should create ContentGenerationModel from JSON', () {
        // arrange
        final json = {
          'id': 'generation-1',
          'userId': 'user-1',
          'type': 'lesson',
          'topic': 'Greetings in Ewondo',
          'language': 'ewondo',
          'difficulty': 'beginner',
          'generatedContent': 'Here is a lesson about greetings in Ewondo...',
          'tags': ['greetings', 'basic'],
          'generatedAt': '2024-01-01T10:00:00.000Z',
        };

        // act
        final result = ContentGenerationModel.fromJson(json);

        // assert
        expect(result.id, 'generation-1');
        expect(result.userId, 'user-1');
        expect(result.type, 'lesson');
        expect(result.topic, 'Greetings in Ewondo');
        expect(result.language, 'ewondo');
        expect(result.difficulty, 'beginner');
        expect(
          result.generatedContent,
          'Here is a lesson about greetings in Ewondo...',
        );
        expect(result.tags, ['greetings', 'basic']);
        expect(result.generatedAt, isA<DateTime>());
      });

      test('should convert to JSON correctly', () {
        // act
        final result = tContentGenerationModel.toJson();

        // assert
        expect(result['id'], 'generation-1');
        expect(result['userId'], 'user-1');
        expect(result['type'], 'lesson');
        expect(result['topic'], 'Greetings in Ewondo');
        expect(result['language'], 'ewondo');
        expect(result['difficulty'], 'beginner');
        expect(
          result['generatedContent'],
          'Here is a lesson about greetings in Ewondo...',
        );
        expect(result['tags'], ['greetings', 'basic']);
        expect(result['generatedAt'], isA<String>());
      });

      test('should convert to entity correctly', () {
        // act
        final result = tContentGenerationModel;

        // assert
        expect(result, isA<ContentGenerationEntity>());
        expect(result.id, 'generation-1');
        expect(result.userId, 'user-1');
        expect(result.type, 'lesson');
        expect(result.topic, 'Greetings in Ewondo');
        expect(result.language, 'ewondo');
        expect(result.difficulty, 'beginner');
        expect(
          result.generatedContent,
          'Here is a lesson about greetings in Ewondo...',
        );
        expect(result.tags, ['greetings', 'basic']);
        expect(result.generatedAt, isA<DateTime>());
      });

      test('should handle different content types', () {
        // Test exercise generation
        final exerciseGeneration = ContentGenerationModel(
          id: 'generation-2',
          userId: 'user-1',
          type: 'exercise',
          topic: 'Vocabulary Quiz',
          language: 'ewondo',
          difficulty: 'intermediate',
          generatedContent: 'Quiz content...',
          tags: ['quiz', 'vocabulary'],
          generatedAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
        );

        expect(exerciseGeneration.type, 'exercise');

        // Test story generation
        final storyGeneration = ContentGenerationModel(
          id: 'generation-3',
          userId: 'user-1',
          type: 'story',
          topic: 'Cultural Story',
          language: 'ewondo',
          difficulty: 'advanced',
          generatedContent: 'Story content...',
          tags: ['story', 'culture'],
          generatedAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
        );

        expect(storyGeneration.type, 'story');
      });
    });

    group('AiLearningRecommendationModel', () {
      final tRecommendationModel = AiLearningRecommendationModel(
        id: 'recommendation-1',
        userId: 'user-1',
        type: 'lesson',
        title: 'Learn Ewondo Numbers',
        description: 'Practice counting from 1 to 10 in Ewondo',
        reason:
            'Based on your progress in greetings, you are ready for numbers',
        priority: 5,
        isCompleted: false,
        createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
      );

      test('should create AiLearningRecommendationModel from JSON', () {
        // arrange
        final json = {
          'id': 'recommendation-1',
          'userId': 'user-1',
          'type': 'lesson',
          'title': 'Learn Ewondo Numbers',
          'description': 'Practice counting from 1 to 10 in Ewondo',
          'reason':
              'Based on your progress in greetings, you are ready for numbers',
          'priority': 5,
          'isCompleted': false,
          'createdAt': '2024-01-01T10:00:00.000Z',
        };

        // act
        final result = AiLearningRecommendationModel.fromJson(json);

        // assert
        expect(result.id, 'recommendation-1');
        expect(result.userId, 'user-1');
        expect(result.type, 'lesson');
        expect(result.title, 'Learn Ewondo Numbers');
        expect(result.description, 'Practice counting from 1 to 10 in Ewondo');
        expect(
          result.reason,
          'Based on your progress in greetings, you are ready for numbers',
        );
        expect(result.priority, 5);
        expect(result.isCompleted, false);
        expect(result.createdAt, isA<DateTime>());
      });

      test('should convert to JSON correctly', () {
        // act
        final result = tRecommendationModel.toJson();

        // assert
        expect(result['id'], 'recommendation-1');
        expect(result['userId'], 'user-1');
        expect(result['type'], 'lesson');
        expect(result['title'], 'Learn Ewondo Numbers');
        expect(
          result['description'],
          'Practice counting from 1 to 10 in Ewondo',
        );
        expect(
          result['reason'],
          'Based on your progress in greetings, you are ready for numbers',
        );
        expect(result['priority'], 5);
        expect(result['isCompleted'], false);
        expect(result['createdAt'], isA<String>());
      });

      test('should convert to entity correctly', () {
        // act
        final result = tRecommendationModel;

        // assert
        expect(result, isA<AiLearningRecommendationEntity>());
        expect(result.id, 'recommendation-1');
        expect(result.userId, 'user-1');
        expect(result.type, 'lesson');
        expect(result.title, 'Learn Ewondo Numbers');
        expect(result.description, 'Practice counting from 1 to 10 in Ewondo');
        expect(
          result.reason,
          'Based on your progress in greetings, you are ready for numbers',
        );
        expect(result.priority, 5);
        expect(result.isCompleted, false);
        expect(result.createdAt, isA<DateTime>());
      });

      test('should handle different recommendation types', () {
        final exerciseRecommendation = AiLearningRecommendationModel(
          id: 'recommendation-2',
          userId: 'user-1',
          type: 'exercise',
          title: 'Practice Pronunciation',
          description: 'Work on your Ewondo pronunciation',
          reason: 'Your pronunciation needs improvement',
          priority: 3,
          isCompleted: false,
          createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
        );

        expect(exerciseRecommendation.type, 'exercise');

        final gameRecommendation = AiLearningRecommendationModel(
          id: 'recommendation-3',
          userId: 'user-1',
          type: 'game',
          title: 'Vocabulary Game',
          description: 'Play a fun vocabulary game',
          reason: 'Games make learning more engaging',
          priority: 1,
          isCompleted: false,
          createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
        );

        expect(gameRecommendation.type, 'game');
      });

      test('should handle different priority levels', () {
        final highPriorityRecommendation = AiLearningRecommendationModel(
          id: 'recommendation-1',
          userId: 'user-1',
          type: 'lesson',
          title: 'Important Lesson',
          description: 'This lesson is crucial for your progress',
          reason: 'High priority for your learning path',
          priority: 5,
          isCompleted: false,
          createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
        );

        expect(highPriorityRecommendation.priority, 5);

        final lowPriorityRecommendation = AiLearningRecommendationModel(
          id: 'recommendation-2',
          userId: 'user-1',
          type: 'lesson',
          title: 'Optional Lesson',
          description: 'This lesson is optional',
          reason: 'Nice to have but not essential',
          priority: 1,
          isCompleted: false,
          createdAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
        );

        expect(lowPriorityRecommendation.priority, 1);
      });
    });
  });
}
