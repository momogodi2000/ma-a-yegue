import '../../domain/entities/level_assessment_entity.dart';
import '../../domain/repositories/level_assessment_repository.dart';
import '../../../../core/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LevelAssessmentRepositoryImpl implements LevelAssessmentRepository {
  final FirebaseService firebaseService;

  LevelAssessmentRepositoryImpl(this.firebaseService);

  @override
  Future<LevelAssessmentEntity> startLevelAssessment({
    required String userId,
    required String languageCode,
    required String currentLevel,
    required String targetLevel,
  }) async {
    final assessmentId = firebaseService.firestore.collection('assessments').doc().id;
    
    // Get questions for the assessment
    final questions = await getAssessmentQuestions(
      languageCode: languageCode,
      level: targetLevel,
      questionCount: 10,
    );

    final assessment = LevelAssessmentEntity(
      id: assessmentId,
      userId: userId,
      languageCode: languageCode,
      currentLevel: currentLevel,
      targetLevel: targetLevel,
      questions: questions,
      startedAt: DateTime.now(),
    );

    // Save to Firestore
    await firebaseService.firestore
        .collection('assessments')
        .doc(assessmentId)
        .set({
      'id': assessment.id,
      'userId': assessment.userId,
      'languageCode': assessment.languageCode,
      'currentLevel': assessment.currentLevel,
      'targetLevel': assessment.targetLevel,
      'startedAt': Timestamp.fromDate(assessment.startedAt),
      'isCompleted': false,
      'questionIds': questions.map((q) => q.id).toList(),
    });

    return assessment;
  }

  @override
  Future<List<AssessmentQuestionEntity>> getAssessmentQuestions({
    required String languageCode,
    required String level,
    required int questionCount,
  }) async {
    // For now, generate default questions based on level
    return _generateDefaultQuestions(languageCode, level, questionCount);
  }

  @override
  Future<void> submitAnswer({
    required String assessmentId,
    required String questionId,
    required String answer,
  }) async {
    await firebaseService.firestore
        .collection('assessments')
        .doc(assessmentId)
        .collection('answers')
        .doc(questionId)
        .set({
      'questionId': questionId,
      'userAnswer': answer,
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<AssessmentResult> completeAssessment(String assessmentId) async {
    // Get all answers for this assessment
    final answersSnapshot = await firebaseService.firestore
        .collection('assessments')
        .doc(assessmentId)
        .collection('answers')
        .get();

    // Get the original assessment
    final assessmentDoc = await firebaseService.firestore
        .collection('assessments')
        .doc(assessmentId)
        .get();

    if (!assessmentDoc.exists) {
      throw Exception('Assessment not found');
    }

    final assessmentData = assessmentDoc.data()!;
    final languageCode = assessmentData['languageCode'] as String;
    final targetLevel = assessmentData['targetLevel'] as String;

    // Get questions to calculate score
    final questions = await getAssessmentQuestions(
      languageCode: languageCode,
      level: targetLevel,
      questionCount: 10,
    );

    // Calculate score
    double totalScore = 0;
    double maxScore = 0;
    List<String> strengths = [];
    List<String> weaknesses = [];

    for (final question in questions) {
      maxScore += question.points;
      final answerDoc = answersSnapshot.docs
          .where((doc) => doc.data()['questionId'] == question.id)
          .firstOrNull;
      
      if (answerDoc != null) {
        final userAnswer = answerDoc.data()['userAnswer'] as String;
        if (userAnswer.toLowerCase().trim() == question.correctAnswer.toLowerCase().trim()) {
          totalScore += question.points;
          if (question.type == 'translation') {
            strengths.add('Translation skills');
          } else if (question.type == 'multiple_choice') {
            strengths.add('Vocabulary recognition');
          }
        } else {
          if (question.type == 'translation') {
            weaknesses.add('Translation accuracy');
          } else if (question.type == 'multiple_choice') {
            weaknesses.add('Vocabulary knowledge');
          }
        }
      } else {
        weaknesses.add('Question completion');
      }
    }

    final percentage = (totalScore / maxScore) * 100;
    final levelPassed = percentage >= 70.0; // 70% to pass to next level
    final recommendedLevel = levelPassed ? targetLevel : assessmentData['currentLevel'] as String;

    final result = AssessmentResult(
      totalScore: totalScore,
      percentage: percentage,
      recommendedLevel: recommendedLevel,
      levelPassed: levelPassed,
      strengths: strengths.toSet().toList(),
      weaknesses: weaknesses.toSet().toList(),
      feedback: _generateFeedback(percentage, levelPassed),
    );

    // Update assessment in Firestore
    await firebaseService.firestore
        .collection('assessments')
        .doc(assessmentId)
        .update({
      'completedAt': FieldValue.serverTimestamp(),
      'isCompleted': true,
      'score': totalScore,
      'percentage': percentage,
      'levelPassed': levelPassed,
      'recommendedLevel': recommendedLevel,
    });

    // Update user level if they passed
    if (levelPassed) {
      await updateUserLevel(
        userId: assessmentData['userId'] as String,
        languageCode: languageCode,
        newLevel: targetLevel,
      );
    }

    return result;
  }

  @override
  Future<List<LevelAssessmentEntity>> getUserAssessmentHistory(String userId) async {
    final querySnapshot = await firebaseService.firestore
        .collection('assessments')
        .where('userId', isEqualTo: userId)
        .orderBy('startedAt', descending: true)
        .get();

    List<LevelAssessmentEntity> assessments = [];
    
    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      assessments.add(LevelAssessmentEntity(
        id: data['id'],
        userId: data['userId'],
        languageCode: data['languageCode'],
        currentLevel: data['currentLevel'],
        targetLevel: data['targetLevel'],
        questions: [], // Don't load questions for history view
        startedAt: (data['startedAt'] as Timestamp).toDate(),
        completedAt: data['completedAt'] != null ? (data['completedAt'] as Timestamp).toDate() : null,
        score: data['score']?.toDouble(),
        isCompleted: data['isCompleted'] ?? false,
      ));
    }

    return assessments;
  }

  @override
  Future<String> getCurrentUserLevel({
    required String userId,
    required String languageCode,
  }) async {
    final userDoc = await firebaseService.firestore
        .collection('users')
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      return 'beginner'; // Default level
    }

    final userData = userDoc.data()!;
    final levels = userData['languageLevels'] as Map<String, dynamic>?;
    
    return levels?[languageCode] ?? 'beginner';
  }

  @override
  Future<void> updateUserLevel({
    required String userId,
    required String languageCode,
    required String newLevel,
  }) async {
    await firebaseService.firestore
        .collection('users')
        .doc(userId)
        .update({
      'languageLevels.$languageCode': newLevel,
      'lastLevelUpdate': FieldValue.serverTimestamp(),
    });
  }

  List<AssessmentQuestionEntity> _generateDefaultQuestions(String languageCode, String level, int count) {
    // Generate default questions based on language and level
    List<AssessmentQuestionEntity> questions = [];
    
    for (int i = 0; i < count; i++) {
      questions.add(AssessmentQuestionEntity(
        id: 'q_${i + 1}',
        type: i % 2 == 0 ? 'multiple_choice' : 'translation',
        question: _getQuestionForLanguageAndLevel(languageCode, level, i),
        options: _getOptionsForQuestion(languageCode, level, i),
        correctAnswer: _getCorrectAnswer(languageCode, level, i),
        points: level == 'beginner' ? 5 : level == 'intermediate' ? 7 : 10,
        difficulty: level,
      ));
    }

    return questions;
  }

  String _getQuestionForLanguageAndLevel(String languageCode, String level, int index) {
    // Basic questions for different languages and levels
    final Map<String, Map<String, List<String>>> questions = {
      'ewondo': {
        'beginner': [
          'Que signifie "Mbolo" en français ?',
          'Comment dit-on "merci" en Ewondo ?',
          'Traduisez "Je mange" en Ewondo',
          'Que veut dire "Wom" ?',
          'Comment salue-t-on le matin en Ewondo ?',
        ],
        'intermediate': [
          'Conjuguez le verbe "être" en Ewondo',
          'Traduisez la phrase: "Je vais au marché"',
          'Que signifie "A ke di mba" ?',
          'Comment exprime-t-on le futur en Ewondo ?',
          'Traduisez: "Ma famille est grande"',
        ],
        'advanced': [
          'Expliquez la différence entre "nlo" et "nloa"',
          'Traduisez: "Si j\'avais su, je serais venu"',
          'Analysez la structure de: "Me ke di mba"',
          'Comment exprime-t-on le conditionnel ?',
          'Traduisez un proverbe ewondo au choix',
        ],
      },
    };

    final languageQuestions = questions[languageCode]?[level] ?? questions['ewondo']!['beginner']!;
    return languageQuestions[index % languageQuestions.length];
  }

  List<String> _getOptionsForQuestion(String languageCode, String level, int index) {
    // Return options for multiple choice questions
    if (index % 2 == 0) { // Multiple choice
      final Map<String, Map<String, List<List<String>>>> options = {
        'ewondo': {
          'beginner': [
            ['Bonjour', 'Au revoir', 'Bonsoir', 'Merci'],
            ['Merci', 'Pardon', 'Bonjour', 'Au revoir'],
            ['Ma di', 'Ma ke', 'Ma ne', 'Ma do'],
            ['Eau', 'Feu', 'Terre', 'Air'],
            ['Mbolo', 'Ngul meki', 'Jam', 'Wom'],
          ],
        },
      };
      
      final languageOptions = options[languageCode]?[level] ?? options['ewondo']!['beginner']!;
      return languageOptions[index ~/ 2 % languageOptions.length];
    }
    return [];
  }

  String _getCorrectAnswer(String languageCode, String level, int index) {
    // Return correct answers
    final Map<String, Map<String, List<String>>> answers = {
      'ewondo': {
        'beginner': [
          'Bonjour',
          'Akiba',
          'Ma di',
          'Eau',
          'Mbolo',
          'Ma ke di mba',
          'Je vais au marché',
          'A ke di mba',
          'Ma ke + verbe',
          'Nlo ma ma nkukuma',
        ],
      },
    };

    final languageAnswers = answers[languageCode]?[level] ?? answers['ewondo']!['beginner']!;
    return languageAnswers[index % languageAnswers.length];
  }

  String _generateFeedback(double percentage, bool passed) {
    if (percentage >= 90) {
      return 'Excellent! Vous maîtrisez très bien ce niveau.';
    } else if (percentage >= 80) {
      return 'Très bien! Vous êtes prêt pour le niveau suivant.';
    } else if (percentage >= 70) {
      return 'Bien! Vous pouvez passer au niveau suivant avec un peu plus de pratique.';
    } else if (percentage >= 60) {
      return 'Pas mal, mais vous devriez réviser certains points avant de passer au niveau suivant.';
    } else {
      return 'Il faut encore travailler ce niveau. Ne vous découragez pas, continuez à pratiquer!';
    }
  }
}