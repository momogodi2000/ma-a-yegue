import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import '../config/environment_config.dart';
import '../database/unified_database_service.dart';
import 'firebase_service.dart';

/// Admin Setup Service - Hybrid Architecture
///
/// ✅ Uses Firebase Auth for authentication only
/// ✅ Uses SQLite for all admin user data and permissions storage
///
/// Manages admin user creation, permissions, and role management
class AdminSetupServiceHybrid {
  final FirebaseService _firebaseService;
  final UnifiedDatabaseService _database = UnifiedDatabaseService.instance;

  AdminSetupServiceHybrid(this._firebaseService);

  /// Check if default admin exists in SQLite
  Future<bool> defaultAdminExists() async {
    try {
      final adminEmail = EnvironmentConfig.defaultAdminEmail;
      final db = await _database.database;

      final results = await db.query(
        'users',
        where: 'email = ? AND role = ?',
        whereArgs: [adminEmail, 'admin'],
        limit: 1,
      );

      return results.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking if admin exists: $e');
      }
      return false;
    }
  }

  /// Create the default admin user
  Future<Map<String, dynamic>> createDefaultAdmin() async {
    try {
      final adminEmail = EnvironmentConfig.defaultAdminEmail;
      final adminPassword = EnvironmentConfig.defaultAdminPassword;
      final adminName = EnvironmentConfig.defaultAdminName;

      // Validate credentials
      if (adminEmail.isEmpty || adminPassword.isEmpty) {
        throw Exception('Admin credentials not set in environment');
      }

      if (adminPassword.length < 8) {
        throw Exception('Admin password must be at least 8 characters');
      }

      // Check if admin already exists
      if (await defaultAdminExists()) {
        throw Exception('Default admin already exists');
      }

      // Step 1: Create Firebase Auth user
      final userCredential = await _firebaseService.auth
          .createUserWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create admin user');
      }

      await user.updateDisplayName(adminName);

      // Step 2: Store admin profile in SQLite with all privileges
      final now = DateTime.now().toIso8601String();
      final userId = await _database.upsertUser({
        'firebase_uid': user.uid,
        'email': adminEmail,
        'display_name': adminName,
        'role': 'admin',
        'is_active': 1,
        'is_default_admin': 1,
        'created_at': now,
        'last_login_at': now,
        'auth_provider': 'email',
        'two_factor_enabled': 0,
        'permissions': jsonEncode([
          'view_lessons',
          'create_lessons',
          'edit_lessons',
          'delete_lessons',
          'view_dictionary',
          'add_dictionary_entries',
          'edit_dictionary_entries',
          'delete_dictionary_entries',
          'review_dictionary_entries',
          'manage_users',
          'view_analytics',
          'system_configuration',
          'content_moderation',
          'process_payments',
          'view_payment_history',
        ]),
        'profile_data': jsonEncode({
          'bio': 'Administrateur par défaut de la plateforme Ma\'a yegue',
          'preferredLanguage': 'fr',
          'timezone': 'Africa/Douala',
        }),
      });

      // Send email verification
      await user.sendEmailVerification();

      // Log analytics
      await _firebaseService.logEvent(
        name: 'admin_created',
        parameters: {'type': 'default_admin'},
      );

      if (kDebugMode) {
        print('✅ Default admin created: $adminEmail');
      }

      return {
        'success': true,
        'uid': user.uid,
        'userId': userId,
        'email': adminEmail,
        'message': 'Admin créé avec succès',
      };
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Auth error: ${e.code} - ${e.message}');
      }

      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'L\'email est déjà utilisé';
          break;
        case 'invalid-email':
          errorMessage = 'Email invalide';
          break;
        case 'weak-password':
          errorMessage = 'Mot de passe trop faible';
          break;
        default:
          errorMessage = 'Erreur: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating admin: $e');
      }
      await _firebaseService.recordError(
        e,
        StackTrace.current,
        reason: 'Failed to create default admin',
      );
      throw Exception('Erreur: $e');
    }
  }

  /// Reset admin password
  Future<void> resetAdminPassword() async {
    try {
      final adminEmail = EnvironmentConfig.defaultAdminEmail;
      await _firebaseService.auth.sendPasswordResetEmail(email: adminEmail);

      if (kDebugMode) {
        print('✅ Password reset email sent to: $adminEmail');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to send password reset email: $e');
      }
      throw Exception('Failed to send password reset: $e');
    }
  }

  /// Get admin users count from SQLite
  Future<int> getAdminCount() async {
    try {
      final db = await _database.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM users WHERE role = ?',
        ['admin'],
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting admin count: $e');
      }
      return 0;
    }
  }

  /// Promote user to admin role
  Future<void> promoteToAdmin(String userId) async {
    try {
      final db = await _database.database;

      // Get current user
      final users = await db.query(
        'users',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (users.isEmpty) {
        throw Exception('User not found');
      }

      final user = users.first;
      if (user['role'] == 'admin') {
        throw Exception('User is already an admin');
      }

      // Update role to admin with permissions
      await db.update(
        'users',
        {
          'role': 'admin',
          'promoted_to_admin_at': DateTime.now().toIso8601String(),
          'permissions': jsonEncode([
            'view_lessons',
            'create_lessons',
            'edit_lessons',
            'delete_lessons',
            'view_dictionary',
            'add_dictionary_entries',
            'edit_dictionary_entries',
            'delete_dictionary_entries',
            'manage_users',
            'view_analytics',
            'content_moderation',
          ]),
        },
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      // Log admin promotion
      await db.insert('admin_logs', {
        'action': 'user_promoted',
        'user_id': userId,
        'details': jsonEncode({'role': 'admin'}),
        'timestamp': DateTime.now().toIso8601String(),
      });

      await _firebaseService.logEvent(
        name: 'user_promoted_to_admin',
        parameters: {'userId': userId},
      );

      if (kDebugMode) {
        print('✅ User $userId promoted to admin');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error promoting user to admin: $e');
      }
      throw Exception('Failed to promote user: $e');
    }
  }

  /// Demote admin to regular user
  Future<void> demoteFromAdmin(String userId) async {
    try {
      final db = await _database.database;

      // Check if this is the default admin
      final users = await db.query(
        'users',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (users.isEmpty) {
        throw Exception('User not found');
      }

      final user = users.first;
      if (user['is_default_admin'] == 1) {
        throw Exception('Cannot demote default admin');
      }

      if (user['role'] != 'admin') {
        throw Exception('User is not an admin');
      }

      // Update role to student with basic permissions
      await db.update(
        'users',
        {
          'role': 'student',
          'demoted_from_admin_at': DateTime.now().toIso8601String(),
          'permissions': jsonEncode(['view_lessons', 'view_dictionary']),
        },
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      // Log admin demotion
      await db.insert('admin_logs', {
        'action': 'user_demoted',
        'user_id': userId,
        'details': jsonEncode({'from_role': 'admin', 'to_role': 'student'}),
        'timestamp': DateTime.now().toIso8601String(),
      });

      await _firebaseService.logEvent(
        name: 'user_demoted_from_admin',
        parameters: {'userId': userId},
      );

      if (kDebugMode) {
        print('✅ User $userId demoted from admin');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error demoting admin: $e');
      }
      throw Exception('Failed to demote user: $e');
    }
  }

  /// Get all admin users from SQLite
  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final db = await _database.database;
      final admins = await db.query(
        'users',
        where: 'role = ?',
        whereArgs: ['admin'],
        orderBy: 'created_at DESC',
      );

      return admins;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting admin list: $e');
      }
      return [];
    }
  }

  /// Initialize admin account on first launch
  Future<void> initializeAdminOnFirstLaunch() async {
    try {
      final adminCount = await getAdminCount();

      if (adminCount == 0) {
        if (kDebugMode) {
          print('ℹ️ No admin found. Creating default admin...');
        }
        await createDefaultAdmin();
      } else {
        if (kDebugMode) {
          print('✓ Admin account(s) already exist: $adminCount');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error initializing admin: $e');
      }
      await _firebaseService.recordError(
        e,
        StackTrace.current,
        reason: 'Failed to initialize admin on first launch',
      );
    }
  }
}

// Backward compatibility alias
typedef AdminSetupService = AdminSetupServiceHybrid;
