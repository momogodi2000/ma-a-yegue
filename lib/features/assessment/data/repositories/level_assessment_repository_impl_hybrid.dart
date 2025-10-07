import '../../domain/entities/level_assessment_entity.dart';
import '../../domain/repositories/level_assessment_repository.dart';
import '../../../../core/database/unified_database_service.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';

class LevelAssessmentRepositoryImpl implements LevelAssessmentRepository {
  final UnifiedDatabaseService _db = UnifiedDatabaseService.instance;

  /// Initialize assessment tables
  Future<void> _initializeTables() async {
    final db = await _db.database;
    
    // Create assessments table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assessments (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        language_code TEXT NOT NULL,
        current_level TEXT NOT NULL,
        target_level TEXT NOT NULL,
        question_ids TEXT,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        is_completed INTEGER DEFAULT 0,
        score REAL,
        percentage REAL,
        level_passed INTEGER,
        recommended_level TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Create assessment_answers table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assessment_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        assessment_id TEXT NOT NULL,
        question_id TEXT NOT NULL,
        user_answer TEXT NOT NULL,
        submitted_at TEXT NOT NULL,
        FOREIGN KEY (assessment_id) REFERENCES assessments(id),
        UNIQUE(assessment_id, question_id)
      )
    ''');
    
    // Create indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_assessments_user ON assessments(user_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_assessments_language ON assessments(language_code)');
  }

  @override
  Future<LevelAssessmentEntity> startLevelAssessment({
    required String userId,
    required String languageCode,
    required String currentLevel,
    required String targetLevel,
  }) async {
    await _initializeTables();
    final db = await _db.database;
    
    final assessmentId = 'assess_${DateTime.now().millisecondsSinceEpoch}_$userId';
    
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

    // Save to SQLite
    await db.insert('assessments', {
      'id': assessment.id,
      'user_id': assessment.userId,
      'language_code': assessment.languageCode,
      'current_level': assessment.currentLevel,
      'target_level': assessment.targetLevel,
      'started_at': assessment.startedAt.toIso8601String(),
      'is_completed': 0,
      'question_ids': jsonEncode(questions.map((q) => q.id).toList()),
    });

    return assessment;
  }

  @override
  Future<List<AssessmentQuestionEntity>> getAssessmentQuestions({
    required String languageCode,
    required String level,
    required int questionCount,
  }) async {
    // Generate default questions based on level
    return _generateDefaultQuestions(languageCode, level, questionCount);
  }

  @override
  Future<void> submitAnswer({
    required String assessmentId,
    required String questionId,
    required String answer,
  }) async {
    await _initializeTables();
    final db = await _db.database;
    
    await db.insert(
      'assessment_answers',
      {
        'assessment_id': assessmentId,
        'question_id': questionId,
        'user_answer': answer,
        'submitted_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<AssessmentResult> completeAssessment(String assessmentId) async {
    await _initializeTables();
    final db = await _db.database;
    
    // Get all answers for this assessment
    final answers = await db.query(
      'assessment_answers',
      where: 'assessment_id = ?',
      whereArgs: [assessmentId],
    );

    // Get the original assessment
    final assessmentResults = await db.query(
      'assessments',
      where: 'id = ?',
      whereArgs: [assessmentId],
      limit: 1,
    );

    if (assessmentResults.isEmpty) {
      throw Exception('Assessment not found');
    }

    final assessmentData = assessmentResults.first;
    final languageCode = assessmentData['language_code'] as String;
    final targetLevel = assessmentData['target_level'] as String;

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
      final answer = answers.where((a) => a['question_id'] == question.id).firstOrNull;
      
      if (answer != null) {
        final userAnswer = answer['user_answer'] as String;
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
    final recommendedLevel = levelPassed ? targetLevel : assessmentData['current_level'] as String;

    final result = AssessmentResult(
      totalScore: totalScore,
      percentage: percentage,
      recommendedLevel: recommendedLevel,
      levelPassed: levelPassed,
      strengths: strengths.toSet().toList(),
      weaknesses: weaknesses.toSet().toList(),
      feedback: _generateFeedback(percentage, levelPassed),
    );

    // Update assessment in SQLite
    await db.update(
      'assessments',
      {
        'completed_at': DateTime.now().toIso8601String(),
        'is_completed': 1,
        'score': totalScore,
        'percentage': percentage,
        'level_passed': levelPassed ? 1 : 0,
        'recommended_level': recommendedLevel,
      },
      where: 'id = ?',
      whereArgs: [assessmentId],
    );

    // Update user level if they passed
    if (levelPassed) {
      await updateUserLevel(
        userId: assessmentData['user_id'] as String,
        languageCode: languageCode,
        newLevel: targetLevel,
      );
    }

    return result;
  }

  @override
  Future<List<LevelAssessmentEntity>> getUserAssessmentHistory(String userId) async {
    await _initializeTables();
    final db = await _db.database;
    
    final results = await db.query(
      'assessments',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'started_at DESC',
    );

    List<LevelAssessmentEntity> assessments = [];
    
    for (final data in results) {
      assessments.add(LevelAssessmentEntity(
        id: data['id'] as String,
        userId: data['user_id'] as String,
        languageCode: data['language_code'] as String,
        currentLevel: data['current_level'] as String,
        targetLevel: data['target_level'] as String,
        questions: [], // Don't load questions for history view
        startedAt: DateTime.parse(data['started_at'] as String),
        completedAt: data['completed_at'] != null 
            ? DateTime.parse(data['completed_at'] as String) 
            : null,
        score: (data['score'] as num?)?.toDouble(),
        isCompleted: (data['is_completed'] as int?) == 1,
      ));
    }

    return assessments;
  }

  @override
  Future<String> getCurrentUserLevel({
    required String userId,
    required String languageCode,
  }) async {
    final db = await _db.database;
    
    final results = await db.query(
      'users',
      columns: ['language_levels'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (results.isEmpty) {
      return 'beginner'; // Default level
    }

    final levelsJson = results.first['language_levels'] as String?;
    if (levelsJson == null) return 'beginner';
    
    final levels = jsonDecode(levelsJson) as Map<String, dynamic>?;
    return levels?[languageCode] ?? 'beginner';
  }

  @override
  Future<void> updateUserLevel({
    required String userId,
    required String languageCode,
    required String newLevel,
  }) async {
    final db = await _db.database;
    
    // Get current language levels
    final results = await db.query(
      'users',
      columns: ['language_levels'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    Map<String, dynamic> levels = {};
    if (results.isNotEmpty) {
      final levelsJson = results.first['language_levels'] as String?;
      if (levelsJson != null && levelsJson.isNotEmpty) {
        levels = jsonDecode(levelsJson) as Map<String, dynamic>;
      }
    }

    // Update the level for this language
    levels[languageCode] = newLevel;

    // Save back to database
    await db.update(
      'users',
      {
        'language_levels': jsonEncode(levels),
        'last_level_update': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
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
          'intermediate': [],
          'advanced': [],
        },
      };
      
      final languageOptions = options[languageCode]?[level] ?? options['ewondo']!['beginner']!;
      if (languageOptions.isEmpty) return [];
      return languageOptions[index ~/ 2 % languageOptions.length];
    }
    return [];
  }

  String _getCorrectAnswer(String languageCode, String level, int index) {
    final Map<String, Map<String, List<String>>> answers = {
      'ewondo': {
        'beginner': [
          'Bonjour',
          'Akiba',
          'Ma di',
          'Eau',
          'Mbolo',
        ],
        'intermediate': [
          'Ma ke di mba',
          'Je vais au marché',
          'A ke di mba',
          'Ma ke + verbe',
          'Nlo ma ma nkukuma',
        ],
        'advanced': [],
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
