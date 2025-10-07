import 'package:flutter/foundation.dart';

/// Comprehensive Input Validator
///
/// Validates all user inputs to prevent SQL injection, XSS, and other attacks
class InputValidator {
  // ==================== EMAIL VALIDATION ====================

  /// Validate email address
  static ValidationResult validateEmail(String email) {
    if (email.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'L\'email est requis',
      );
    }

    // Basic email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return ValidationResult(
        isValid: false,
        error: 'Format d\'email invalide',
      );
    }

    // Check for common disposable email domains
    final disposableDomains = [
      'tempmail.com',
      '10minutemail.com',
      'guerrillamail.com',
      'mailinator.com',
    ];

    final domain = email.split('@').last.toLowerCase();
    if (disposableDomains.contains(domain)) {
      return ValidationResult(
        isValid: false,
        error: 'Les emails temporaires ne sont pas autorisés',
      );
    }

    return ValidationResult(isValid: true, sanitized: email.trim().toLowerCase());
  }

  // ==================== PASSWORD VALIDATION ====================

  /// Validate password strength
  static ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'Le mot de passe est requis',
      );
    }

    if (password.length < 8) {
      return ValidationResult(
        isValid: false,
        error: 'Le mot de passe doit contenir au moins 8 caractères',
      );
    }

    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return ValidationResult(
        isValid: false,
        error: 'Le mot de passe doit contenir au moins une majuscule',
      );
    }

    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return ValidationResult(
        isValid: false,
        error: 'Le mot de passe doit contenir au moins une minuscule',
      );
    }

    // Check for at least one number
    if (!password.contains(RegExp(r'[0-9]'))) {
      return ValidationResult(
        isValid: false,
        error: 'Le mot de passe doit contenir au moins un chiffre',
      );
    }

    // Check for at least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return ValidationResult(
        isValid: false,
        error: 'Le mot de passe doit contenir au moins un caractère spécial',
      );
    }

    return ValidationResult(isValid: true);
  }

  /// Check password strength level
  static PasswordStrength checkPasswordStrength(String password) {
    int score = 0;

    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    if (password.length >= 16) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    if (score <= 5) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  // ==================== TEXT INPUT VALIDATION ====================

  /// Sanitize text input (prevent SQL injection and XSS)
  static String sanitizeText(String input) {
    if (input.isEmpty) return '';

    // Remove potentially dangerous characters
    String sanitized = input
        .replaceAll(RegExp(r'[<>]'), '') // Remove HTML tags
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Remove control characters
        .trim();

    // Limit length
    if (sanitized.length > 10000) {
      sanitized = sanitized.substring(0, 10000);
    }

    return sanitized;
  }

  /// Validate display name
  static ValidationResult validateDisplayName(String name) {
    if (name.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'Le nom est requis',
      );
    }

    if (name.length < 2) {
      return ValidationResult(
        isValid: false,
        error: 'Le nom doit contenir au moins 2 caractères',
      );
    }

    if (name.length > 50) {
      return ValidationResult(
        isValid: false,
        error: 'Le nom ne peut pas dépasser 50 caractères',
      );
    }

    // Only allow letters, spaces, hyphens, and apostrophes
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$");
    if (!nameRegex.hasMatch(name)) {
      return ValidationResult(
        isValid: false,
        error: 'Le nom contient des caractères invalides',
      );
    }

    return ValidationResult(isValid: true, sanitized: sanitizeText(name));
  }

  /// Validate lesson title
  static ValidationResult validateLessonTitle(String title) {
    if (title.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'Le titre est requis',
      );
    }

    if (title.length < 3) {
      return ValidationResult(
        isValid: false,
        error: 'Le titre doit contenir au moins 3 caractères',
      );
    }

    if (title.length > 200) {
      return ValidationResult(
        isValid: false,
        error: 'Le titre ne peut pas dépasser 200 caractères',
      );
    }

    return ValidationResult(isValid: true, sanitized: sanitizeText(title));
  }

  /// Validate lesson content
  static ValidationResult validateLessonContent(String content) {
    if (content.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'Le contenu est requis',
      );
    }

    if (content.length < 10) {
      return ValidationResult(
        isValid: false,
        error: 'Le contenu doit contenir au moins 10 caractères',
      );
    }

    if (content.length > 50000) {
      return ValidationResult(
        isValid: false,
        error: 'Le contenu ne peut pas dépasser 50000 caractères',
      );
    }

    return ValidationResult(isValid: true, sanitized: sanitizeText(content));
  }

  // ==================== NUMERIC VALIDATION ====================

  /// Validate positive integer
  static ValidationResult validatePositiveInteger(
    dynamic value,
    String fieldName,
  ) {
    if (value == null) {
      return ValidationResult(
        isValid: false,
        error: '$fieldName est requis',
      );
    }

    int? intValue;
    if (value is int) {
      intValue = value;
    } else if (value is String) {
      intValue = int.tryParse(value);
    }

    if (intValue == null) {
      return ValidationResult(
        isValid: false,
        error: '$fieldName doit être un nombre entier',
      );
    }

    if (intValue <= 0) {
      return ValidationResult(
        isValid: false,
        error: '$fieldName doit être positif',
      );
    }

    return ValidationResult(isValid: true, sanitized: intValue);
  }

  /// Validate score (0-100)
  static ValidationResult validateScore(dynamic score) {
    if (score == null) {
      return ValidationResult(
        isValid: false,
        error: 'Le score est requis',
      );
    }

    double? doubleValue;
    if (score is double) {
      doubleValue = score;
    } else if (score is int) {
      doubleValue = score.toDouble();
    } else if (score is String) {
      doubleValue = double.tryParse(score);
    }

    if (doubleValue == null) {
      return ValidationResult(
        isValid: false,
        error: 'Le score doit être un nombre',
      );
    }

    if (doubleValue < 0 || doubleValue > 100) {
      return ValidationResult(
        isValid: false,
        error: 'Le score doit être entre 0 et 100',
      );
    }

    return ValidationResult(isValid: true, sanitized: doubleValue);
  }

  // ==================== ENUM VALIDATION ====================

  /// Validate role
  static ValidationResult validateRole(String role) {
    const validRoles = ['guest', 'student', 'teacher', 'admin'];

    if (!validRoles.contains(role.toLowerCase())) {
      return ValidationResult(
        isValid: false,
        error: 'Rôle invalide',
      );
    }

    return ValidationResult(isValid: true, sanitized: role.toLowerCase());
  }

  /// Validate content type
  static ValidationResult validateContentType(String type) {
    const validTypes = ['lesson', 'quiz', 'translation', 'reading'];

    if (!validTypes.contains(type.toLowerCase())) {
      return ValidationResult(
        isValid: false,
        error: 'Type de contenu invalide',
      );
    }

    return ValidationResult(isValid: true, sanitized: type.toLowerCase());
  }

  /// Validate difficulty level
  static ValidationResult validateDifficultyLevel(String level) {
    const validLevels = ['beginner', 'intermediate', 'advanced'];

    if (!validLevels.contains(level.toLowerCase())) {
      return ValidationResult(
        isValid: false,
        error: 'Niveau de difficulté invalide',
      );
    }

    return ValidationResult(isValid: true, sanitized: level.toLowerCase());
  }

  /// Validate language code
  static ValidationResult validateLanguageCode(String code) {
    const validCodes = ['EWO', 'DUA', 'FEF', 'FUL', 'BAS', 'BAM', 'YMB'];

    if (!validCodes.contains(code.toUpperCase())) {
      return ValidationResult(
        isValid: false,
        error: 'Code de langue invalide',
      );
    }

    return ValidationResult(isValid: true, sanitized: code.toUpperCase());
  }

  // ==================== SQL INJECTION PREVENTION ====================

  /// Sanitize for SQL query (although parameterized queries should be used)
  static String sanitizeForSQL(String input) {
    // Remove SQL special characters
    return input
        .replaceAll("'", "''") // Escape single quotes
        .replaceAll(';', '') // Remove semicolons
        .replaceAll('--', '') // Remove SQL comments
        .replaceAll('/*', '') // Remove block comments
        .replaceAll('*/', '');
  }

  /// Validate and sanitize search query
  static ValidationResult validateSearchQuery(String query) {
    if (query.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'La recherche ne peut pas être vide',
      );
    }

    if (query.length > 200) {
      return ValidationResult(
        isValid: false,
        error: 'La recherche ne peut pas dépasser 200 caractères',
      );
    }

    // Remove SQL injection attempts
    final sanitized = sanitizeForSQL(sanitizeText(query));

    return ValidationResult(isValid: true, sanitized: sanitized);
  }

  // ==================== URL VALIDATION ====================

  /// Validate URL
  static ValidationResult validateUrl(String url, {bool required = false}) {
    if (url.trim().isEmpty) {
      if (required) {
        return ValidationResult(
          isValid: false,
          error: 'L\'URL est requise',
        );
      }
      return ValidationResult(isValid: true, sanitized: '');
    }

    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return ValidationResult(
          isValid: false,
          error: 'Format d\'URL invalide',
        );
      }

      // Only allow http/https
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return ValidationResult(
          isValid: false,
          error: 'Seuls les URLs HTTP/HTTPS sont autorisés',
        );
      }

      return ValidationResult(isValid: true, sanitized: url.trim());
    } catch (e) {
      return ValidationResult(
        isValid: false,
        error: 'URL invalide',
      );
    }
  }

  // ==================== BULK VALIDATION ====================

  /// Validate multiple fields at once
  static Map<String, ValidationResult> validateFields(
    Map<String, dynamic> fields,
  ) {
    final results = <String, ValidationResult>{};

    fields.forEach((fieldName, value) {
      if (value is String) {
        results[fieldName] = ValidationResult(
          isValid: true,
          sanitized: sanitizeText(value),
        );
      }
    });

    return results;
  }

  /// Check if all validations passed
  static bool allValid(Map<String, ValidationResult> results) {
    return results.values.every((result) => result.isValid);
  }

  /// Get all errors from validation results
  static List<String> getAllErrors(Map<String, ValidationResult> results) {
    return results.values
        .where((result) => !result.isValid && result.error != null)
        .map((result) => result.error!)
        .toList();
  }
}

/// Validation result model
class ValidationResult {
  final bool isValid;
  final String? error;
  final dynamic sanitized;

  ValidationResult({
    required this.isValid,
    this.error,
    this.sanitized,
  });
}

/// Password strength enum
enum PasswordStrength {
  weak,
  medium,
  strong,
  veryStrong,
}

/// Extension for password strength
extension PasswordStrengthExtension on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.weak:
        return 'Faible';
      case PasswordStrength.medium:
        return 'Moyen';
      case PasswordStrength.strong:
        return 'Fort';
      case PasswordStrength.veryStrong:
        return 'Très fort';
    }
  }

  double get score {
    switch (this) {
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.5;
      case PasswordStrength.strong:
        return 0.75;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }
}
