import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maa_yegue/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:maa_yegue/features/authentication/data/models/user_model.dart';

void main() {
  late AuthLocalDataSourceImpl dataSource;

  final tUserModel = UserModel(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    role: 'learner',
    createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
    isEmailVerified: true,
  );

  setUp(() {
    dataSource = AuthLocalDataSourceImpl();
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthLocalDataSourceImpl', () {
    group('cacheUser', () {
      test('should cache user data in SharedPreferences', () async {
        // act
        await dataSource.cacheUser(tUserModel);

        // assert
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('current_user_id'), 'test-user-id');
        expect(prefs.getString('cached_user_data'), isNotNull);
        expect(prefs.getString('last_cache_time'), isNotNull);
      });

      test('should cache user with all fields', () async {
        // act
        await dataSource.cacheUser(tUserModel);

        // assert
        final prefs = await SharedPreferences.getInstance();
        final cachedUserJson = prefs.getString('cached_user_data');
        expect(cachedUserJson, isNotNull);
        expect(cachedUserJson, contains('test-user-id'));
        expect(cachedUserJson, contains('test@example.com'));
        expect(cachedUserJson, contains('Test User'));
      });
    });

    group('getCachedUser', () {
      test('should return cached user when cache is valid', () async {
        // arrange
        await dataSource.cacheUser(tUserModel);

        // act
        final result = await dataSource.getCachedUser();

        // assert
        expect(result, isNotNull);
        expect(result!.id, 'test-user-id');
        expect(result.email, 'test@example.com');
        expect(result.displayName, 'Test User');
        expect(result.role, 'learner');
      });

      test('should return null when no cached user exists', () async {
        // act
        final result = await dataSource.getCachedUser();

        // assert
        expect(result, isNull);
      });

      test('should return null when cache has expired', () async {
        // arrange
        final prefs = await SharedPreferences.getInstance();
        
        // Set cache time to 10 minutes ago (past the 5-minute expiry)
        final oldTime = DateTime.now().subtract(const Duration(minutes: 10));
        await prefs.setString('last_cache_time', oldTime.toIso8601String());
        await prefs.setString('cached_user_data', '{"id": "test"}');

        // act
        final result = await dataSource.getCachedUser();

        // assert
        expect(result, isNull);
        // Verify expired cache was cleared
        expect(prefs.getString('cached_user_data'), isNull);
      });

      test('should return null when cached data is invalid JSON', () async {
        // arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_user_data', 'invalid-json');
        await prefs.setString('last_cache_time', DateTime.now().toIso8601String());

        // act
        final result = await dataSource.getCachedUser();

        // assert
        expect(result, isNull);
        // Verify invalid cache was cleared
        expect(prefs.getString('cached_user_data'), isNull);
      });
    });

    group('clearCachedUser', () {
      test('should clear cached user data', () async {
        // arrange
        await dataSource.cacheUser(tUserModel);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('cached_user_data'), isNotNull);

        // act
        await dataSource.clearCachedUser();

        // assert
        expect(prefs.getString('cached_user_data'), isNull);
        expect(prefs.getString('last_cache_time'), isNull);
      });
    });

    group('cacheUserId', () {
      test('should cache user ID in SharedPreferences', () async {
        // act
        await dataSource.cacheUserId('test-user-id');

        // assert
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('current_user_id'), 'test-user-id');
      });
    });

    group('getCachedUserId', () {
      test('should return cached user ID', () async {
        // arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user_id', 'test-user-id');

        // act
        final result = await dataSource.getCachedUserId();

        // assert
        expect(result, 'test-user-id');
      });

      test('should return null when no user ID is cached', () async {
        // act
        final result = await dataSource.getCachedUserId();

        // assert
        expect(result, isNull);
      });
    });

    group('clearAuthData', () {
      test('should clear all auth data from SharedPreferences', () async {
        // arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user_id', 'test-user-id');
        await prefs.setString('cached_user_data', 'cached-data');
        await prefs.setString('last_cache_time', DateTime.now().toIso8601String());
        await prefs.setString('user_email', 'test@example.com');
        await prefs.setString('user_role', 'learner');

        // act
        await dataSource.clearAuthData();

        // assert
        expect(prefs.getString('current_user_id'), isNull);
        expect(prefs.getString('cached_user_data'), isNull);
        expect(prefs.getString('last_cache_time'), isNull);
        expect(prefs.getString('user_email'), isNull);
        expect(prefs.getString('user_role'), isNull);
      });
    });

    group('isUserLoggedIn', () {
      test('should return true when user ID is cached', () async {
        // arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user_id', 'test-user-id');

        // act
        final result = await dataSource.isUserLoggedIn();

        // assert
        expect(result, isTrue);
      });

      test('should return false when no user ID is cached', () async {
        // act
        final result = await dataSource.isUserLoggedIn();

        // assert
        expect(result, isFalse);
      });
    });
  });
}
