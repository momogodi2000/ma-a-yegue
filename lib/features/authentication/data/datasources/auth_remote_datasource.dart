import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/database/unified_database_service.dart';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';

/// Remote data source for authentication (HYBRID VERSION)
/// Uses Firebase Auth for authentication, SQLite for user profiles
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<AuthResponseModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  );
  Future<AuthResponseModel> signInWithGoogle();
  Future<AuthResponseModel> signInWithFacebook();
  Future<AuthResponseModel> signInWithApple();
  Future<String> signInWithPhoneNumber(String phoneNumber);
  Future<AuthResponseModel> verifyPhoneNumber(
    String verificationId,
    String smsCode,
  );
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel> updateUserProfile(UserModel user);
  Future<void> deleteUserAccount();
  Stream<UserModel?> get authStateChanges;
}

/// Hybrid implementation: Firebase Auth + SQLite profiles
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseService firebaseService;
  final UnifiedDatabaseService _db = UnifiedDatabaseService.instance;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseService,
    required this.googleSignIn,
  });

  /// Create or update user profile in SQLite
  Future<UserModel> _createOrUpdateUserProfile(
    User firebaseUser, {
    String? displayName,
    String? role,
    String? authProvider,
  }) async {
    final db = await _db.database;
    
    // Check if user exists in SQLite
    final existingUser = await _db.getUserByFirebaseUid(firebaseUser.uid);
    
    final userData = {
      'firebase_uid': firebaseUser.uid,
      'email': firebaseUser.email,
      'display_name': displayName ?? firebaseUser.displayName ?? 'User',
      'photo_url': firebaseUser.photoURL,
      'phone_number': firebaseUser.phoneNumber,
      'role': role ?? (existingUser?['role'] as String?) ?? 'learner',
      'auth_provider': authProvider ?? 'email',
      'is_active': 1,
      'is_email_verified': firebaseUser.emailVerified ? 1 : 0,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (existingUser == null) {
      // Create new user
      userData['created_at'] = DateTime.now().toIso8601String();
      userData['last_login_at'] = DateTime.now().toIso8601String();
      
      await db.insert('users', userData);
      
      return UserModel(
        id: firebaseUser.uid, // Use Firebase UID as ID
        email: firebaseUser.email ?? '',
        displayName: userData['display_name'] as String,
        photoUrl: firebaseUser.photoURL,
        phoneNumber: firebaseUser.phoneNumber,
        role: userData['role'] as String,
        isEmailVerified: firebaseUser.emailVerified,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    } else {
      // Update existing user
      userData['last_login_at'] = DateTime.now().toIso8601String();
      
      await db.update(
        'users',
        userData,
        where: 'firebase_uid = ?',
        whereArgs: [firebaseUser.uid],
      );
      
      // Fetch updated user
      final updated = await _db.getUserByFirebaseUid(firebaseUser.uid);
      return _userModelFromMap(updated!);
    }
  }

  /// Convert SQLite map to UserModel
  UserModel _userModelFromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['firebase_uid'] as String, // Use Firebase UID as ID
      email: data['email'] as String? ?? '',
      displayName: data['display_name'] as String? ?? 'User',
      photoUrl: data['photo_url'] as String?,
      phoneNumber: data['phone_number'] as String?,
      role: data['role'] as String? ?? 'learner',
      isEmailVerified: (data['is_email_verified'] as int?) == 1,
      createdAt: data['created_at'] != null 
          ? DateTime.parse(data['created_at'] as String)
          : DateTime.now(),
      lastLoginAt: data['last_login_at'] != null
          ? DateTime.parse(data['last_login_at'] as String)
          : null,
    );
  }

  @override
  Future<AuthResponseModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final userCredential = await firebaseService.auth
        .signInWithEmailAndPassword(email: email, password: password);

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Sign in failed: No user returned');
    }

    // Create/update user profile in SQLite
    final user = await _createOrUpdateUserProfile(firebaseUser);
    return AuthResponseModel(user: user);
  }

  @override
  Future<AuthResponseModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    final userCredential = await firebaseService.auth
        .createUserWithEmailAndPassword(email: email, password: password);

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Sign up failed: No user returned');
    }

    await firebaseUser.updateDisplayName(displayName);

    // Create user profile in SQLite with default role 'learner'
    final user = await _createOrUpdateUserProfile(
      firebaseUser,
      displayName: displayName,
      role: 'learner',
      authProvider: 'email',
    );

    return AuthResponseModel(user: user);
  }

  @override
  Future<AuthResponseModel> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google sign in cancelled');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await firebaseService.auth.signInWithCredential(
      credential,
    );

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Google sign-in failed: No user returned');
    }

    // Create/update user profile in SQLite
    final user = await _createOrUpdateUserProfile(
      firebaseUser,
      authProvider: 'google',
    );

    return AuthResponseModel(user: user);
  }

  @override
  Future<AuthResponseModel> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status != LoginStatus.success) {
      throw Exception('Facebook sign in failed: ${result.message}');
    }

    final OAuthCredential credential = FacebookAuthProvider.credential(
      result.accessToken!.token,
    );
    final userCredential = await firebaseService.auth.signInWithCredential(
      credential,
    );

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Facebook sign-in failed: No user returned');
    }

    // Create/update user profile in SQLite
    final user = await _createOrUpdateUserProfile(
      firebaseUser,
      authProvider: 'facebook',
    );

    return AuthResponseModel(user: user);
  }

  @override
  Future<AuthResponseModel> signInWithApple() async {
    // Temporarily disabled due to plugin compatibility issues
    throw Exception('Apple sign-in temporarily disabled');
  }

  @override
  Future<String> signInWithPhoneNumber(String phoneNumber) async {
    final completer = Completer<String>();

    await firebaseService.auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval on Android
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          completer.completeError(
            Exception('The phone number entered is invalid.'),
          );
        } else {
          completer.completeError(
            Exception('Phone verification failed: ${e.message}'),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  @override
  Future<AuthResponseModel> verifyPhoneNumber(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await firebaseService.auth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw Exception('Phone verification failed: No user returned');
      }

      final firebaseUser = userCredential.user!;

      // Create/update user profile in SQLite
      final user = await _createOrUpdateUserProfile(
        firebaseUser,
        authProvider: 'phone',
      );

      return AuthResponseModel(
        success: true,
        user: user,
        message: 'Phone verification successful',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw Exception('The verification code entered is invalid.');
      } else if (e.code == 'session-expired') {
        throw Exception(
          'The verification code has expired. Please request a new code.',
        );
      } else {
        throw Exception('Phone verification failed: ${e.message}');
      }
    }
  }

  @override
  Future<void> signOut() async {
    await firebaseService.auth.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = firebaseService.auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      // Fetch user profile from SQLite
      final userData = await _db.getUserByFirebaseUid(firebaseUser.uid);

      if (userData != null) {
        return _userModelFromMap(userData);
      } else {
        // User exists in Firebase Auth but not in SQLite - create profile
        return await _createOrUpdateUserProfile(firebaseUser);
      }
    } catch (e) {
      // On error, create basic profile
      return await _createOrUpdateUserProfile(firebaseUser);
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return firebaseService.auth.currentUser != null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await firebaseService.auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    final firebaseUser = firebaseService.auth.currentUser;
    if (firebaseUser == null) throw Exception('No authenticated user');

    // Update Firebase Auth profile
    await firebaseUser.updateDisplayName(user.displayName);
    if (user.photoUrl != null) {
      await firebaseUser.updatePhotoURL(user.photoUrl);
    }

    // Update SQLite profile
    final db = await _db.database;
    await db.update(
      'users',
      {
        'display_name': user.displayName,
        'photo_url': user.photoUrl,
        'phone_number': user.phoneNumber,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'firebase_uid = ?',
      whereArgs: [user.id], // user.id is the Firebase UID
    );

    return user;
  }

  @override
  Future<void> deleteUserAccount() async {
    final firebaseUser = firebaseService.auth.currentUser;
    if (firebaseUser == null) throw Exception('No authenticated user');

    // Delete from SQLite
    final db = await _db.database;
    await db.delete(
      'users',
      where: 'firebase_uid = ?',
      whereArgs: [firebaseUser.uid],
    );

    // Delete from Firebase Auth
    await firebaseUser.delete();
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseService.auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      try {
        final userData = await _db.getUserByFirebaseUid(firebaseUser.uid);
        if (userData != null) {
          return _userModelFromMap(userData);
        } else {
          return await _createOrUpdateUserProfile(firebaseUser);
        }
      } catch (e) {
        return UserModel.fromFirebaseUser(firebaseUser);
      }
    });
  }
}
