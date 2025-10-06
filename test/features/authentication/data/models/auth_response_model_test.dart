import 'package:flutter_test/flutter_test.dart';
import 'package:mayegue/features/authentication/data/models/auth_response_model.dart';
import 'package:mayegue/features/authentication/data/models/user_model.dart';
import 'package:mayegue/features/authentication/domain/entities/auth_response_entity.dart';

void main() {
  group('AuthResponseModel', () {
    final tUserModel = UserModel(
      id: 'test-id',
      email: 'test@example.com',
      displayName: 'Test User',
      role: 'learner',
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      isEmailVerified: true,
    );

    final tAuthResponseModel = AuthResponseModel(
      user: tUserModel,
      token: 'test-token-123',
      refreshToken: 'refresh-token-456',
      success: true,
      message: 'Authentication successful',
      expiresAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
    );

    group('fromJson', () {
      test('should return a valid AuthResponseModel when JSON is valid', () {
        // arrange
        final json = {
          'user': {
            'id': 'test-id',
            'email': 'test@example.com',
            'displayName': 'Test User',
            'role': 'learner',
            'createdAt': '2024-01-01T00:00:00.000Z',
            'isEmailVerified': true,
          },
          'token': 'test-token-123',
          'refreshToken': 'refresh-token-456',
          'success': true,
          'message': 'Authentication successful',
          'expiresAt': '2024-01-02T00:00:00.000Z',
        };

        // act
        final result = AuthResponseModel.fromJson(json);

        // assert
        expect(result, tAuthResponseModel);
      });

      test(
        'should return a AuthResponseModel with default values when JSON has missing fields',
        () {
          // arrange
          final json = {
            'user': {
              'id': 'test-id',
              'email': 'test@example.com',
              'displayName': 'Test User',
              'role': 'learner',
              'createdAt': '2024-01-01T00:00:00.000Z',
            },
            'success': true,
          };

          // act
          final result = AuthResponseModel.fromJson(json);

          // assert
          expect(result.user.id, 'test-id');
          expect(result.token, null);
          expect(result.refreshToken, null);
          expect(result.success, true);
          expect(result.message, null);
          expect(result.expiresAt, null);
        },
      );

      test('should handle null user in JSON', () {
        // arrange
        final json = {
          'user': null,
          'success': false,
          'message': 'Authentication failed',
        };

        // act
        final result = AuthResponseModel.fromJson(json);

        // assert
        expect(result.user, null);
        expect(result.success, false);
        expect(result.message, 'Authentication failed');
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // act
        final result = tAuthResponseModel.toJson();

        // assert
        expect(result['user'], isA<Map<String, dynamic>>());
        expect(result['token'], 'test-token-123');
        expect(result['refreshToken'], 'refresh-token-456');
        expect(result['success'], true);
        expect(result['message'], 'Authentication successful');
        expect(result['expiresAt'], '2024-01-02T00:00:00.000Z');
      });

      test('should handle null user in JSON conversion', () {
        // arrange
        final authResponseModel = AuthResponseModel(
          user: tUserModel,
          token: 'test-token',
          success: false,
          message: 'Authentication failed',
        );

        // act
        final result = authResponseModel.toJson();

        // assert
        expect(result['user'], null);
        expect(result['token'], 'test-token');
        expect(result['success'], false);
        expect(result['message'], 'Authentication failed');
      });
    });

    group('toEntity', () {
      test('should return a valid AuthResponseEntity', () {
        // act
        final result = tAuthResponseModel.toEntity();

        // assert
        expect(result, isA<AuthResponseEntity>());
        expect(result.user.id, 'test-id');
        expect(result.user.email, 'test@example.com');
        expect(result.token, 'test-token-123');
        expect(result.refreshToken, 'refresh-token-456');
        expect(result.success, true);
        expect(result.message, 'Authentication successful');
        expect(result.expiresAt, isA<DateTime>());
      });

      test(
        'should return AuthResponseEntity with null user when user is null',
        () {
          // arrange
          final authResponseModel = AuthResponseModel(
            user: tUserModel,
            token: 'test-token',
            success: false,
            message: 'Authentication failed',
          );

          // act
          final result = authResponseModel.toEntity();

          // assert
          expect(result.user, null);
          expect(result.token, 'test-token');
          expect(result.success, false);
          expect(result.message, 'Authentication failed');
          expect(result.expiresAt, null);
        },
      );
    });

    group('copyWith', () {
      test('should return a new AuthResponseModel with updated fields', () {
        // act
        final result = tAuthResponseModel.copyWith(
          success: false,
          message: 'Updated message',
        );

        // assert
        expect(result.user.id, 'test-id');
        expect(result.token, 'test-token-123');
        expect(result.success, false);
        expect(result.message, 'Updated message');
        expect(result.refreshToken, 'refresh-token-456'); // unchanged
      });

      test(
        'should return the same AuthResponseModel when no fields are updated',
        () {
          // act
          final result = tAuthResponseModel.copyWith();

          // assert
          expect(result, tAuthResponseModel);
        },
      );
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // arrange
        final authResponseModel1 = AuthResponseModel(
          user: tUserModel,
          token: 'test-token',
          success: true,
          message: 'Success',
        );

        final authResponseModel2 = AuthResponseModel(
          user: tUserModel,
          token: 'test-token',
          success: true,
          message: 'Success',
        );

        // assert
        expect(authResponseModel1, equals(authResponseModel2));
        expect(
          authResponseModel1.hashCode,
          equals(authResponseModel2.hashCode),
        );
      });

      test('should not be equal when properties are different', () {
        // arrange
        final authResponseModel1 = AuthResponseModel(
          user: tUserModel,
          token: 'test-token-1',
          success: true,
          message: 'Success',
        );

        final authResponseModel2 = AuthResponseModel(
          user: tUserModel,
          token: 'test-token-2',
          success: false,
          message: 'Failure',
        );

        // assert
        expect(authResponseModel1, isNot(equals(authResponseModel2)));
        expect(
          authResponseModel1.hashCode,
          isNot(equals(authResponseModel2.hashCode)),
        );
      });
    });

    group('validation', () {
      test('should validate token format when provided', () {
        // arrange
        final invalidTokenModel = AuthResponseModel(
          user: tUserModel,
          token: '',
          success: true,
          message: 'Success',
        );

        // act & assert
        expect(
          () => invalidTokenModel.toEntity(),
          throwsA(isA<FormatException>()),
        );
      });

      test('should validate success and message consistency', () {
        // arrange
        final inconsistentModel = AuthResponseModel(
          user: tUserModel,
          token: 'test-token',
          success: true,
          message: 'Authentication failed', // inconsistent with success: true
        );

        // act & assert
        expect(
          () => inconsistentModel.toEntity(),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('factory methods', () {
      test('should create success response', () {
        // act
        final result = AuthResponseModel.createSuccess(
          user: tUserModel,
          token: 'test-token',
          message: 'Login successful',
        );

        // assert
        expect(result.user, tUserModel);
        expect(result.token, 'test-token');
        expect(result.success, true);
        expect(result.message, 'Login successful');
      });

      test('should create failure response', () {
        // arrange
        const errorMessage = 'Invalid credentials';

        // act
        final result = AuthResponseModel.createFailure(message: errorMessage);

        // assert
        expect(result.user, null);
        expect(result.token, null);
        expect(result.success, false);
        expect(result.message, errorMessage);
      });
    });
  });
}
