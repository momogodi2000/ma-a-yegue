import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_role.dart';
import 'firebase_service.dart';

/// Service for managing user roles in Firestore
class UserRoleService {
  final FirebaseService _firebaseService;

  UserRoleService(this._firebaseService);

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

  /// Get user role from Firestore
  Future<String> getUserRole(String userId) async {
    try {
      final userDoc = await _firebaseService.firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        if (kDebugMode) {
          print('User document not found for userId: $userId');
        }
        return 'learner'; // Default role
      }

      final role = userDoc.data()!['role'] as String?;
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

      await _firebaseService.firestore.collection('users').doc(userId).update({
        'role': normalizedRole,
        'roleUpdatedAt': FieldValue.serverTimestamp(),
      });

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

      await _firebaseService.firestore.collection('users').doc(userId).set({
        'role': normalizedRole,
        'roleAssignedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

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
      
      final querySnapshot = await _firebaseService.firestore
          .collection('users')
          .where('role', isEqualTo: normalizedRole)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'uid': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching users by role: $e');
      }
      return [];
    }
  }

  /// Create user with role (for admin creating new users)
  Future<void> createUserWithRole({
    required String userId,
    required String email,
    required String displayName,
    required String role,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final normalizedRole = _normalizeRole(role);

      if (!_isValidRole(normalizedRole)) {
        throw Exception('Invalid role: $role (normalized: $normalizedRole)');
      }

      final userData = {
        'uid': userId,
        'email': email,
        'displayName': displayName,
        'role': normalizedRole,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        ...?additionalData,
      };

      await _firebaseService.firestore
          .collection('users')
          .doc(userId)
          .set(userData);

      if (kDebugMode) {
        print('User created with role: $email -> $normalizedRole');
      }
    } catch (e) {
      throw Exception('Failed to create user with role: $e');
    }
  }

  /// Promote user to teacher (admin only)
  Future<void> promoteToTeacher(String userId) async {
    await updateUserRole(userId, 'teacher');
  }

  /// Promote user to admin (super admin only)
  Future<void> promoteToAdmin(String userId) async {
    await updateUserRole(userId, 'admin');
  }

  /// Demote user to learner
  Future<void> demoteToLearner(String userId) async {
    await updateUserRole(userId, 'learner');
  }

  /// Get role statistics
  Future<Map<String, int>> getRoleStatistics() async {
    try {
      final usersSnapshot = await _firebaseService.firestore
          .collection('users')
          .get();

      final stats = <String, int>{
        'visitor': 0,
        'admin': 0,
        'teacher': 0,
        'learner': 0,
        'total': usersSnapshot.docs.length,
      };

      for (final doc in usersSnapshot.docs) {
        final role = _normalizeRole(doc.data()['role'] as String? ?? 'learner');
        stats[role] = (stats[role] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting role statistics: $e');
      }
      return {'visitor': 0, 'admin': 0, 'teacher': 0, 'learner': 0, 'total': 0};
    }
  }

  /// Get UserRole enum from string
  UserRole getUserRoleEnum(String role) {
    return UserRoleExtension.fromString(_normalizeRole(role));
  }
}
