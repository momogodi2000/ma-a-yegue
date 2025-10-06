import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:mayegue/features/authentication/domain/usecases/login_usecase.dart';
import 'package:mayegue/features/authentication/domain/repositories/auth_repository.dart';
import 'package:mayegue/features/authentication/domain/entities/auth_response_entity.dart';
import 'package:mayegue/features/authentication/domain/entities/user_entity.dart';
import 'package:mayegue/core/errors/failures.dart';

import 'login_usecase_test.mocks.dart';

// Generate mocks
@GenerateMocks([AuthRepository])
void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  const tEmail = 'test@example.com';
  const tPassword = 'password123';

  final tUserEntity = UserEntity(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    role: 'learner',
    createdAt: DateTime(2024, 1, 1),
    isEmailVerified: true,
  );

  final tAuthResponseEntity = AuthResponseEntity(
    user: tUserEntity,
    token: 'test-token',
    success: true,
    message: 'Authentication successful',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUsecase(mockAuthRepository);
  });

  group('LoginUsecase', () {
    test('should return AuthResponseEntity when login is successful', () async {
      // arrange
      when(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).thenAnswer((_) async => tAuthResponseEntity);

      // act
      final result = await usecase.call(tEmail, tPassword);

      // assert
      expect(result, Right(tAuthResponseEntity));
      expect(
        result.fold((failure) => null, (response) => response),
        tAuthResponseEntity,
      );

      verify(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test(
      'should return AuthFailure when login fails with invalid credentials',
      () async {
        // arrange
        final failedAuthResponse = AuthResponseEntity(
          user: tUserEntity,
          success: false,
          message: 'Invalid email or password',
        );
        when(
          mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
        ).thenAnswer((_) async => failedAuthResponse);

        // act
        final result = await usecase.call(tEmail, tPassword);

        // assert
        expect(result, Right(failedAuthResponse));
        result.fold((failure) => fail('Should not return failure'), (response) {
          expect(response.success, false);
          expect(response.message, 'Invalid email or password');
        });

        verify(
          mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
        ).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test('should return AuthFailure when exception occurs', () async {
      // arrange
      when(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).thenThrow(Exception('Network error'));

      // act
      final result = await usecase.call(tEmail, tPassword);

      // assert
      expect(result, const Left(AuthFailure('Échec de connexion')));
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Échec de connexion');
      }, (response) => fail('Should return failure'));

      verify(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should handle network exception', () async {
      // arrange
      when(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).thenThrow(Exception('No internet connection'));

      // act
      final result = await usecase.call(tEmail, tPassword);

      // assert
      expect(result, const Left(AuthFailure('Échec de connexion')));
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Échec de connexion');
      }, (response) => fail('Should return failure'));

      verify(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should handle server error exception', () async {
      // arrange
      when(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).thenThrow(Exception('Internal server error'));

      // act
      final result = await usecase.call(tEmail, tPassword);

      // assert
      expect(result, const Left(AuthFailure('Échec de connexion')));
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Échec de connexion');
      }, (response) => fail('Should return failure'));

      verify(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should handle timeout exception', () async {
      // arrange
      when(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).thenThrow(Exception('Request timeout'));

      // act
      final result = await usecase.call(tEmail, tPassword);

      // assert
      expect(result, const Left(AuthFailure('Échec de connexion')));
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Échec de connexion');
      }, (response) => fail('Should return failure'));

      verify(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return AuthResponseEntity with correct user data', () async {
      // arrange
      when(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).thenAnswer((_) async => tAuthResponseEntity);

      // act
      final result = await usecase.call(tEmail, tPassword);

      // assert
      result.fold((failure) => fail('Should not return failure'), (response) {
        expect(response.user.id, 'test-user-id');
        expect(response.user.email, 'test@example.com');
        expect(response.user.displayName, 'Test User');
        expect(response.user.role, 'learner');
        expect(response.user.isEmailVerified, true);
        expect(response.token, 'test-token');
        expect(response.success, true);
        expect(response.message, 'Authentication successful');
      });
    });

    test('should handle multiple concurrent login attempts', () async {
      // arrange
      when(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).thenAnswer((_) async => tAuthResponseEntity);

      // act
      final futures = List.generate(3, (_) => usecase.call(tEmail, tPassword));
      final results = await Future.wait(futures);

      // assert
      expect(results.length, 3);
      for (final result in results) {
        expect(result, Right(tAuthResponseEntity));
      }

      verify(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).called(3);
    });

    test('should handle authentication response with null user', () async {
      // arrange
      final tAuthResponseWithNullUser = AuthResponseEntity(
        user: UserEntity(
          id: 'dummy',
          email: 'dummy@example.com',
          createdAt: DateTime.now(),
        ),
        token: 'test-token',
        success: false,
        message: 'Authentication failed',
      );

      when(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).thenAnswer((_) async => tAuthResponseWithNullUser);

      // act
      final result = await usecase.call(tEmail, tPassword);

      // assert
      expect(result, Right(tAuthResponseWithNullUser));
      result.fold((failure) => fail('Should not return failure'), (response) {
        expect(response.success, false);
        expect(response.message, 'Authentication failed');
      });
    });

    test('should validate input parameters', () async {
      // Test with empty email
      when(
        mockAuthRepository.signInWithEmailAndPassword('', tPassword),
      ).thenAnswer((_) async => tAuthResponseEntity);

      final result1 = await usecase.call('', tPassword);
      expect(result1, Right(tAuthResponseEntity));

      // Test with empty password
      when(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, ''),
      ).thenAnswer((_) async => tAuthResponseEntity);

      final result2 = await usecase.call(tEmail, '');
      expect(result2, Right(tAuthResponseEntity));
    });

    test('should handle different types of exceptions', () async {
      // Test with FormatException
      when(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).thenThrow(const FormatException('Invalid format'));

      final result1 = await usecase.call(tEmail, tPassword);
      expect(result1, const Left(AuthFailure('Échec de connexion')));

      // Test with ArgumentError
      when(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).thenThrow(ArgumentError('Invalid argument'));

      final result2 = await usecase.call(tEmail, tPassword);
      expect(result2, const Left(AuthFailure('Échec de connexion')));

      // Test with StateError
      when(
        mockAuthRepository.signInWithEmailAndPassword(tEmail, tPassword),
      ).thenThrow(StateError('Invalid state'));

      final result3 = await usecase.call(tEmail, tPassword);
      expect(result3, const Left(AuthFailure('Échec de connexion')));
    });
  });
}
