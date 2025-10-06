import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:maa_yegue/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:maa_yegue/features/authentication/data/models/user_model.dart';

import 'auth_local_datasource_test.mocks.dart';

// Generate mocks
@GenerateMocks([SharedPreferences, Database])
void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;
  late MockDatabase mockDatabase;

  final tUserModel = UserModel(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    role: 'learner',
    createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
    isEmailVerified: true,
  );

  // Remove unused variable
  // final tAuthResponseModel = AuthResponseModel(
  //   user: tUserModel,
  //   token: 'test-token-123',
  //   refreshToken: 'refresh-token-456',
  //   success: true,
  //   message: 'Authentication successful',
  // );

  setUp(() {
    // Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    mockSharedPreferences = MockSharedPreferences();
    mockDatabase = MockDatabase();
    dataSource = AuthLocalDataSourceImpl();
  });

  group('AuthLocalDataSourceImpl', () {
    group('saveUser', () {
      test(
        'should save user data to database and shared preferences',
        () async {
          // arrange
          when(
            mockDatabase.insert(
              any,
              any,
              conflictAlgorithm: anyNamed('conflictAlgorithm'),
            ),
          ).thenAnswer((_) async => 1);
          when(
            mockSharedPreferences.setString(any, any),
          ).thenAnswer((_) async => true);

          // act
          await dataSource.saveUser(tUserModel);

          // assert
          verify(
            mockDatabase.insert(
              'users',
              any,
              conflictAlgorithm: ConflictAlgorithm.replace,
            ),
          ).called(1);
          verify(
            mockSharedPreferences.setString('current_user_id', 'test-user-id'),
          ).called(1);
          verify(
            mockSharedPreferences.setString('user_email', 'test@example.com'),
          ).called(1);
          verify(
            mockSharedPreferences.setString('user_role', 'learner'),
          ).called(1);
        },
      );

      test('should throw exception when database insert fails', () async {
        // arrange
        when(
          mockDatabase.insert(
            any,
            any,
            conflictAlgorithm: anyNamed('conflictAlgorithm'),
          ),
        ).thenThrow(Exception('Database error'));

        // act & assert
        expect(
          () => dataSource.saveUser(tUserModel),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getCurrentUser', () {
      test('should return user when found in database', () async {
        // arrange
        final userJson = {
          'id': 'test-user-id',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'role': 'learner',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'isEmailVerified': 1,
        };

        when(
          mockDatabase.query(
            'users',
            where: any,
            whereArgs: any,
            limit: anyNamed('limit'),
          ),
        ).thenAnswer((_) async => [userJson]);

        // act
        final result = await dataSource.getCurrentUser();

        // assert
        expect(result, isA<UserModel>());
        expect(result?.id, 'test-user-id');
        expect(result?.email, 'test@example.com');
        expect(result?.displayName, 'Test User');
        expect(result?.role, 'learner');
        expect(result?.isEmailVerified, true);

        verify(
          mockDatabase.query(
            'users',
            where: 'id = ?',
            whereArgs: ['test-user-id'],
            limit: 1,
          ),
        ).called(1);
      });

      test('should return null when user not found in database', () async {
        // arrange
        when(
          mockDatabase.query(
            'users',
            where: any,
            whereArgs: any,
            limit: anyNamed('limit'),
          ),
        ).thenAnswer((_) async => []);

        // act
        final result = await dataSource.getCurrentUser();

        // assert
        expect(result, null);
      });

      test(
        'should return null when no current user ID in shared preferences',
        () async {
          // arrange
          when(
            mockSharedPreferences.getString('current_user_id'),
          ).thenReturn(null);

          // act
          final result = await dataSource.getCurrentUser();

          // assert
          expect(result, null);
          verifyNever(
            mockDatabase.query(
              any,
              where: any,
              whereArgs: any,
              limit: anyNamed('limit'),
            ),
          );
        },
      );

      test('should throw exception when database query fails', () async {
        // arrange
        when(
          mockSharedPreferences.getString('current_user_id'),
        ).thenReturn('test-user-id');
        when(
          mockDatabase.query(
            any,
            where: any,
            whereArgs: any,
            limit: anyNamed('limit'),
          ),
        ).thenThrow(Exception('Database error'));

        // act & assert
        expect(() => dataSource.getCurrentUser(), throwsA(isA<Exception>()));
      });
    });

    group('deleteUser', () {
      test(
        'should delete user from database and clear shared preferences',
        () async {
          // arrange
          when(
            mockDatabase.delete(any, where: any, whereArgs: any),
          ).thenAnswer((_) async => 1);
          when(mockSharedPreferences.remove(any)).thenAnswer((_) async => true);

          // act
          await dataSource.deleteUser('test-user-id');

          // assert
          verify(
            mockDatabase.delete(
              'users',
              where: 'id = ?',
              whereArgs: ['test-user-id'],
            ),
          ).called(1);
          verify(mockSharedPreferences.remove('current_user_id')).called(1);
          verify(mockSharedPreferences.remove('user_email')).called(1);
          verify(mockSharedPreferences.remove('user_role')).called(1);
          verify(mockSharedPreferences.remove('auth_token')).called(1);
          verify(mockSharedPreferences.remove('refresh_token')).called(1);
        },
      );

      test('should throw exception when database delete fails', () async {
        // arrange
        when(
          mockDatabase.delete(any, where: any, whereArgs: any),
        ).thenThrow(Exception('Database error'));

        // act & assert
        expect(
          () => dataSource.deleteUser('test-user-id'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('saveAuthTokens', () {
      test('should save auth tokens to shared preferences', () async {
        // arrange
        when(
          mockSharedPreferences.setString(any, any),
        ).thenAnswer((_) async => true);

        // act
        await dataSource.saveAuthTokens('test-token', 'refresh-token');

        // assert
        verify(
          mockSharedPreferences.setString('auth_token', 'test-token'),
        ).called(1);
        verify(
          mockSharedPreferences.setString('refresh_token', 'refresh-token'),
        ).called(1);
      });

      test('should throw exception when shared preferences fails', () async {
        // arrange
        when(
          mockSharedPreferences.setString(any, any),
        ).thenThrow(Exception('Storage error'));

        // act & assert
        expect(
          () => dataSource.saveAuthTokens('test-token', 'refresh-token'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getAuthTokens', () {
      test('should return auth tokens from shared preferences', () async {
        // arrange
        when(
          mockSharedPreferences.getString('auth_token'),
        ).thenReturn('test-token');
        when(
          mockSharedPreferences.getString('refresh_token'),
        ).thenReturn('refresh-token');

        // act
        final result = await dataSource.getAuthTokens();

        // assert
        expect(result!['token'], 'test-token');
        expect(result['refreshToken'], 'refresh-token');
      });

      test(
        'should return null tokens when not found in shared preferences',
        () async {
          // arrange
          when(mockSharedPreferences.getString('auth_token')).thenReturn(null);
          when(
            mockSharedPreferences.getString('refresh_token'),
          ).thenReturn(null);

          // act
          final result = await dataSource.getAuthTokens();

          // assert
          expect(result, null);
        },
      );
    });

    group('clearAuthData', () {
      test('should clear all auth data from shared preferences', () async {
        // arrange
        when(mockSharedPreferences.remove(any)).thenAnswer((_) async => true);

        // act
        await dataSource.clearAuthData();

        // assert
        verify(mockSharedPreferences.remove('current_user_id')).called(1);
        verify(mockSharedPreferences.remove('user_email')).called(1);
        verify(mockSharedPreferences.remove('user_role')).called(1);
        verify(mockSharedPreferences.remove('auth_token')).called(1);
        verify(mockSharedPreferences.remove('refresh_token')).called(1);
      });

      test('should throw exception when shared preferences fails', () async {
        // arrange
        when(
          mockSharedPreferences.remove(any),
        ).thenThrow(Exception('Storage error'));

        // act & assert
        expect(() => dataSource.clearAuthData(), throwsA(isA<Exception>()));
      });
    });

    group('isUserLoggedIn', () {
      test('should return true when user is logged in', () async {
        // arrange
        when(
          mockSharedPreferences.getString('current_user_id'),
        ).thenReturn('test-user-id');
        when(
          mockSharedPreferences.getString('auth_token'),
        ).thenReturn('test-token');

        // act
        final result = await dataSource.isUserLoggedIn();

        // assert
        expect(result, true);
      });

      test('should return false when user is not logged in', () async {
        // arrange
        when(
          mockSharedPreferences.getString('current_user_id'),
        ).thenReturn(null);
        when(mockSharedPreferences.getString('auth_token')).thenReturn(null);

        // act
        final result = await dataSource.isUserLoggedIn();

        // assert
        expect(result, false);
      });

      test('should return false when user ID exists but no token', () async {
        // arrange
        when(
          mockSharedPreferences.getString('current_user_id'),
        ).thenReturn('test-user-id');
        when(mockSharedPreferences.getString('auth_token')).thenReturn(null);

        // act
        final result = await dataSource.isUserLoggedIn();

        // assert
        expect(result, false);
      });
    });

    group('updateUserProfile', () {
      test('should update user profile in database', () async {
        // arrange
        final updatedUser = UserModel(
          id: 'test-user-id',
          email: 'updated@example.com',
          displayName: 'Updated User',
          role: 'learner',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
          isEmailVerified: true,
        );

        when(
          mockDatabase.update(any, any, where: any, whereArgs: any),
        ).thenAnswer((_) async => 1);

        // act
        await dataSource.updateUserProfile(updatedUser);

        // assert
        verify(
          mockDatabase.update(
            'users',
            any,
            where: 'id = ?',
            whereArgs: ['test-user-id'],
          ),
        ).called(1);
      });

      test('should throw exception when database update fails', () async {
        // arrange
        when(
          mockDatabase.update(any, any, where: any, whereArgs: any),
        ).thenThrow(Exception('Database error'));

        // act & assert
        expect(
          () => dataSource.updateUserProfile(tUserModel),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getUserById', () {
      test('should return user when found by ID', () async {
        // arrange
        final userJson = {
          'id': 'test-user-id',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'role': 'learner',
          'createdAt': '2024-01-01T00:00:00.000Z',
          'isEmailVerified': 1,
        };

        when(
          mockDatabase.query(
            'users',
            where: any,
            whereArgs: any,
            limit: anyNamed('limit'),
          ),
        ).thenAnswer((_) async => [userJson]);

        // act
        final result = await dataSource.getUserById('test-user-id');

        // assert
        expect(result, isA<UserModel>());
        expect(result?.id, 'test-user-id');
        expect(result?.email, 'test@example.com');

        verify(
          mockDatabase.query(
            'users',
            where: 'id = ?',
            whereArgs: ['test-user-id'],
            limit: 1,
          ),
        ).called(1);
      });

      test('should return null when user not found by ID', () async {
        // arrange
        when(
          mockDatabase.query(
            'users',
            where: any,
            whereArgs: any,
            limit: anyNamed('limit'),
          ),
        ).thenAnswer((_) async => []);

        // act
        final result = await dataSource.getUserById('non-existent-id');

        // assert
        expect(result, null);
      });
    });
  });
}
