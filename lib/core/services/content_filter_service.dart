/// Age-appropriate content filtering service
/// Addresses CRITICAL_ANALYSIS requirement for age-differentiated content

import '../models/educational_models.dart';

/// Content difficulty/complexity levels
enum ContentComplexity {
  veryEasy(1, 'Très Facile', [GradeLevel.cp, GradeLevel.ce1]),
  easy(2, 'Facile', [GradeLevel.ce2, GradeLevel.cm1]),
  medium(3, 'Moyen', [
    GradeLevel.cm2,
    GradeLevel.sixieme,
    GradeLevel.cinquieme,
  ]),
  advanced(4, 'Avancé', [
    GradeLevel.quatrieme,
    GradeLevel.troisieme,
    GradeLevel.seconde,
  ]),
  expert(5, 'Expert', [GradeLevel.premiere, GradeLevel.terminale]);

  const ContentComplexity(this.level, this.displayName, this.appropriateGrades);

  final int level;
  final String displayName;
  final List<GradeLevel> appropriateGrades;

  /// Check if content is appropriate for a grade level
  bool isAppropriateFor(GradeLevel grade) {
    return appropriateGrades.contains(grade);
  }

  /// Get complexity for a grade level
  static ContentComplexity forGradeLevel(GradeLevel grade) {
    for (final complexity in ContentComplexity.values) {
      if (complexity.appropriateGrades.contains(grade)) {
        return complexity;
      }
    }
    return ContentComplexity.medium; // Default
  }

  /// Check if content can be shown to age
  bool isAppropriateForAge(int age) {
    switch (this) {
      case ContentComplexity.veryEasy:
        return age >= 6 && age <= 8;
      case ContentComplexity.easy:
        return age >= 8 && age <= 11;
      case ContentComplexity.medium:
        return age >= 11 && age <= 14;
      case ContentComplexity.advanced:
        return age >= 14 && age <= 16;
      case ContentComplexity.expert:
        return age >= 16 && age <= 18;
    }
  }
}

/// Content maturity rating
enum ContentMaturity {
  allAges('Tous âges', 0, 100),
  children('Enfants 6-11 ans', 6, 11),
  youngTeens('Jeunes Ados 12-14 ans', 12, 14),
  teens('Adolescents 15-17 ans', 15, 17),
  mature('Adultes 18+', 18, 100);

  const ContentMaturity(this.displayName, this.minAge, this.maxAge);

  final String displayName;
  final int minAge;
  final int maxAge;

  bool isAppropriateForAge(int age) {
    return age >= minAge && age <= maxAge;
  }
}

/// Content filter service
class ContentFilterService {
  /// Filter content based on grade level
  static bool isContentAppropriate({
    required GradeLevel studentGrade,
    required ContentComplexity contentComplexity,
    bool allowHigherComplexity = false,
  }) {
    final gradeComplexity = ContentComplexity.forGradeLevel(studentGrade);

    if (allowHigherComplexity) {
      // Allow content up to 1 level higher
      return contentComplexity.level <= gradeComplexity.level + 1;
    }

    return contentComplexity.isAppropriateFor(studentGrade);
  }

  /// Filter content based on age
  static bool isContentAppropriateForAge({
    required int studentAge,
    required ContentMaturity contentMaturity,
  }) {
    return contentMaturity.isAppropriateForAge(studentAge);
  }

  /// Get recommended complexity for student
  static ContentComplexity getRecommendedComplexity({
    required GradeLevel gradeLevel,
    required double performanceScore, // 0-100
  }) {
    final baseComplexity = ContentComplexity.forGradeLevel(gradeLevel);

    // Adjust based on performance
    if (performanceScore >= 90) {
      // High performers can handle one level higher
      final higherLevel = baseComplexity.level + 1;
      if (higherLevel <= ContentComplexity.expert.level) {
        return ContentComplexity.values.firstWhere(
          (c) => c.level == higherLevel,
        );
      }
    } else if (performanceScore < 50) {
      // Lower performers need easier content
      final lowerLevel = baseComplexity.level - 1;
      if (lowerLevel >= ContentComplexity.veryEasy.level) {
        return ContentComplexity.values.firstWhere(
          (c) => c.level == lowerLevel,
        );
      }
    }

    return baseComplexity;
  }

  /// Filter vocabulary by age appropriateness
  static List<String> filterVocabulary({
    required List<String> words,
    required GradeLevel gradeLevel,
  }) {
    // Get complexity level for filtering
    // In real implementation, this would check against a vocabulary database
    // For now, we return all words (placeholder)
    // TODO: Implement vocabulary difficulty database
    return words;
  }

  /// Get content tags for filtering
  static List<String> getAgeAppropriateTags(GradeLevel gradeLevel) {
    if (gradeLevel.isPrimaire) {
      return [
        'enfants',
        'débutant',
        'basique',
        'simple',
        'illustré',
        'jeux',
        'contes',
      ];
    } else if (gradeLevel.educationLevel == EducationLevel.secondaire1) {
      return [
        'adolescents',
        'intermédiaire',
        'culture',
        'histoire',
        'sciences',
        'projets',
      ];
    } else {
      return [
        'avancé',
        'analyse',
        'recherche',
        'littérature',
        'philosophie',
        'débat',
      ];
    }
  }

  /// Validate lesson content for grade level
  static ValidationResult validateLessonContent({
    required String lessonContent,
    required GradeLevel targetGrade,
  }) {
    // Placeholder validation logic
    // In real implementation, would use NLP to analyze content complexity

    final wordCount = lessonContent.split(' ').length;
    final recommendedWordCount = _getRecommendedWordCount(targetGrade);

    if (wordCount > recommendedWordCount * 1.5) {
      return ValidationResult(
        isValid: false,
        message:
            'Contenu trop long pour le niveau ${targetGrade.fullName}. '
            'Recommandé: $recommendedWordCount mots, Actuel: $wordCount mots',
        suggestions: [
          'Réduire le nombre de mots',
          'Simplifier les phrases',
          'Diviser en plusieurs leçons',
        ],
      );
    }

    if (wordCount < recommendedWordCount * 0.3) {
      return ValidationResult(
        isValid: false,
        message: 'Contenu insuffisant pour le niveau ${targetGrade.fullName}.',
        suggestions: [
          'Ajouter plus d\'exemples',
          'Développer les explications',
          'Ajouter des exercices',
        ],
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Contenu approprié pour ${targetGrade.fullName}',
      suggestions: [],
    );
  }

  static int _getRecommendedWordCount(GradeLevel grade) {
    if (grade.level <= 2) return 200; // CP, CE1
    if (grade.level <= 5) return 400; // CE2, CM1, CM2
    if (grade.level <= 9) return 600; // Collège
    return 800; // Lycée
  }

  /// Get reading time estimate based on grade level
  static int getEstimatedReadingTime({
    required String content,
    required GradeLevel gradeLevel,
  }) {
    final wordCount = content.split(' ').length;
    final wordsPerMinute = _getReadingSpeed(gradeLevel);
    return (wordCount / wordsPerMinute).ceil();
  }

  static int _getReadingSpeed(GradeLevel grade) {
    if (grade.level <= 2) return 50; // CP, CE1: 50 mots/min
    if (grade.level <= 5) return 100; // CE2-CM2: 100 mots/min
    if (grade.level <= 9) return 150; // Collège: 150 mots/min
    return 200; // Lycée: 200 mots/min
  }
}

class ValidationResult {
  final bool isValid;
  final String message;
  final List<String> suggestions;

  const ValidationResult({
    required this.isValid,
    required this.message,
    required this.suggestions,
  });
}
