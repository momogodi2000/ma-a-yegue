import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/sync/general_sync_manager.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_response_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

/// Implementation of AuthRepository
/// Uses Firebase as the single source of truth for user data
/// Local cache is only used for session management and quick access
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final Connectivity connectivity;
  final GeneralSyncManager syncManager;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
    required this.syncManager,
  });

  /// Helper method to check if device is offline
  Future<bool> _isOffline() async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult == ConnectivityResult.none;
  }

  /// Helper method to create offline error response
  AuthResponseEntity _createOfflineErrorResponse(
    String message, {
    String? email,
  }) {
    final dummyUser = UserEntity(
      id: 'offline',
      email: email ?? 'offline@example.com',
      createdAt: DateTime.now(),
    );
    return AuthResponseEntity(
      user: dummyUser,
      success: false,
      message: message,
    );
  }

  /// Helper method to handle successful authentication and cache
  Future<void> _handleSuccessfulAuth(AuthResponseEntity result) async {
    if (result.success) {
      // Cache user data for quick access
      await localDataSource.cacheUser(result.user);
    }
  }

  @override
  Future<AuthResponseEntity> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (await _isOffline()) {
      return _createOfflineErrorResponse(
        'Internet connection required for authentication',
        email: email,
      );
    }

    // Always authenticate with Firebase
    final result = await remoteDataSource.signInWithEmailAndPassword(
      email,
      password,
    );
    await _handleSuccessfulAuth(result);
    return result;
  }

  @override
  Future<AuthResponseEntity> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    if (await _isOffline()) {
      return _createOfflineErrorResponse(
        'Internet connection required for registration',
        email: email,
      );
    }

    final result = await remoteDataSource.signUpWithEmailAndPassword(
      email,
      password,
      displayName,
    );

    if (result.success) {
      await localDataSource.cacheUser(result.user);
    }

    return result;
  }

  @override
  Future<AuthResponseEntity> signInWithGoogle() async {
    return _handleOAuthSignIn(
      () => remoteDataSource.signInWithGoogle(),
      'Google',
    );
  }

  @override
  Future<AuthResponseEntity> signInWithFacebook() async {
    return _handleOAuthSignIn(
      () => remoteDataSource.signInWithFacebook(),
      'Facebook',
    );
  }

  @override
  Future<AuthResponseEntity> signInWithApple() async {
    return _handleOAuthSignIn(
      () => remoteDataSource.signInWithApple(),
      'Apple',
    );
  }

  /// Helper method for OAuth sign-in
  Future<AuthResponseEntity> _handleOAuthSignIn(
    Future<AuthResponseEntity> Function() signInMethod,
    String provider,
  ) async {
    if (await _isOffline()) {
      return _createOfflineErrorResponse(
        'Internet connection required for $provider authentication',
      );
    }

    final result = await signInMethod();
    if (result.success) {
      await localDataSource.cacheUser(result.user);
    }

    return result;
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
    await localDataSource.clearAuthData();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // Try to get from Firebase (always the source of truth)
    try {
      final remoteUser = await remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        // Update cache with fresh data
        await localDataSource.cacheUser(remoteUser);
        return remoteUser;
      }
    } catch (e) {
      // If Firebase fails, try cache
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return cachedUser;
      }
    }

    return null;
  }

  @override
  Future<bool> isAuthenticated() async {
    return await remoteDataSource.isAuthenticated();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (await _isOffline()) {
      throw Exception('Internet connection required for password reset');
    }
    await remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<UserEntity> updateUserProfile(UserEntity user) async {
    if (await _isOffline()) {
      throw Exception('Internet connection required to update profile');
    }

    // Convert to UserModel for remote data source
    final userModel = UserModel.fromEntity(user);

    // Update in Firebase (source of truth)
    final updatedUser = await remoteDataSource.updateUserProfile(userModel);

    // Update cache
    await localDataSource.cacheUser(updatedUser);

    return updatedUser;
  }

  @override
  Future<void> deleteUserAccount() async {
    if (await _isOffline()) {
      throw Exception('Internet connection required to delete account');
    }

    await remoteDataSource.deleteUserAccount();
    await localDataSource.clearAuthData();
  }

  @override
  Stream<UserEntity?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  Future<AuthResponseEntity> signInWithPhoneNumber(String phoneNumber) async {
    if (await _isOffline()) {
      return _createOfflineErrorResponse(
        'Internet connection required for phone authentication',
      );
    }

    // Note: Phone authentication returns a verification ID, not a full auth response
    // The actual authentication happens in verifyPhoneNumber
    try {
      final verificationId = await remoteDataSource.signInWithPhoneNumber(
        phoneNumber,
      );

      // Return a temporary response indicating OTP was sent
      final tempUser = UserEntity(
        id: 'pending_verification',
        email: phoneNumber,
        createdAt: DateTime.now(),
      );

      return AuthResponseEntity(
        user: tempUser,
        success: true,
        message: 'OTP sent to $phoneNumber. Verification ID: $verificationId',
      );
    } catch (e) {
      return _createOfflineErrorResponse('Failed to send OTP: $e');
    }
  }

  @override
  Future<AuthResponseEntity> verifyPhoneNumber(
    String verificationId,
    String smsCode,
  ) async {
    if (await _isOffline()) {
      return _createOfflineErrorResponse(
        'Internet connection required for phone verification',
      );
    }

    final result = await remoteDataSource.verifyPhoneNumber(
      verificationId,
      smsCode,
    );
    if (result.success) {
      await localDataSource.cacheUser(result.user);
    }

    return result;
  }
}
