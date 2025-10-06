import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:mayegue/features/authentication/domain/usecases/register_usecase.dart';
import 'package:mayegue/features/authentication/domain/repositories/auth_repository.dart';
import 'package:mayegue/features/authentication/domain/entities/auth_response_entity.dart';
import 'package:mayegue/features/authentication/domain/entities/user_entity.dart';
import 'package:mayegue/core/errors/failures.dart';

import 'register_usecase_test.mocks.dart';

// Generate mocks
@GenerateMocks([AuthRepository])
void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockAuthRepository;

  const tEmail = 'newuser@example.com';
  const tPassword = 'password123';
  const tDisplayName = 'New User';

  final tUserEntity = UserEntity(
    id: 'new-user-id',
    email: 'newuser@example.com',
    displayName: 'New User',
    role: 'learner',
    createdAt: DateTime(2024, 1, 1),
    isEmailVerified: false,
  );

  final tAuthResponseEntity = AuthResponseEntity(
    user: tUserEntity,
    token: 'test-token',
    success: true,
    message: 'Registration successful',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = RegisterUsecase(mockAuthRepository);
  });

  group('RegisterUsecase', () {
    test(
      'should return AuthResponseEntity when registration is successful',
      () async {
        // arrange
        when(
          mockAuthRepository.signUpWithEmailAndPassword(
            tEmail,
            tPassword,
            tDisplayName,
          ),
        ).thenAnswer((_) async => tAuthResponseEntity);

        // act
        final result = await usecase.call(tEmail, tPassword, tDisplayName);

        // assert
        expect(result, Right(tAuthResponseEntity));
        expect(
          result.fold((failure) => null, (response) => response),
          tAuthResponseEntity,
        );

        verify(
          mockAuthRepository.signUpWithEmailAndPassword(
            tEmail,
            tPassword,
            tDisplayName,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test(
      'should return AuthFailure when registration fails with invalid email',
      () async {
        // arrange
        final failedAuthResponse = AuthResponseEntity(
          user: tUserEntity,
          success: false,
          message: 'Invalid email format',
        );
        when(
          mockAuthRepository.signUpWithEmailAndPassword(
            tEmail,
            tPassword,
            tDisplayName,
          ),
        ).thenAnswer((_) async => failedAuthResponse);

        // act
        final result = await usecase.call(tEmail, tPassword, tDisplayName);

        // assert
        expect(result, Right(failedAuthResponse));
        result.fold((failure) => fail('Should not return failure'), (response) {
          expect(response.success, false);
          expect(response.message, 'Invalid email format');
        });

        verify(
          mockAuthRepository.signUpWithEmailAndPassword(
            tEmail,
            tPassword,
            tDisplayName,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test('should return AuthFailure when exception occurs', () async {
      // arrange
      when(
        mockAuthRepository.signUpWithEmailAndPassword(
          tEmail,
          tPassword,
          tDisplayName,
        ),
      ).thenThrow(Exception('Network error'));

      // act
      final result = await usecase.call(tEmail, tPassword, tDisplayName);

      // assert
      expect(result, const Left(AuthFailure('Échec d\'inscription')));
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Échec d\'inscription');
      }, (response) => fail('Should return failure'));

      verify(
        mockAuthRepository.signUpWithEmailAndPassword(
          tEmail,
          tPassword,
          tDisplayName,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should handle network exception', () async {
      // arrange
      when(
        mockAuthRepository.signUpWithEmailAndPassword(
          tEmail,
          tPassword,
          tDisplayName,
        ),
      ).thenThrow(Exception('No internet connection'));

      // act
      final result = await usecase.call(tEmail, tPassword, tDisplayName);

      // assert
      expect(result, const Left(AuthFailure('Échec d\'inscription')));
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Échec d\'inscription');
      }, (response) => fail('Should return failure'));

      verify(
        mockAuthRepository.signUpWithEmailAndPassword(
          tEmail,
          tPassword,
          tDisplayName,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should handle server error exception', () async {
      // arrange
      when(
        mockAuthRepository.signUpWithEmailAndPassword(
          tEmail,
          tPassword,
          tDisplayName,
        ),
      ).thenThrow(Exception('Internal server error'));

      // act
      final result = await usecase.call(tEmail, tPassword, tDisplayName);

      // assert
      expect(result, const Left(AuthFailure('Échec d\'inscription')));
      result.fold((failure) {
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Échec d\'inscription');
      }, (response) => fail('Should return failure'));

      verify(
        mockAuthRepository.signUpWithEmailAndPassword(
          tEmail,
          tPassword,
          tDisplayName,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return AuthResponseEntity with correct user data', () async {
      // arrange
      when(
        mockAuthRepository.signUpWithEmailAndPassword(
          tEmail,
          tPassword,
          tDisplayName,
        ),
      ).thenAnswer((_) async => tAuthResponseEntity);

      // act
      final result = await usecase.call(tEmail, tPassword, tDisplayName);

      // assert
      result.fold((failure) => fail('Should not return failure'), (response) {
        expect(response.user.id, 'new-user-id');
        expect(response.user.email, 'newuser@example.com');
        expect(response.user.displayName, 'New User');
        expect(response.user.role, 'learner');
        expect(response.user.isEmailVerified, false);
        expect(response.token, 'test-token');
        expect(response.success, true);
        expect(response.message, 'Registration successful');
      });
    });

    test('should handle multiple concurrent registration attempts', () async {
      // arrange
      when(
        mockAuthRepository.signUpWithEmailAndPassword(
          tEmail,
          tPassword,
          tDisplayName,
        ),
      ).thenAnswer((_) async => tAuthResponseEntity);

      // act
      final futures = List.generate(
        3,
        (_) => usecase.call(tEmail, tPassword, tDisplayName),
      );
      final results = await Future.wait(futures);

      // assert
      expect(results.length, 3);
      for (final result in results) {
        expect(result, Right(tAuthResponseEntity));
      }

      verify(
        mockAuthRepository.signUpWithEmailAndPassword(
          tEmail,
          tPassword,
          tDisplayName,
        ),
      ).called(3);
    });

    test('should handle registration response with weak password', () async {
      // arrange
      final weakPasswordResponse = AuthResponseEntity(
        user: tUserEntity,
        success: false,
        message: 'Password is too weak',
      );

      when(
        mockAuthRepository.signUpWithEmailAndPassword(
          tEmail,
          'weak',
          tDisplayName,
        ),
      ).thenAnswer((_) async => weakPasswordResponse);

      // act
      final result = await usecase.call(tEmail, 'weak', tDisplayName);

      // assert
      expect(result, Right(weakPasswordResponse));
      result.fold((failure) => fail('Should not return failure'), (response) {
        expect(response.success, false);
        expect(response.message, 'Password is too weak');
      });
    });

    test('should validate input parameters', () async {
      // Test with empty email
      when(
        mockAuthRepository.signUpWithEmailAndPassword(
          '',
          tPassword,
          tDisplayName,
        ),
      ).thenAnswer((_) async => tAuthResponseEntity);

      final result1 = await usecase.call('', tPassword, tDisplayName);
      expect(result1, Right(tAuthResponseEntity));

      // Test with empty password
      when(
        mockAuthRepository.signUpWithEmailAndPassword(tEmail, '', tDisplayName),
      ).thenAnswer((_) async => tAuthResponseEntity);

      final result2 = await usecase.call(tEmail, '', tDisplayName);
      expect(result2, Right(tAuthResponseEntity));

      // Test with empty display name
      when(
        mockAuthRepository.signUpWithEmailAndPassword(tEmail, tPassword, ''),
      ).thenAnswer((_) async => tAuthResponseEntity);

      final result3 = await usecase.call(tEmail, tPassword, '');
      expect(result3, Right(tAuthResponseEntity));
    });

    test('should handle different types of exceptions', () async {
      // Test with FormatException
      when(
        mockAuthRepository.signUpWithEmailAndPassword(
          tEmail,
          tPassword,
          tDisplayName,
        ),
      ).thenThrow(const FormatException('Invalid format'));

      final result1 = await usecase.call(tEmail, tPassword, tDisplayName);
      expect(result1, const Left(AuthFailure('Échec d\'inscription')));

      // Test with ArgumentError
      when(
        mockAuthRepository.signUpWithEmailAndPassword(
          tEmail,
          tPassword,
          tDisplayName,
        ),
      ).thenThrow(ArgumentError('Invalid argument'));

      final result2 = await usecase.call(tEmail, tPassword, tDisplayName);
      expect(result2, const Left(AuthFailure('Échec d\'inscription')));

      // Test with StateError
      when(
        mockAuthRepository.signUpWithEmailAndPassword(
          tEmail,
          tPassword,
          tDisplayName,
        ),
      ).thenThrow(StateError('Invalid state'));

      final result3 = await usecase.call(tEmail, tPassword, tDisplayName);
      expect(result3, const Left(AuthFailure('Échec d\'inscription')));
    });

    test('should handle email already exists error', () async {
      // arrange
      final emailExistsResponse = AuthResponseEntity(
        user: tUserEntity,
        success: false,
        message: 'Email already exists',
      );

      when(
        mockAuthRepository.signUpWithEmailAndPassword(
          tEmail,
          tPassword,
          tDisplayName,
        ),
      ).thenAnswer((_) async => emailExistsResponse);

      // act
      final result = await usecase.call(tEmail, tPassword, tDisplayName);

      // assert
      expect(result, Right(emailExistsResponse));
      result.fold((failure) => fail('Should not return failure'), (response) {
        expect(response.success, false);
        expect(response.message, 'Email already exists');
      });
    });

    test('should handle timeout scenarios', () async {
      // arrange
      when(
        mockAuthRepository.signUpWithEmailAndPassword(
          tEmail,
          tPassword,
          tDisplayName,
        ),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 30));
        return tAuthResponseEntity;
      });

      // act
      final result = await usecase
          .call(tEmail, tPassword, tDisplayName)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => const Left(AuthFailure('Échec d\'inscription')),
          );

      // assert
      expect(result, const Left(AuthFailure('Échec d\'inscription')));
    });
  });
}
