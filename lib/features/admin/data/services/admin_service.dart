import 'package:flutter/foundation.dart';
import '../../../../core/database/unified_database_service.dart';

/// Service for administrator users
///
/// Administrators can:
/// - Manage all users (view, edit roles, deactivate)
/// - View platform statistics
/// - Manage all content (lessons, quizzes, translations)
/// - Access analytics and reports
/// - Perform system maintenance tasks
class AdminService {
  static final _db = UnifiedDatabaseService.instance;

  // ==================== USER MANAGEMENT ====================

  /// Get all users
  static Future<List<Map<String, dynamic>>> getAllUsers({String? role}) async {
    try {
      return await _db.getAllUsers(role: role);
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  /// Get users by role
  static Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      return await _db.getAllUsers(role: role);
    } catch (e) {
      debugPrint('Error getting users by role: $e');
      return [];
    }
  }

  /// Get all students
  static Future<List<Map<String, dynamic>>> getAllStudents() async {
    return await getUsersByRole('student');
  }

  /// Get all teachers
  static Future<List<Map<String, dynamic>>> getAllTeachers() async {
    return await getUsersByRole('teacher');
  }

  /// Update user role
  static Future<Map<String, dynamic>> updateUserRole({
    required String userId,
    required String newRole,
  }) async {
    try {
      if (!['guest', 'student', 'teacher', 'admin'].contains(newRole)) {
        return {'success': false, 'error': 'Rôle invalide'};
      }

      await _db.updateUserRole(userId, newRole);

      debugPrint('✅ User role updated: $userId -> $newRole');

      return {
        'success': true,
        'message': 'Rôle utilisateur mis à jour avec succès',
      };
    } catch (e) {
      debugPrint('Error updating user role: $e');
      return {
        'success': false,
        'error': 'Erreur lors de la mise à jour du rôle',
      };
    }
  }

  /// Get user details with statistics
  static Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      final user = await _db.getUserById(userId);
      if (user == null) return null;

      final stats = await _db.getUserStatistics(userId);
      final progress = await _db.getUserAllProgress(userId);
      final favorites = await _db.getUserFavorites(userId);
      final createdContent = await _db.getUserCreatedContent(userId);

      return {
        ...user,
        'statistics': stats,
        'progress_count': progress.length,
        'favorites_count': favorites.length,
        'created_content_count': createdContent.length,
      };
    } catch (e) {
      debugPrint('Error getting user details: $e');
      return null;
    }
  }

  // ==================== PLATFORM STATISTICS ====================

  /// Get comprehensive platform statistics
  static Future<Map<String, dynamic>> getPlatformStatistics() async {
    try {
      return await _db.getPlatformStatistics();
    } catch (e) {
      debugPrint('Error getting platform statistics: $e');
      return {};
    }
  }

  /// Get user growth statistics
  static Future<Map<String, dynamic>> getUserGrowthStatistics() async {
    try {
      final allUsers = await _db.getAllUsers();

      // Group users by creation date
      final now = DateTime.now();
      final thisMonth = allUsers.where((user) {
        final createdAt = user['created_at'] as int?;
        if (createdAt == null) return false;
        final date = DateTime.fromMillisecondsSinceEpoch(createdAt);
        return date.year == now.year && date.month == now.month;
      }).length;

      final lastMonth = allUsers.where((user) {
        final createdAt = user['created_at'] as int?;
        if (createdAt == null) return false;
        final date = DateTime.fromMillisecondsSinceEpoch(createdAt);
        final lastMonthDate = DateTime(now.year, now.month - 1);
        return date.year == lastMonthDate.year &&
            date.month == lastMonthDate.month;
      }).length;

      return {
        'total_users': allUsers.length,
        'new_users_this_month': thisMonth,
        'new_users_last_month': lastMonth,
        'growth_rate': lastMonth > 0
            ? ((thisMonth - lastMonth) / lastMonth * 100).toStringAsFixed(1)
            : '0',
      };
    } catch (e) {
      debugPrint('Error getting user growth statistics: $e');
      return {};
    }
  }

  /// Get content statistics
  static Future<Map<String, dynamic>> getContentStatistics() async {
    try {
      final platformStats = await _db.getPlatformStatistics();

      // Get user-created content counts
      final lessons = await _db.getAllUsers().then((users) async {
        int count = 0;
        for (var user in users) {
          final content = await _db.getUserCreatedContent(
            user['user_id'] as String,
            contentType: 'lesson',
          );
          count += content.length;
        }
        return count;
      });

      final quizzes = await _db.getAllUsers().then((users) async {
        int count = 0;
        for (var user in users) {
          final content = await _db.getUserCreatedContent(
            user['user_id'] as String,
            contentType: 'quiz',
          );
          count += content.length;
        }
        return count;
      });

      return {
        'official_translations': platformStats['total_translations'] ?? 0,
        'official_lessons': platformStats['total_lessons'] ?? 0,
        'official_quizzes': platformStats['total_quizzes'] ?? 0,
        'user_created_lessons': lessons,
        'user_created_quizzes': quizzes,
      };
    } catch (e) {
      debugPrint('Error getting content statistics: $e');
      return {};
    }
  }

  /// Get engagement statistics
  static Future<Map<String, dynamic>> getEngagementStatistics() async {
    try {
      final platformStats = await _db.getPlatformStatistics();

      return {
        'total_lessons_completed':
            platformStats['total_lessons_completed'] ?? 0,
        'total_quizzes_completed':
            platformStats['total_quizzes_completed'] ?? 0,
        'total_words_learned': platformStats['total_words_learned'] ?? 0,
      };
    } catch (e) {
      debugPrint('Error getting engagement statistics: $e');
      return {};
    }
  }

  // ==================== CONTENT MANAGEMENT ====================

  /// Get all user-created content across platform
  static Future<List<Map<String, dynamic>>> getAllUserCreatedContent({
    String? contentType,
    String? status,
  }) async {
    try {
      final allUsers = await _db.getAllUsers();
      final allContent = <Map<String, dynamic>>[];

      for (var user in allUsers) {
        final content = await _db.getUserCreatedContent(
          user['user_id'] as String,
          contentType: contentType,
          status: status,
        );

        // Add creator info to each content item
        for (var item in content) {
          allContent.add({
            ...item,
            'creator_name': user['display_name'],
            'creator_email': user['email'],
          });
        }
      }

      // Sort by creation date (newest first)
      allContent.sort((a, b) {
        final aDate = a['created_at'] as int? ?? 0;
        final bDate = b['created_at'] as int? ?? 0;
        return bDate.compareTo(aDate);
      });

      return allContent;
    } catch (e) {
      debugPrint('Error getting all user-created content: $e');
      return [];
    }
  }

  /// Approve/publish content
  static Future<Map<String, dynamic>> approveContent({
    required int contentId,
  }) async {
    try {
      await _db.updateContentStatus(contentId: contentId, status: 'published');

      debugPrint('✅ Content #$contentId approved and published');

      return {'success': true, 'message': 'Contenu approuvé et publié'};
    } catch (e) {
      debugPrint('Error approving content: $e');
      return {'success': false, 'error': 'Erreur lors de l\'approbation'};
    }
  }

  /// Reject/archive content
  static Future<Map<String, dynamic>> rejectContent({
    required int contentId,
  }) async {
    try {
      await _db.updateContentStatus(contentId: contentId, status: 'archived');

      debugPrint('✅ Content #$contentId rejected and archived');

      return {'success': true, 'message': 'Contenu rejeté et archivé'};
    } catch (e) {
      debugPrint('Error rejecting content: $e');
      return {'success': false, 'error': 'Erreur lors du rejet'};
    }
  }

  /// Delete any content
  static Future<Map<String, dynamic>> deleteContent({
    required int contentId,
  }) async {
    try {
      await _db.deleteUserContent(contentId);

      debugPrint('✅ Content #$contentId deleted by admin');

      return {'success': true, 'message': 'Contenu supprimé avec succès'};
    } catch (e) {
      debugPrint('Error deleting content: $e');
      return {'success': false, 'error': 'Erreur lors de la suppression'};
    }
  }

  // ==================== ANALYTICS & REPORTS ====================

  /// Get top performing students
  static Future<List<Map<String, dynamic>>> getTopStudents({
    int limit = 10,
  }) async {
    try {
      final students = await getAllStudents();
      final studentsWithStats = <Map<String, dynamic>>[];

      for (var student in students) {
        final stats = await _db.getUserStatistics(student['user_id'] as String);
        if (stats != null) {
          studentsWithStats.add({
            ...student,
            'total_xp': stats['experience_points'] ?? 0,
            'level': stats['level'] ?? 1,
            'lessons_completed': stats['total_lessons_completed'] ?? 0,
            'quizzes_completed': stats['total_quizzes_completed'] ?? 0,
          });
        }
      }

      // Sort by XP
      studentsWithStats.sort((a, b) {
        final aXp = a['total_xp'] as int? ?? 0;
        final bXp = b['total_xp'] as int? ?? 0;
        return bXp.compareTo(aXp);
      });

      return studentsWithStats.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting top students: $e');
      return [];
    }
  }

  /// Get most active teachers
  static Future<List<Map<String, dynamic>>> getMostActiveTeachers({
    int limit = 10,
  }) async {
    try {
      final teachers = await getAllTeachers();
      final teachersWithStats = <Map<String, dynamic>>[];

      for (var teacher in teachers) {
        final content = await _db.getUserCreatedContent(
          teacher['user_id'] as String,
        );
        teachersWithStats.add({
          ...teacher,
          'content_count': content.length,
          'published_count': content
              .where((c) => c['status'] == 'published')
              .length,
        });
      }

      // Sort by content count
      teachersWithStats.sort((a, b) {
        final aCount = a['content_count'] as int? ?? 0;
        final bCount = b['content_count'] as int? ?? 0;
        return bCount.compareTo(aCount);
      });

      return teachersWithStats.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting most active teachers: $e');
      return [];
    }
  }

  /// Get language usage statistics
  static Future<Map<String, dynamic>> getLanguageStatistics() async {
    try {
      final languages = await _db.getAllLanguages();
      final languageStats = <Map<String, dynamic>>[];

      for (var language in languages) {
        final languageId = language['language_id'] as String;

        final translations = await _db.getTranslationsByLanguage(languageId);
        final lessons = await _db.getLessonsByLanguage(languageId);
        final quizzes = await _db.getQuizzesByLanguageAndDifficulty(languageId);

        languageStats.add({
          'language_id': languageId,
          'language_name': language['language_name'],
          'translations_count': translations.length,
          'lessons_count': lessons.length,
          'quizzes_count': quizzes.length,
          'total_content':
              translations.length + lessons.length + quizzes.length,
        });
      }

      // Sort by total content
      languageStats.sort((a, b) {
        final aTotal = a['total_content'] as int? ?? 0;
        final bTotal = b['total_content'] as int? ?? 0;
        return bTotal.compareTo(aTotal);
      });

      return {
        'total_languages': languages.length,
        'language_breakdown': languageStats,
      };
    } catch (e) {
      debugPrint('Error getting language statistics: $e');
      return {};
    }
  }

  // ==================== SYSTEM MAINTENANCE ====================

  /// Get database metadata
  static Future<Map<String, dynamic>> getDatabaseMetadata() async {
    try {
      final dbVersion = await _db.getMetadata('db_version');
      final createdAt = await _db.getMetadata('created_at');
      final totalLanguages = await _db.getMetadata('total_languages');

      return {
        'db_version': dbVersion,
        'created_at': createdAt,
        'total_languages': totalLanguages,
      };
    } catch (e) {
      debugPrint('Error getting database metadata: $e');
      return {};
    }
  }

  /// Export platform data (placeholder for future implementation)
  static Future<Map<String, dynamic>> exportPlatformData() async {
    try {
      // This would export all data for backup/analysis
      debugPrint('⚠️ Export platform data not yet implemented');

      return {
        'success': false,
        'message': 'Fonctionnalité d\'export non encore implémentée',
      };
    } catch (e) {
      debugPrint('Error exporting platform data: $e');
      return {'success': false, 'error': 'Erreur lors de l\'export'};
    }
  }

  /// Generate comprehensive admin dashboard data
  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final platformStats = await getPlatformStatistics();
      final userGrowth = await getUserGrowthStatistics();
      final contentStats = await getContentStatistics();
      final engagementStats = await getEngagementStatistics();

      return {
        'platform_stats': platformStats,
        'user_growth': userGrowth,
        'content_stats': contentStats,
        'engagement_stats': engagementStats,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error generating dashboard data: $e');
      return {};
    }
  }
}
