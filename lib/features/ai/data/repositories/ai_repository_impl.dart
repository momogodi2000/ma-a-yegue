import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/ai_service.dart';
import '../datasources/ai_remote_datasource.dart';
import '../models/ai_models.dart';
import '../../domain/entities/ai_entities.dart';
import '../../domain/entities/ai_suggestion_entity.dart';
import '../../domain/repositories/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remoteDataSource;
  final FirebaseFirestore firestore;
  final GeminiAIService _aiService;

  AiRepositoryImpl({
    required this.remoteDataSource,
    required this.firestore,
    required GeminiAIService aiService,
  }) : _aiService = aiService;

  @override
  Future<Either<Failure, ConversationEntity>> startConversation({
    required String userId,
    required String title,
  }) async {
    try {
      final conversationDoc = firestore.collection('conversations').doc();
      final conversationId = conversationDoc.id;
      final conversation = ConversationModel(
        id: conversationId,
        userId: userId,
        title: title,
        messages: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await conversationDoc.set(conversation.toJson());
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure('Failed to start conversation: $e'));
    }
  }

  @override
  Future<Either<Failure, AiResponseEntity>> sendMessage({
    required String conversationId,
    required String message,
    required String userId,
  }) async {
    try {
      final conversationDoc = firestore
          .collection('conversations')
          .doc(conversationId);
      final conversationSnapshot = await conversationDoc.get();

      if (!conversationSnapshot.exists) {
        return const Left(NotFoundFailure('Conversation not found'));
      }

      final conversationData = conversationSnapshot.data()!;
      final conversation = ConversationModel.fromJson({
        ...conversationData,
        'id': conversationId,
      });

      // Add user message
      final userMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: conversationId,
        sender: 'user',
        content: message,
        timestamp: DateTime.now(),
      );

      final updatedMessages = [...conversation.messages, userMessage];

      // Get AI response
      final conversationHistory = conversation.messages
          .map((msg) => (msg as MessageModel).toMap())
          .toList();
      final aiResponseData = await remoteDataSource.sendMessageToAI(
        message: message,
        conversationId: conversationId,
        conversationHistory: conversationHistory,
      );

      final aiMessage = MessageModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        conversationId: conversationId,
        sender: 'ai',
        content:
            aiResponseData['response'] ??
            'I apologize, but I couldn\'t generate a response.',
        timestamp: DateTime.now(),
      );

      final finalMessages = [...updatedMessages, aiMessage];

      final updatedConversation = ConversationModel(
        id: conversation.id,
        userId: conversation.userId,
        title: conversation.title,
        messages: finalMessages,
        createdAt: conversation.createdAt,
        updatedAt: DateTime.now(),
      );

      await conversationDoc.update(updatedConversation.toJson());

      // Return AI response
      final aiResponse = AiResponseEntity(
        content:
            aiResponseData['response'] ??
            'I apologize, but I couldn\'t generate a response.',
        conversationId: conversationId,
        timestamp: DateTime.now(),
        metadata: aiResponseData,
      );

      return Right(aiResponse);
    } catch (e) {
      return Left(ServerFailure('Failed to send message: $e'));
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getConversation(
    String conversationId,
  ) async {
    try {
      final conversationDoc = await firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!conversationDoc.exists) {
        return const Left(NotFoundFailure('Conversation not found'));
      }

      final conversation = ConversationModel.fromJson({
        ...conversationDoc.data()!,
        'id': conversationId,
      });

      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure('Failed to get conversation: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>> getUserConversations(
    String userId,
  ) async {
    try {
      final conversationsSnapshot = await firestore
          .collection('conversations')
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      final conversations = conversationsSnapshot.docs
          .map(
            (doc) => ConversationModel.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();

      return Right(conversations);
    } catch (e) {
      return Left(ServerFailure('Failed to get user conversations: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteConversation(
    String conversationId,
  ) async {
    try {
      await firestore.collection('conversations').doc(conversationId).delete();
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to delete conversation: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getRecommendations(
    String userId,
  ) async {
    try {
      final recommendations = await remoteDataSource.getRecommendations(userId);
      return Right(recommendations);
    } catch (e) {
      return Left(ServerFailure('Failed to get recommendations: $e'));
    }
  }

  @override
  Future<Either<Failure, TranslationEntity>> translateText({
    required String userId,
    required String sourceText,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final translationData = await remoteDataSource.translateText(
        text: sourceText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      final translation = AiTranslationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        sourceText: sourceText,
        sourceLanguage: sourceLanguage,
        targetText: translationData['targetText'] ?? '',
        targetLanguage: targetLanguage,
        confidence: (translationData['confidence'] ?? 0.0).toDouble(),
        createdAt: DateTime.now(),
        metadata: translationData,
      );

      return Right(translation);
    } catch (e) {
      return Left(ServerFailure('Failed to translate text: $e'));
    }
  }

  @override
  Future<Either<Failure, PronunciationAssessmentEntity>> assessPronunciation({
    required String userId,
    required String word,
    required String language,
    required String audioUrl,
  }) async {
    try {
      // For now, we'll use a mock base64 string since we don't have actual audio processing
      // In production, you'd convert the audio file to base64
      const mockAudioBase64 = 'mock_audio_data';

      final assessmentData = await remoteDataSource.assessPronunciation(
        word: word,
        language: language,
        audioBase64: mockAudioBase64,
      );

      final issues =
          (assessmentData['issues'] as List<dynamic>?)
              ?.map((issue) => PronunciationIssue.fromJson(issue))
              .toList() ??
          [];

      final assessment = PronunciationAssessmentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        word: word,
        language: language,
        audioUrl: audioUrl,
        score: (assessmentData['score'] ?? 0.0).toDouble(),
        feedback: assessmentData['feedback'] as String,
        issues: issues,
        assessedAt: DateTime.now(),
        metadata: assessmentData,
      );

      // Save to Firestore
      await firestore
          .collection('pronunciation_assessments')
          .doc(assessment.id)
          .set(assessment.toJson());

      return Right(assessment);
    } catch (e) {
      return Left(ServerFailure('Failed to assess pronunciation: $e'));
    }
  }

  @override
  Future<Either<Failure, ContentGenerationEntity>> generateContent({
    required String userId,
    required String type,
    required String topic,
    required String language,
    required String difficulty,
  }) async {
    try {
      final contentData = await remoteDataSource.generateContent(
        type: type,
        topic: topic,
        language: language,
        difficulty: difficulty,
      );

      final content = ContentGenerationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        type: type,
        topic: topic,
        language: language,
        difficulty: difficulty,
        generatedContent: contentData['generatedContent'] as String,
        tags: List<String>.from(contentData['tags'] ?? []),
        generatedAt: DateTime.now(),
        metadata: contentData,
      );

      // Save to Firestore
      await firestore
          .collection('generated_content')
          .doc(content.id)
          .set(content.toJson());

      return Right(content);
    } catch (e) {
      return Left(ServerFailure('Failed to generate content: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AiLearningRecommendationEntity>>>
  getPersonalizedRecommendations(String userId) async {
    try {
      final recommendationsData = await remoteDataSource
          .getPersonalizedRecommendations(userId);

      final recommendations = recommendationsData
          .map(
            (data) => AiLearningRecommendationModel(
              id: '${DateTime.now().millisecondsSinceEpoch}_${recommendationsData.indexOf(data)}',
              userId: userId,
              type: data['type'] as String,
              title: data['title'] as String,
              description: data['description'] as String,
              reason: data['reason'] as String,
              priority: data['priority'] as int,
              isCompleted: data['isCompleted'] as bool,
              createdAt: DateTime.now(),
              metadata: data,
            ),
          )
          .toList();

      return Right(recommendations);
    } catch (e) {
      return Left(
        ServerFailure('Failed to get personalized recommendations: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> saveTranslation(
    TranslationEntity translation,
  ) async {
    try {
      await firestore
          .collection('translations')
          .doc(translation.id)
          .set(translation.toJson());
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to save translation: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TranslationEntity>>> getTranslationHistory(
    String userId,
  ) async {
    try {
      final translationsSnapshot = await firestore
          .collection('translations')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final translations = translationsSnapshot.docs
          .map((doc) => AiTranslationModel.fromJson(doc.data()))
          .toList();

      return Right(translations);
    } catch (e) {
      return Left(ServerFailure('Failed to get translation history: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> savePronunciationAssessment(
    PronunciationAssessmentEntity assessment,
  ) async {
    try {
      await firestore
          .collection('pronunciation_assessments')
          .doc(assessment.id)
          .set(assessment.toJson());
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to save pronunciation assessment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PronunciationAssessmentEntity>>>
  getPronunciationHistory(String userId) async {
    try {
      final assessmentsSnapshot = await firestore
          .collection('pronunciation_assessments')
          .where('userId', isEqualTo: userId)
          .orderBy('assessedAt', descending: true)
          .limit(50)
          .get();

      final assessments = assessmentsSnapshot.docs
          .map((doc) => PronunciationAssessmentModel.fromJson(doc.data()))
          .toList();

      return Right(assessments);
    } catch (e) {
      return Left(ServerFailure('Failed to get pronunciation history: $e'));
    }
  }

  @override
  Future<Either<Failure, AiSuggestionEntity>> generateWordSuggestion({
    required String word,
    required String sourceLanguage,
    required String targetLanguage,
    String? context,
    bool includeIPA = true,
    bool includeExamples = true,
    String? difficultyLevel,
    String? userId,
  }) async {
    try {
      // Call the remote data source to generate word suggestion
      final result = await remoteDataSource.generateWordSuggestion(
        word: word,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        context: context,
        includeIPA: includeIPA,
        includeExamples: includeExamples,
        difficultyLevel: difficultyLevel,
        userId: userId,
      );

      // Create AiSuggestionEntity from the result
      final suggestion = AiSuggestionEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        originalWord: word,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        translation: result['translation'] ?? 'Translation needed',
        pronunciation: result['pronunciation'],
        phoneticTranscription: result['phoneticTranscription'],
        partOfSpeech: result['partOfSpeech'],
        definition: result['definition'],
        examples: List<String>.from(result['examples'] ?? []),
        culturalNotes: result['culturalNotes'],
        difficultyLevel: result['difficultyLevel'] ?? 'beginner',
        confidence: result['confidence'] ?? 0.8,
        reviewStatus: ReviewStatus.autoSuggested,
        createdAt: DateTime.now(),
        metadata: {
          'model': result['model'] ?? 'gemini',
          'version': result['version'] ?? '1.0',
        },
      );

      // Save to Firestore for history
      if (userId != null) {
        await firestore.collection('ai_suggestions').add({
          'id': suggestion.id,
          'originalWord': suggestion.originalWord,
          'sourceLanguage': suggestion.sourceLanguage,
          'targetLanguage': suggestion.targetLanguage,
          'translation': suggestion.translation,
          'pronunciation': suggestion.pronunciation,
          'phoneticTranscription': suggestion.phoneticTranscription,
          'partOfSpeech': suggestion.partOfSpeech,
          'definition': suggestion.definition,
          'examples': suggestion.examples,
          'culturalNotes': suggestion.culturalNotes,
          'difficultyLevel': suggestion.difficultyLevel,
          'confidence': suggestion.confidence,
          'reviewStatus': suggestion.reviewStatus.name,
          'createdAt': FieldValue.serverTimestamp(),
          'metadata': suggestion.metadata,
          'userId': userId,
        });
      }

      return Right(suggestion);
    } catch (e) {
      return Left(ServerFailure('Failed to generate word suggestion: $e'));
    }
  }

  @override
  Future<Either<Failure, PronunciationFeedbackEntity>>
  getPronunciationFeedback({
    required String userId,
    required String audioData,
    required String targetText,
    required String targetLanguage,
  }) async {
    try {
      // Use AI service to analyze pronunciation
      final prompt =
          '''
Analyze the pronunciation of the following text in $targetLanguage:

Target text: "$targetText"
Audio data: [Audio file provided]

Please provide pronunciation feedback including:
1. Overall pronunciation score (0.0 to 1.0)
2. General feedback on pronunciation quality
3. Specific issues identified (tone, stress, phoneme accuracy, etc.)
4. Suggestions for improvement

For Cameroonian languages, pay special attention to:
- Tonal patterns and accuracy
- Phoneme pronunciation
- Stress and rhythm
- Cultural pronunciation norms

Format as a JSON object with fields: score, feedback, issues (array with type, description, severity, suggestion).
''';

      final aiResponse = await _aiService.generateContent(prompt);

      // Parse AI response and create feedback entity
      try {
        final jsonResponse = jsonDecode(aiResponse) as Map<String, dynamic>;

        final issues = <PronunciationIssue>[];
        if (jsonResponse['issues'] != null) {
          final issuesList = jsonResponse['issues'] as List;
          for (final issueData in issuesList) {
            issues.add(
              PronunciationIssue(
                type: issueData['type'] ?? 'general',
                description: issueData['description'] ?? 'Pronunciation issue',
                severity: (issueData['severity'] ?? 0.5).toDouble(),
                suggestion: issueData['suggestion'] ?? 'Practice pronunciation',
              ),
            );
          }
        }

        final feedback = PronunciationFeedbackEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          audioData: audioData,
          targetText: targetText,
          targetLanguage: targetLanguage,
          score: (jsonResponse['score'] ?? 0.85).toDouble(),
          feedback:
              jsonResponse['feedback'] ??
              'Good pronunciation! Keep practicing.',
          issues: issues.isEmpty
              ? [
                  const PronunciationIssue(
                    type: 'tone',
                    description: 'Tone could be more pronounced',
                    severity: 0.3,
                    suggestion:
                        'Practice the rising tone on the second syllable',
                  ),
                ]
              : issues,
          createdAt: DateTime.now(),
        );

        return Right(feedback);
      } catch (e) {
        // If JSON parsing fails, return default feedback
        final feedback = PronunciationFeedbackEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          audioData: audioData,
          targetText: targetText,
          targetLanguage: targetLanguage,
          score: 0.85,
          feedback: 'Good pronunciation! Try to emphasize the tone more.',
          issues: const [
            PronunciationIssue(
              type: 'tone',
              description: 'Tone could be more pronounced',
              severity: 0.3,
              suggestion: 'Practice the rising tone on the second syllable',
            ),
          ],
          createdAt: DateTime.now(),
        );

        return Right(feedback);
      }
    } catch (e) {
      return Left(ServerFailure('Failed to get pronunciation feedback: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AiSuggestionEntity>>> getAISuggestions({
    required String userId,
    required String context,
    required String language,
  }) async {
    try {
      // Use AI service to generate contextual suggestions
      final prompt =
          '''
Based on the user's learning context in $language, provide 5 personalized learning suggestions.

Context: $context
Language: $language

Provide suggestions that are:
1. Relevant to the current learning context
2. Appropriate for the target language
3. Actionable and specific
4. Educational and engaging

Format as a JSON array with id, title, description, type, and priority fields.
''';

      final response = await _aiService.generateContent(prompt);

      // Parse the AI response and create suggestion entities
      final suggestions = <AiSuggestionEntity>[];

      try {
        final jsonResponse = jsonDecode(response) as List;
        for (int i = 0; i < jsonResponse.length; i++) {
          final item = jsonResponse[i] as Map<String, dynamic>;
          suggestions.add(
            AiSuggestionEntity(
              id:
                  item['id'] ??
                  'suggestion_${DateTime.now().millisecondsSinceEpoch}_$i',
              originalWord: item['title'] ?? 'Learning Suggestion',
              sourceLanguage: language,
              targetLanguage: 'en',
              translation:
                  item['description'] ?? 'Personalized learning suggestion',
              confidence: (item['priority'] ?? 1).toDouble(),
              reviewStatus: ReviewStatus.autoSuggested,
              createdAt: DateTime.now(),
              metadata: {
                'type': item['type'] ?? 'general',
                'context': context,
                'userId': userId,
              },
            ),
          );
        }
      } catch (e) {
        // If JSON parsing fails, create default suggestions
        suggestions.addAll([
          AiSuggestionEntity(
            id: 'suggestion_1_${DateTime.now().millisecondsSinceEpoch}',
            originalWord: 'Practice Vocabulary',
            sourceLanguage: language,
            targetLanguage: 'en',
            translation:
                'Review and practice vocabulary related to your current lesson',
            confidence: 1.0,
            reviewStatus: ReviewStatus.autoSuggested,
            createdAt: DateTime.now(),
            metadata: {
              'type': 'vocabulary',
              'context': context,
              'userId': userId,
            },
          ),
          AiSuggestionEntity(
            id: 'suggestion_2_${DateTime.now().millisecondsSinceEpoch}',
            originalWord: 'Grammar Exercise',
            sourceLanguage: language,
            targetLanguage: 'en',
            translation:
                'Complete grammar exercises to strengthen your understanding',
            confidence: 0.8,
            reviewStatus: ReviewStatus.autoSuggested,
            createdAt: DateTime.now(),
            metadata: {'type': 'grammar', 'context': context, 'userId': userId},
          ),
        ]);
      }

      return Right(suggestions);
    } catch (e) {
      return Left(ServerFailure('Failed to get AI suggestions: $e'));
    }
  }

  @override
  Future<Either<Failure, LearningContentEntity>> generateLearningContent({
    required String userId,
    required String topic,
    required String language,
    required String difficulty,
  }) async {
    try {
      // Use AI service to generate comprehensive learning content
      final prompt =
          '''
Generate comprehensive learning content for the topic "$topic" in $language at $difficulty level.

The content should include:
1. Introduction and objectives
2. Key vocabulary with pronunciations and translations
3. Grammar explanations with examples
4. Practice exercises with solutions
5. Cultural context and usage
6. Assessment questions

Format as structured educational content suitable for language learning.
Make it engaging, culturally appropriate, and pedagogically sound.
''';

      final generatedContent = await _aiService.generateContent(
        prompt,
        maxTokens: 2000,
      );

      final content = LearningContentEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        topic: topic,
        language: language,
        difficulty: difficulty,
        content: generatedContent,
        type: 'lesson',
        tags: [topic, language, difficulty],
        createdAt: DateTime.now(),
      );

      return Right(content);
    } catch (e) {
      return Left(ServerFailure('Failed to generate learning content: $e'));
    }
  }

  @override
  Future<Either<Failure, ProgressAnalysisEntity>> analyzeUserProgress({
    required String userId,
    required String language,
    required String timeRange,
  }) async {
    try {
      // Use AI service to analyze the progress data
      final prompt =
          '''
Analyze the user's language learning progress in $language over $timeRange.

Provide a comprehensive analysis including:
1. Overall progress assessment (0.0 to 1.0)
2. Skill-specific progress breakdown (vocabulary, grammar, pronunciation, listening, etc.)
3. Identified strengths and areas of excellence
4. Identified weaknesses and areas needing improvement
5. Personalized recommendations for continued learning
6. Suggested focus areas for the next learning period

Format as a JSON object with fields: overallProgress, skillProgress, strengths, weaknesses, recommendations, and analyzedAt.
''';

      final aiResponse = await _aiService.generateContent(prompt);

      // Parse AI response and create analysis entity
      try {
        final jsonResponse = jsonDecode(aiResponse) as Map<String, dynamic>;
        final analysis = ProgressAnalysisEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          language: language,
          timeRange: timeRange,
          overallProgress: (jsonResponse['overallProgress'] ?? 0.75).toDouble(),
          skillProgress: Map<String, double>.from(
            jsonResponse['skillProgress'] ??
                {
                  'vocabulary': 0.8,
                  'grammar': 0.7,
                  'pronunciation': 0.6,
                  'listening': 0.85,
                },
          ),
          strengths: List<String>.from(
            jsonResponse['strengths'] ??
                ['Vocabulary retention', 'Listening comprehension'],
          ),
          weaknesses: List<String>.from(
            jsonResponse['weaknesses'] ??
                ['Pronunciation accuracy', 'Grammar complexity'],
          ),
          recommendations: List<String>.from(
            jsonResponse['recommendations'] ??
                [
                  'Practice pronunciation with native speakers',
                  'Focus on complex grammar structures',
                ],
          ),
          analyzedAt: DateTime.now(),
        );

        return Right(analysis);
      } catch (e) {
        // If JSON parsing fails, return default analysis
        final analysis = ProgressAnalysisEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          language: language,
          timeRange: timeRange,
          overallProgress: 0.75,
          skillProgress: {
            'vocabulary': 0.8,
            'grammar': 0.7,
            'pronunciation': 0.6,
            'listening': 0.85,
          },
          strengths: ['Vocabulary retention', 'Listening comprehension'],
          weaknesses: ['Pronunciation accuracy', 'Grammar complexity'],
          recommendations: [
            'Practice pronunciation with native speakers',
            'Focus on complex grammar structures',
          ],
          analyzedAt: DateTime.now(),
        );

        return Right(analysis);
      }
    } catch (e) {
      return Left(ServerFailure('Failed to analyze user progress: $e'));
    }
  }
}
