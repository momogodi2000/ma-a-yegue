import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:maa_yegue/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:maa_yegue/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:maa_yegue/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:maa_yegue/features/authentication/data/models/user_model.dart';
import 'package:maa_yegue/features/authentication/data/models/auth_response_model.dart';
import 'package:maa_yegue/core/sync/general_sync_manager.dart';

import 'auth_repository_impl_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  AuthRemoteDataSource,
  AuthLocalDataSource,
  Connectivity,
  GeneralSyncManager,
])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockConnectivity mockConnectivity;
  late MockGeneralSyncManager mockSyncManager;

  final tUserModel = UserModel(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    role: 'learner',
    createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
    isEmailVerified: true,
  );

  final tAuthResponseModel = AuthResponseModel(
    user: tUserModel,
    token: 'test-token',
    success: true,
    message: 'Success',
  );

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockConnectivity = MockConnectivity();
    mockSyncManager = MockGeneralSyncManager();

    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      connectivity: mockConnectivity,
      syncManager: mockSyncManager,
    );
  });

  group('AuthRepositoryImpl - Sign In with Email and Password', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    test('should sign in with remote data source when online', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.signInWithEmailAndPassword(tEmail, tPassword))
          .thenAnswer((_) async => tAuthResponseModel);
      when(mockLocalDataSource.cacheUser(any)).thenAnswer((_) async => {});

      // act
      final result =
          await repository.signInWithEmailAndPassword(tEmail, tPassword);

      // assert
      expect(result, tAuthResponseModel);
      expect(result.success, true);
      expect(result.user.email, tEmail);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockRemoteDataSource.signInWithEmailAndPassword(tEmail, tPassword))
          .called(1);
      verify(mockLocalDataSource.cacheUser(tUserModel)).called(1);
    });

    test('should return error when offline', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      // act
      final result =
          await repository.signInWithEmailAndPassword(tEmail, tPassword);

      // assert
      expect(result.success, false);
      expect(
        result.message,
        'Internet connection required for authentication',
      );
      verify(mockConnectivity.checkConnectivity()).called(1);
      verifyNever(mockRemoteDataSource.signInWithEmailAndPassword(any, any));
    });
  });

  group('AuthRepositoryImpl - Sign Up with Email and Password', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tDisplayName = 'Test User';

    test('should sign up with remote data source when online', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.signUpWithEmailAndPassword(
        tEmail,
        tPassword,
        tDisplayName,
      )).thenAnswer((_) async => tAuthResponseModel);
      when(mockLocalDataSource.cacheUser(any)).thenAnswer((_) async => {});

      // act
      final result = await repository.signUpWithEmailAndPassword(
        tEmail,
        tPassword,
        tDisplayName,
      );

      // assert
      expect(result, tAuthResponseModel);
      expect(result.success, true);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockRemoteDataSource.signUpWithEmailAndPassword(
        tEmail,
        tPassword,
        tDisplayName,
      )).called(1);
      verify(mockLocalDataSource.cacheUser(tUserModel)).called(1);
    });

    test('should return error when offline', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      // act
      final result = await repository.signUpWithEmailAndPassword(
        tEmail,
        tPassword,
        tDisplayName,
      );

      // assert
      expect(result.success, false);
      expect(result.message, 'Internet connection required for registration');
      verify(mockConnectivity.checkConnectivity()).called(1);
      verifyNever(mockRemoteDataSource.signUpWithEmailAndPassword(
        any,
        any,
        any,
      ));
    });
  });

  group('AuthRepositoryImpl - OAuth Sign In', () {
    test('should sign in with Google when online', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.signInWithGoogle())
          .thenAnswer((_) async => tAuthResponseModel);
      when(mockLocalDataSource.cacheUser(any)).thenAnswer((_) async => {});

      // act
      final result = await repository.signInWithGoogle();

      // assert
      expect(result, tAuthResponseModel);
      expect(result.success, true);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockRemoteDataSource.signInWithGoogle()).called(1);
      verify(mockLocalDataSource.cacheUser(tUserModel)).called(1);
    });

    test('should return error when offline for Google sign in', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      // act
      final result = await repository.signInWithGoogle();

      // assert
      expect(result.success, false);
      expect(
        result.message,
        'Internet connection required for Google authentication',
      );
      verify(mockConnectivity.checkConnectivity()).called(1);
      verifyNever(mockRemoteDataSource.signInWithGoogle());
    });
  });

  group('AuthRepositoryImpl - Get Current User', () {
    test('should get current user from remote when available', () async {
      // arrange
      when(mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => tUserModel);
      when(mockLocalDataSource.cacheUser(any)).thenAnswer((_) async => {});

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, tUserModel);
      verify(mockRemoteDataSource.getCurrentUser()).called(1);
      verify(mockLocalDataSource.cacheUser(tUserModel)).called(1);
    });

    test('should return cached user when remote fails', () async {
      // arrange
      when(mockRemoteDataSource.getCurrentUser())
          .thenThrow(Exception('Network error'));
      when(mockLocalDataSource.getCachedUser())
          .thenAnswer((_) async => tUserModel);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, tUserModel);
      verify(mockRemoteDataSource.getCurrentUser()).called(1);
      verify(mockLocalDataSource.getCachedUser()).called(1);
    });

    test('should return null when no user is available', () async {
      // arrange
      when(mockRemoteDataSource.getCurrentUser())
          .thenThrow(Exception('Network error'));
      when(mockLocalDataSource.getCachedUser()).thenAnswer((_) async => null);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, null);
      verify(mockRemoteDataSource.getCurrentUser()).called(1);
      verify(mockLocalDataSource.getCachedUser()).called(1);
    });
  });

  group('AuthRepositoryImpl - Sign Out', () {
    test('should sign out and clear local data', () async {
      // arrange
      when(mockRemoteDataSource.signOut()).thenAnswer((_) async => {});
      when(mockLocalDataSource.clearAuthData()).thenAnswer((_) async => {});

      // act
      await repository.signOut();

      // assert
      verify(mockRemoteDataSource.signOut()).called(1);
      verify(mockLocalDataSource.clearAuthData()).called(1);
    });
  });

  group('AuthRepositoryImpl - Update User Profile', () {
    test('should update user profile when online', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.updateUserProfile(any))
          .thenAnswer((_) async => tUserModel);
      when(mockLocalDataSource.cacheUser(any)).thenAnswer((_) async => {});

      // act
      final result = await repository.updateUserProfile(tUserModel);

      // assert
      expect(result, tUserModel);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockRemoteDataSource.updateUserProfile(any)).called(1);
      verify(mockLocalDataSource.cacheUser(tUserModel)).called(1);
    });

    test('should throw exception when offline', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      // act & assert
      expect(
        () => repository.updateUserProfile(tUserModel),
        throwsA(isA<Exception>()),
      );
      verify(mockConnectivity.checkConnectivity()).called(1);
      verifyNever(mockRemoteDataSource.updateUserProfile(any));
    });
  });

  group('AuthRepositoryImpl - Password Reset', () {
    const tEmail = 'test@example.com';

    test('should send password reset email when online', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.sendPasswordResetEmail(tEmail))
          .thenAnswer((_) async => {});

      // act
      await repository.sendPasswordResetEmail(tEmail);

      // assert
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockRemoteDataSource.sendPasswordResetEmail(tEmail)).called(1);
    });

    test('should throw exception when offline', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      // act & assert
      expect(
        () => repository.sendPasswordResetEmail(tEmail),
        throwsA(isA<Exception>()),
      );
      verify(mockConnectivity.checkConnectivity()).called(1);
      verifyNever(mockRemoteDataSource.sendPasswordResetEmail(any));
    });
  });
}
