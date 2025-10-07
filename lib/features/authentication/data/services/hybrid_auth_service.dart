import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/database/unified_database_service.dart';

/// Hybrid Authentication Service
///
/// Combines Firebase Authentication (for auth logic) with SQLite (for user data storage)
/// - Firebase: Handles authentication, password management, OAuth
/// - SQLite: Stores all user profile data, preferences, and app-specific information
class HybridAuthService {
  static final _firebaseService = FirebaseService();
  static final _db = UnifiedDatabaseService.instance;

  /// Sign up with email and password
  static Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'student',
  }) async {
    try {
      // 1. Create user in Firebase
      final userCredential = await _firebaseService.auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create Firebase user');
      }

      // 2. Update Firebase display name
      await firebaseUser.updateDisplayName(displayName);

      // 3. Create user in SQLite database
      final now = DateTime.now().millisecondsSinceEpoch;
      final userId = firebaseUser.uid;

      await _db.upsertUser({
        'user_id': userId,
        'firebase_uid': firebaseUser.uid,
        'email': email,
        'display_name': displayName,
        'role': role,
        'subscription_status': 'free',
        'created_at': now,
        'updated_at': now,
        'last_login': now,
      });

      // 4. Create initial user statistics
      await _db.upsertUserStatistics(userId, {
        'total_lessons_completed': 0,
        'total_quizzes_completed': 0,
        'total_words_learned': 0,
        'total_readings_completed': 0,
        'total_study_time': 0,
        'current_streak': 0,
        'longest_streak': 0,
        'level': 1,
        'experience_points': 0,
      });

      // 5. Set Firebase Analytics user properties
      await _firebaseService.setUserProperties(
        userId: userId,
        userRole: role,
        subscriptionStatus: 'free',
      );

      // 6. Log signup event
      await _firebaseService.logEvent(
        name: 'sign_up',
        parameters: {'method': 'email', 'role': role},
      );

      debugPrint('✅ User created successfully: $email (Role: $role)');

      return {'success': true, 'user_id': userId, 'email': email, 'role': role};
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      return {'success': false, 'error': _getFirebaseErrorMessage(e.code)};
    } catch (e) {
      debugPrint('Sign up error: $e');
      return {
        'success': false,
        'error': 'Une erreur est survenue lors de l\'inscription',
      };
    }
  }

  /// Sign in with email and password
  static Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign in with Firebase
      final userCredential = await _firebaseService.auth
          .signInWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to sign in');
      }

      // 2. Get or create user in SQLite
      var localUser = await _db.getUserByFirebaseUid(firebaseUser.uid);

      if (localUser == null) {
        // User exists in Firebase but not in SQLite - create local record
        final now = DateTime.now().millisecondsSinceEpoch;
        await _db.upsertUser({
          'user_id': firebaseUser.uid,
          'firebase_uid': firebaseUser.uid,
          'email': firebaseUser.email,
          'display_name': firebaseUser.displayName ?? 'User',
          'role': 'student',
          'subscription_status': 'free',
          'created_at': now,
          'updated_at': now,
          'last_login': now,
        });

        localUser = await _db.getUserByFirebaseUid(firebaseUser.uid);
      } else {
        // Update last login
        await _db.updateUserLastLogin(localUser['user_id'] as String);
      }

      // 3. Log sign-in event
      await _firebaseService.logEvent(
        name: 'login',
        parameters: {
          'method': 'email',
          'role': localUser?['role'] ?? 'student',
        },
      );

      debugPrint('✅ User signed in: $email');

      return {
        'success': true,
        'user_id': localUser?['user_id'],
        'email': email,
        'role': localUser?['role'] ?? 'student',
        'display_name': localUser?['display_name'],
      };
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      return {'success': false, 'error': _getFirebaseErrorMessage(e.code)};
    } catch (e) {
      debugPrint('Sign in error: $e');
      return {
        'success': false,
        'error': 'Une erreur est survenue lors de la connexion',
      };
    }
  }

  /// Sign in with Google
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Implementation would use google_sign_in package
      // For now, return a placeholder
      return {'success': false, 'error': 'Connexion Google non implémentée'};
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return {
        'success': false,
        'error': 'Erreur lors de la connexion avec Google',
      };
    }
  }

  /// Sign in with Facebook
  static Future<Map<String, dynamic>> signInWithFacebook() async {
    try {
      // Implementation would use flutter_facebook_auth package
      // For now, return a placeholder
      return {'success': false, 'error': 'Connexion Facebook non implémentée'};
    } catch (e) {
      debugPrint('Facebook sign in error: $e');
      return {
        'success': false,
        'error': 'Erreur lors de la connexion avec Facebook',
      };
    }
  }

  /// Sign out
  static Future<Map<String, dynamic>> signOut() async {
    try {
      await _firebaseService.signOut();

      await _firebaseService.logEvent(name: 'logout');

      debugPrint('✅ User signed out');

      return {'success': true};
    } catch (e) {
      debugPrint('Sign out error: $e');
      return {'success': false, 'error': 'Erreur lors de la déconnexion'};
    }
  }

  /// Send password reset email
  static Future<Map<String, dynamic>> sendPasswordResetEmail(
    String email,
  ) async {
    try {
      await _firebaseService.auth.sendPasswordResetEmail(email: email);

      await _firebaseService.logEvent(
        name: 'password_reset_requested',
        parameters: {'email': email},
      );

      debugPrint('✅ Password reset email sent to: $email');

      return {
        'success': true,
        'message': 'Un email de réinitialisation a été envoyé à $email',
      };
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset error: ${e.code} - ${e.message}');
      return {'success': false, 'error': _getFirebaseErrorMessage(e.code)};
    } catch (e) {
      debugPrint('Password reset error: $e');
      return {'success': false, 'error': 'Erreur lors de l\'envoi de l\'email'};
    }
  }

  /// Get current user from SQLite
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseService.currentUser;
      if (firebaseUser == null) return null;

      return await _db.getUserByFirebaseUid(firebaseUser.uid);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  /// Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final firebaseUser = _firebaseService.currentUser;
      if (firebaseUser == null) {
        throw Exception('No authenticated user');
      }

      // Update Firebase profile
      if (displayName != null) {
        await firebaseUser.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await firebaseUser.updatePhotoURL(photoUrl);
      }

      // Update SQLite
      final now = DateTime.now().millisecondsSinceEpoch;
      await _db.upsertUser({
        'user_id': userId,
        'firebase_uid': firebaseUser.uid,
        'display_name': displayName ?? firebaseUser.displayName,
        'updated_at': now,
      });

      debugPrint('✅ User profile updated');

      return {'success': true};
    } catch (e) {
      debugPrint('Update profile error: $e');
      return {
        'success': false,
        'error': 'Erreur lors de la mise à jour du profil',
      };
    }
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return _firebaseService.isAuthenticated;
  }

  /// Get user role from local database
  static Future<String?> getUserRole(String userId) async {
    try {
      final user = await _db.getUserById(userId);
      return user?['role'] as String?;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }

  /// Update user subscription status
  static Future<void> updateSubscriptionStatus({
    required String userId,
    required String status,
    DateTime? expiresAt,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _db.upsertUser({
        'user_id': userId,
        'subscription_status': status,
        'subscription_expires_at': expiresAt?.millisecondsSinceEpoch,
        'updated_at': now,
      });

      await _firebaseService.setUserProperties(
        userId: userId,
        subscriptionStatus: status,
      );

      debugPrint('✅ Subscription updated: $status');
    } catch (e) {
      debugPrint('Error updating subscription: $e');
    }
  }

  /// Helper method to convert Firebase error codes to user-friendly messages
  static String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'invalid-email':
        return 'Email invalide';
      case 'weak-password':
        return 'Le mot de passe doit contenir au moins 6 caractères';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard';
      case 'network-request-failed':
        return 'Erreur de connexion. Vérifiez votre internet';
      default:
        return 'Une erreur est survenue. Veuillez réessayer';
    }
  }
}
