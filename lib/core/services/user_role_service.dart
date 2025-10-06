import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

/// Service for managing user roles in Firestore
class UserRoleService {
  final FirebaseService _firebaseService;

  UserRoleService(this._firebaseService);

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
      return role ?? 'learner';
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
      // Validate role
      final validRoles = ['learner', 'teacher', 'admin', 'instructor', 'student'];
      if (!validRoles.contains(newRole.toLowerCase())) {
        throw Exception('Invalid role: $newRole');
      }

      await _firebaseService.firestore.collection('users').doc(userId).update({
        'role': newRole.toLowerCase(),
        'roleUpdatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('User role updated: $userId -> $newRole');
      }
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Assign role to user (for new users or role changes)
  Future<void> assignRole(String userId, String role) async {
    try {
      final validRoles = ['learner', 'teacher', 'admin', 'instructor', 'student'];
      final normalizedRole = role.toLowerCase();

      if (!validRoles.contains(normalizedRole)) {
        throw Exception('Invalid role: $role');
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
      return userRole.toLowerCase() == role.toLowerCase();
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
    final userRole = await getUserRole(userId);
    return userRole == 'teacher' || userRole == 'instructor';
  }

  /// Check if user is learner
  Future<bool> isLearner(String userId) async {
    final userRole = await getUserRole(userId);
    return userRole == 'learner' || userRole == 'student';
  }

  /// Get all users with a specific role
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('users')
          .where('role', isEqualTo: role.toLowerCase())
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
      final validRoles = ['learner', 'teacher', 'admin', 'instructor', 'student'];
      final normalizedRole = role.toLowerCase();

      if (!validRoles.contains(normalizedRole)) {
        throw Exception('Invalid role: $role');
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
        'admin': 0,
        'teacher': 0,
        'learner': 0,
        'total': usersSnapshot.docs.length,
      };

      for (final doc in usersSnapshot.docs) {
        final role = doc.data()['role'] as String? ?? 'learner';
        if (role == 'admin') {
          stats['admin'] = (stats['admin'] ?? 0) + 1;
        } else if (role == 'teacher' || role == 'instructor') {
          stats['teacher'] = (stats['teacher'] ?? 0) + 1;
        } else {
          stats['learner'] = (stats['learner'] ?? 0) + 1;
        }
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting role statistics: $e');
      }
      return {'admin': 0, 'teacher': 0, 'learner': 0, 'total': 0};
    }
  }
}
