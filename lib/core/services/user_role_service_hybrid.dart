import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../database/unified_database_service.dart';

/// Service for managing user roles in SQLite (HYBRID architecture)
/// Supports 4 main roles: visitor (guest), learner (student), teacher, admin
class UserRoleServiceHybrid {
  final UnifiedDatabaseService _db = UnifiedDatabaseService.instance;

  /// Normalize role string to one of the 4 main roles
  /// Maps legacy aliases (student -> learner, instructor -> teacher)
  String _normalizeRole(String role) {
    switch (role.toLowerCase()) {
      case 'visitor':
      case 'guest':
        return 'visitor';
      case 'learner':
      case 'student':
        return 'learner';
      case 'teacher':
      case 'instructor':
        return 'teacher';
      case 'admin':
      case 'administrator':
        return 'admin';
      default:
        if (kDebugMode) {
          print('Unknown role "$role", defaulting to learner');
        }
        return 'learner'; // Default fallback
    }
  }

  /// Validate that a role is one of the 4 main application roles
  bool _isValidRole(String role) {
    const validRoles = ['visitor', 'learner', 'teacher', 'admin'];
    return validRoles.contains(role.toLowerCase());
  }

  /// Get user role from SQLite
  Future<String> getUserRole(String userId) async {
    try {
      final db = await _db.database;
      final results = await db.query(
        'users',
        columns: ['role'],
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (results.isEmpty) {
        if (kDebugMode) {
          print('User document not found for userId: $userId');
        }
        return 'learner'; // Default role
      }

      final role = results.first['role'] as String?;
      return _normalizeRole(role ?? 'learner');
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user role: $e');
      }
      return 'learner'; // Default on error
    }
  }

  /// Update user role (admin only)
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      // Normalize and validate role
      final normalizedRole = _normalizeRole(newRole);

      if (!_isValidRole(normalizedRole)) {
        throw Exception('Invalid role: $newRole (normalized: $normalizedRole)');
      }

      final db = await _db.database;
      final updateCount = await db.update(
        'users',
        {
          'role': normalizedRole,
          'role_updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (updateCount == 0) {
        throw Exception('User not found: $userId');
      }

      if (kDebugMode) {
        print('User role updated: $userId -> $normalizedRole');
      }
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Assign role to user (for new users or role changes)
  Future<void> assignRole(String userId, String role) async {
    try {
      final normalizedRole = _normalizeRole(role);

      if (!_isValidRole(normalizedRole)) {
        throw Exception('Invalid role: $role (normalized: $normalizedRole)');
      }

      final db = await _db.database;

      // Use INSERT OR REPLACE to handle both new and existing users
      await db.insert('users', {
        'id': userId,
        'role': normalizedRole,
        'role_assigned_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      if (kDebugMode) {
        print('Role assigned to user $userId: $normalizedRole');
      }
    } catch (e) {
      throw Exception('Failed to assign role: $e');
    }
  }

  /// Check if user has a specific role
  Future<bool> hasRole(String userId, String role) async {
    try {
      final userRole = await getUserRole(userId);
      final normalizedRole = _normalizeRole(role);
      return userRole == normalizedRole;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking user role: $e');
      }
      return false;
    }
  }

  /// Check if user is admin
  Future<bool> isAdmin(String userId) async {
    return await hasRole(userId, 'admin');
  }

  /// Check if user is teacher
  Future<bool> isTeacher(String userId) async {
    return await hasRole(userId, 'teacher');
  }

  /// Check if user is learner
  Future<bool> isLearner(String userId) async {
    return await hasRole(userId, 'learner');
  }

  /// Check if user is visitor/guest
  Future<bool> isVisitor(String userId) async {
    return await hasRole(userId, 'visitor');
  }

  /// Get all users with a specific role
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      final normalizedRole = _normalizeRole(role);

      if (!_isValidRole(normalizedRole)) {
        throw Exception('Invalid role: $role (normalized: $normalizedRole)');
      }

      final db = await _db.database;
      return await db.query(
        'users',
        where: 'role = ?',
        whereArgs: [normalizedRole],
        orderBy: 'created_at DESC',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching users by role: $e');
      }
      return [];
    }
  }

  /// Get user count by role
  Future<int> getUserCountByRole(String role) async {
    try {
      final normalizedRole = _normalizeRole(role);

      if (!_isValidRole(normalizedRole)) {
        return 0;
      }

      final db = await _db.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM users WHERE role = ?',
        [normalizedRole],
      );

      return result.first['count'] as int? ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error counting users by role: $e');
      }
      return 0;
    }
  }

  /// Get role statistics
  Future<Map<String, int>> getRoleStatistics() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery(
        'SELECT role, COUNT(*) as count FROM users GROUP BY role',
      );

      final stats = <String, int>{};
      for (final row in result) {
        final role = row['role'] as String? ?? 'unknown';
        final count = row['count'] as int? ?? 0;
        stats[role] = count;
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting role statistics: $e');
      }
      return {};
    }
  }
}

// Backward compatibility alias
typedef UserRoleService = UserRoleServiceHybrid;
