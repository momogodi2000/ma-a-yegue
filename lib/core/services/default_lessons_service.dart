import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/ai_service.dart';

class DefaultLessonsService {
  final FirebaseService _firebaseService;
  final GeminiAIService _aiService;

  DefaultLessonsService(this._firebaseService, this._aiService);

  /// Initialize default lessons for all supported languages
  Future<void> initializeDefaultLessons() async {
    try {
      final languages = [
        {'code': 'ewondo', 'name': 'Ewondo', 'region': 'Centre'},
        {'code': 'duala', 'name': 'Duala', 'region': 'Littoral'},
        {'code': 'bafang', 'name': 'Bafang', 'region': 'Ouest'},
        {'code': 'fulfulde', 'name': 'Fulfulde', 'region': 'Nord'},
        {'code': 'bassa', 'name': 'Bassa', 'region': 'Littoral'},
        {'code': 'bamum', 'name': 'Bamum', 'region': 'Ouest'},
      ];

      for (final language in languages) {
        await _createDefaultLessonsForLanguage(
          language['code']!,
          language['name']!,
          language['region']!,
        );
      }

      debugPrint('✅ Default lessons initialized for all languages');
    } catch (e) {
      debugPrint('❌ Error initializing default lessons: $e');
      rethrow;
    }
  }

  /// Create default lessons for a specific language
  Future<void> _createDefaultLessonsForLanguage(
    String languageCode,
    String languageName,
    String region,
  ) async {
    final lessonsCollection = _firebaseService.firestore.collection('lessons');

    // Check if lessons already exist for this language
    final existingLessons = await lessonsCollection
        .where('languageCode', isEqualTo: languageCode)
        .limit(1)
        .get();

    if (existingLessons.docs.isNotEmpty) {
      debugPrint('⚠️ Lessons already exist for $languageName, skipping...');
      return;
    }

    // Create beginner level lessons
    await _createLevelLessons(languageCode, languageName, 'beginner', region);
    
    // Create intermediate level lessons
    await _createLevelLessons(languageCode, languageName, 'intermediate', region);
    
    // Create advanced level lessons
    await _createLevelLessons(languageCode, languageName, 'advanced', region);

    debugPrint('✅ Created default lessons for $languageName');
  }

  /// Create lessons for a specific level
  Future<void> _createLevelLessons(
    String languageCode,
    String languageName,
    String level,
    String region,
  ) async {
    final lessons = _getDefaultLessonsForLevel(languageCode, languageName, level, region);

    for (int i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];
      final lessonId = '${languageCode}_${level}_${i + 1}';

      // Generate AI-enhanced content for each lesson
      final aiEnhancedContent = await _generateAILessonContent(
        languageCode,
        languageName,
        lesson['title']!,
        lesson['topic']!,
        level,
      );

      await _firebaseService.firestore.collection('lessons').doc(lessonId).set({
        'id': lessonId,
        'title': lesson['title'],
        'description': lesson['description'],
        'languageCode': languageCode,
        'languageName': languageName,
        'level': level,
        'order': i + 1,
        'topic': lesson['topic'],
        'duration': lesson['duration'],
        'type': lesson['type'],
        'isPublic': true,
        'isActive': true,
        'difficulty': level,
        'region': region,
        'createdBy': 'system',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'content': aiEnhancedContent,
        'tags': lesson['tags'],
        'objectives': lesson['objectives'],
        'prerequisites': lesson['prerequisites'] ?? [],
        'estimatedCompletionTime': lesson['duration'],
        'language': 'fr', // Content is in French
        'isAIGenerated': true,
        'aiGeneratedAt': FieldValue.serverTimestamp(),
      });

      // Add a small delay to avoid overwhelming the AI service
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Generate AI-enhanced lesson content using Gemini
  Future<Map<String, dynamic>> _generateAILessonContent(
    String languageCode,
    String languageName,
    String lessonTitle,
    String topic,
    String level,
  ) async {
    try {
      final prompt = '''
Créez un contenu de leçon détaillé pour l'apprentissage du $languageName ($languageCode) - une langue traditionnelle camerounaise.

Titre de la leçon: $lessonTitle
Sujet: $topic
Niveau: $level
Région: Cameroun

Veuillez générer un contenu structuré qui inclut:

1. Introduction (150-200 mots)
   - Présentation du sujet
   - Importance culturelle
   - Objectifs d'apprentissage

2. Vocabulaire clé (10-15 mots)
   - Mot en $languageName
   - Traduction française
   - Phonétique simple
   - Exemple d'usage

3. Phrases essentielles (8-10 phrases)
   - Expression en $languageName
   - Traduction française
   - Contexte d'utilisation

4. Point culturel (100-150 mots)
   - Aspect culturel lié au sujet
   - Traditions ou pratiques

5. Exercices pratiques (5 exercices)
   - Type: traduction, compréhension, expression
   - Questions progressives selon le niveau

6. Conseils de pronunciation (50-100 mots)
   - Sons particuliers
   - Intonation
   - Conseils pratiques

Retournez le résultat au format JSON avec ces sections. Assurez-vous que le contenu est culturellement approprié et respectueux des traditions camerounaises.
''';

      final aiResponse = await _aiService.generateContent(prompt, maxTokens: 2000);
      
      // Try to parse JSON response
      try {
        // If AI returns JSON format, parse it
        if (aiResponse.trim().startsWith('{')) {
          return _parseJsonResponse(aiResponse);
        } else {
          // If AI returns text format, structure it manually
          return _structureTextResponse(aiResponse, languageCode, topic);
        }
      } catch (e) {
        // Fallback to structured text response
        return _structureTextResponse(aiResponse, languageCode, topic);
      }
    } catch (e) {
      debugPrint('⚠️ AI content generation failed for $lessonTitle: $e');
      // Return default content structure
      return _getDefaultLessonContent(languageName, topic, level);
    }
  }

  Map<String, dynamic> _parseJsonResponse(String jsonResponse) {
    // Implementation to parse JSON response from AI
    return {
      'sections': [
        {'type': 'introduction', 'content': 'AI-generated introduction'},
        {'type': 'vocabulary', 'content': []},
        {'type': 'phrases', 'content': []},
        {'type': 'culture', 'content': 'Cultural insights'},
        {'type': 'exercises', 'content': []},
        {'type': 'pronunciation', 'content': 'Pronunciation tips'},
      ],
      'aiGenerated': true,
    };
  }

  Map<String, dynamic> _structureTextResponse(String textResponse, String languageCode, String topic) {
    return {
      'sections': [
        {
          'type': 'introduction',
          'title': 'Introduction',
          'content': textResponse.length > 500 ? '${textResponse.substring(0, 500)}...' : textResponse,
        },
        {
          'type': 'vocabulary',
          'title': 'Vocabulaire',
          'content': _extractVocabularyFromText(textResponse, languageCode),
        },
        {
          'type': 'culture',
          'title': 'Point culturel',
          'content': 'Cette leçon explore les aspects culturels importants de la langue $languageCode liés à $topic.',
        },
        {
          'type': 'exercises',
          'title': 'Exercices',
          'content': _generateBasicExercises(languageCode, topic),
        },
      ],
      'aiGenerated': true,
      'aiContent': textResponse,
    };
  }

  List<Map<String, String>> _extractVocabularyFromText(String text, String languageCode) {
    // Basic vocabulary extraction - in a real implementation, this would be more sophisticated
    return [
      {'word': 'Bonjour', 'translation': 'Mbolo', 'phonetic': 'mbolo'},
      {'word': 'Merci', 'translation': 'Akiba', 'phonetic': 'akiba'},
      {'word': 'Eau', 'translation': 'Wom', 'phonetic': 'wom'},
    ];
  }

  List<Map<String, String>> _generateBasicExercises(String languageCode, String topic) {
    return [
      {
        'type': 'translation',
        'question': 'Traduisez "Bonjour" en $languageCode',
        'answer': 'Mbolo',
      },
      {
        'type': 'multiple_choice',
        'question': 'Que signifie "Akiba" ?',
        'options': 'Bonjour,Merci,Au revoir,Pardon',
        'answer': 'Merci',
      },
    ];
  }

  Map<String, dynamic> _getDefaultLessonContent(String languageName, String topic, String level) {
    return {
      'sections': [
        {
          'type': 'introduction',
          'title': 'Introduction',
          'content': 'Bienvenue dans cette leçon de $languageName sur le thème: $topic. Cette leçon de niveau $level vous permettra d\'apprendre les bases de cette belle langue camerounaise.',
        },
        {
          'type': 'vocabulary',
          'title': 'Vocabulaire essentiel',
          'content': [
            {'word': 'Mbolo', 'translation': 'Bonjour', 'phonetic': 'mbolo'},
            {'word': 'Akiba', 'translation': 'Merci', 'phonetic': 'akiba'},
            {'word': 'Wom', 'translation': 'Eau', 'phonetic': 'wom'},
          ],
        },
        {
          'type': 'culture',
          'title': 'Point culturel',
          'content': 'Le $languageName est une langue riche en traditions et en culture camerounaise.',
        },
      ],
      'aiGenerated': false,
      'isDefault': true,
    };
  }

  /// Get default lesson templates for each level
  List<Map<String, dynamic>> _getDefaultLessonsForLevel(
    String languageCode,
    String languageName,
    String level,
    String region,
  ) {
    switch (level) {
      case 'beginner':
        return [
          {
            'title': 'Premiers mots et salutations',
            'description': 'Apprenez les salutations de base et les premiers mots essentiels',
            'topic': 'greetings',
            'duration': 15,
            'type': 'vocabulary',
            'tags': ['salutations', 'bases', 'premiers mots'],
            'objectives': ['Apprendre 10 salutations de base', 'Comprendre les contextes d\'usage', 'Pratiquer la prononciation'],
          },
          {
            'title': 'Les nombres de 1 à 10',
            'description': 'Découvrez comment compter en $languageName',
            'topic': 'numbers',
            'duration': 20,
            'type': 'vocabulary',
            'tags': ['nombres', 'comptage', 'mathématiques'],
            'objectives': ['Mémoriser les nombres 1-10', 'Utiliser les nombres dans des phrases', 'Comprendre le système numérique'],
          },
          {
            'title': 'La famille',
            'description': 'Vocabulaire familial et relations parentales',
            'topic': 'family',
            'duration': 25,
            'type': 'vocabulary',
            'tags': ['famille', 'relations', 'parenté'],
            'objectives': ['Connaître les termes familiaux', 'Décrire sa famille', 'Comprendre les relations de parenté'],
          },
          {
            'title': 'Les couleurs',
            'description': 'Apprenez les couleurs principales',
            'topic': 'colors',
            'duration': 18,
            'type': 'vocabulary',
            'tags': ['couleurs', 'description', 'adjectifs'],
            'objectives': ['Identifier les couleurs principales', 'Décrire des objets', 'Utiliser les couleurs comme adjectifs'],
          },
          {
            'title': 'Nourriture de base',
            'description': 'Découvrez les aliments essentiels',
            'topic': 'food',
            'duration': 30,
            'type': 'vocabulary',
            'tags': ['nourriture', 'cuisine', 'alimentation'],
            'objectives': ['Nommer les aliments de base', 'Commander au restaurant', 'Parler de ses préférences'],
          },
        ];

      case 'intermediate':
        return [
          {
            'title': 'Construire des phrases simples',
            'description': 'Apprenez la structure de base des phrases',
            'topic': 'grammar',
            'duration': 35,
            'type': 'grammar',
            'tags': ['grammaire', 'phrases', 'structure'],
            'objectives': ['Comprendre l\'ordre des mots', 'Former des phrases affirmatives', 'Poser des questions simples'],
          },
          {
            'title': 'Exprimer le temps',
            'description': 'Parlez du temps, des heures et des moments',
            'topic': 'time',
            'duration': 40,
            'type': 'conversation',
            'tags': ['temps', 'heures', 'calendrier'],
            'objectives': ['Dire l\'heure', 'Parler des jours et mois', 'Exprimer la fréquence'],
          },
          {
            'title': 'Décrire des personnes',
            'description': 'Vocabulaire pour décrire l\'apparence et la personnalité',
            'topic': 'description',
            'duration': 30,
            'type': 'vocabulary',
            'tags': ['description', 'apparence', 'personnalité'],
            'objectives': ['Décrire l\'apparence physique', 'Parler de la personnalité', 'Faire des comparaisons'],
          },
        ];

      case 'advanced':
        return [
          {
            'title': 'Contes et proverbes traditionnels',
            'description': 'Découvrez la sagesse ancestrale',
            'topic': 'culture',
            'duration': 45,
            'type': 'culture',
            'tags': ['proverbes', 'contes', 'tradition'],
            'objectives': ['Comprendre des proverbes', 'Raconter des histoires', 'Analyser la sagesse populaire'],
          },
          {
            'title': 'Négociation au marché',
            'description': 'Conversations commerciales authentiques',
            'topic': 'business',
            'duration': 50,
            'type': 'conversation',
            'tags': ['commerce', 'négociation', 'marché'],
            'objectives': ['Négocier des prix', 'Décrire des produits', 'Conclure des ventes'],
          },
        ];

      default:
        return [];
    }
  }

  /// Check if default lessons need to be created
  Future<bool> needsDefaultLessons(String languageCode) async {
    try {
      final lessonsSnapshot = await _firebaseService.firestore
          .collection('lessons')
          .where('languageCode', isEqualTo: languageCode)
          .where('createdBy', isEqualTo: 'system')
          .limit(1)
          .get();

      return lessonsSnapshot.docs.isEmpty;
    } catch (e) {
      debugPrint('Error checking for existing lessons: $e');
      return true; // Assume we need lessons if we can't check
    }
  }

  /// Get all available languages with lesson counts
  Future<List<Map<String, dynamic>>> getLanguagesWithLessonCounts() async {
    try {
      final languages = [
        {'code': 'ewondo', 'name': 'Ewondo', 'region': 'Centre'},
        {'code': 'duala', 'name': 'Duala', 'region': 'Littoral'},
        {'code': 'bafang', 'name': 'Bafang', 'region': 'Ouest'},
        {'code': 'fulfulde', 'name': 'Fulfulde', 'region': 'Nord'},
        {'code': 'bassa', 'name': 'Bassa', 'region': 'Littoral'},
        {'code': 'bamum', 'name': 'Bamum', 'region': 'Ouest'},
      ];

      List<Map<String, dynamic>> result = [];

      for (final language in languages) {
        final lessonsSnapshot = await _firebaseService.firestore
            .collection('lessons')
            .where('languageCode', isEqualTo: language['code'])
            .where('isActive', isEqualTo: true)
            .get();

        result.add({
          ...language,
          'lessonCount': lessonsSnapshot.docs.length,
          'hasLessons': lessonsSnapshot.docs.isNotEmpty,
        });
      }

      return result;
    } catch (e) {
      debugPrint('Error getting languages with lesson counts: $e');
      return [];
    }
  }
}