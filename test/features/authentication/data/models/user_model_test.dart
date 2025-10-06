import 'package:flutter_test/flutter_test.dart';
import 'package:maa_yegue/features/authentication/data/models/user_model.dart';
import 'package:maa_yegue/features/authentication/domain/entities/user_entity.dart';

void main() {
  group('UserModel', () {
    final tUserModel = UserModel(
      id: 'test-id',
      email: 'test@example.com',
      displayName: 'Test User',
      role: 'learner',
      languages: ['en', 'ewondo'],
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      isEmailVerified: true,
      photoUrl: 'https://example.com/photo.jpg',
      phoneNumber: '+237612345678',
      lastLoginAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
      preferences: {'language': 'en', 'theme': 'light'},
    );

    group('fromFirestore', () {
      test('should return a valid UserModel when data is valid', () {
        // arrange
        final data = {
          'email': 'test@example.com',
          'displayName': 'Test User',
          'role': 'learner',
          'languages': ['en', 'ewondo'],
          'isEmailVerified': true,
          'photoUrl': 'https://example.com/photo.jpg',
          'phoneNumber': '+237612345678',
          'preferences': {'language': 'en', 'theme': 'light'},
        };

        // act
        final result = UserModel.fromFirestore(data, 'test-id');

        // assert
        expect(result.id, 'test-id');
        expect(result.email, 'test@example.com');
        expect(result.displayName, 'Test User');
        expect(result.role, 'learner');
        expect(result.languages, ['en', 'ewondo']);
        expect(result.isEmailVerified, true);
        expect(result.photoUrl, 'https://example.com/photo.jpg');
        expect(result.phoneNumber, '+237612345678');
        expect(result.preferences, {'language': 'en', 'theme': 'light'});
        expect(result.createdAt, isA<DateTime>());
      });

      test(
        'should return a UserModel with default values when data has missing fields',
        () {
          // arrange
          final data = {'email': 'test@example.com'};

          // act
          final result = UserModel.fromFirestore(data, 'test-id');

          // assert
          expect(result.id, 'test-id');
          expect(result.email, 'test@example.com');
          expect(result.displayName, null);
          expect(result.role, 'learner');
          expect(result.languages, []);
          expect(result.isEmailVerified, false);
          expect(result.photoUrl, null);
          expect(result.phoneNumber, null);
          expect(result.preferences, null);
          expect(result.createdAt, isA<DateTime>());
        },
      );
    });

    group('toFirestore', () {
      test('should return a Firestore document with proper data', () {
        // act
        final result = tUserModel.toFirestore();

        // assert
        expect(result['email'], 'test@example.com');
        expect(result['displayName'], 'Test User');
        expect(result['role'], 'learner');
        expect(result['languages'], ['en', 'ewondo']);
        expect(result['isEmailVerified'], true);
        expect(result['photoUrl'], 'https://example.com/photo.jpg');
        expect(result['phoneNumber'], '+237612345678');
        expect(result['preferences'], {'language': 'en', 'theme': 'light'});
        expect(result['createdAt'], isA<dynamic>());
        expect(result['lastLoginAt'], isA<dynamic>());
      });
    });

    group('fromFirebaseUser', () {
      test('should create UserModel from Firebase User', () {
        // arrange
        final mockFirebaseUser = MockFirebaseUser();

        // act
        final result = UserModel.fromFirebaseUser(mockFirebaseUser);

        // assert
        expect(result.id, 'firebase-uid');
        expect(result.email, 'firebase@example.com');
        expect(result.displayName, 'Firebase User');
        expect(result.photoUrl, 'https://firebase.com/photo.jpg');
        expect(result.phoneNumber, '+237612345678');
        expect(result.isEmailVerified, true);
        expect(result.createdAt, isA<DateTime>());
      });
    });

    group('fromEntity', () {
      test('should create UserModel from UserEntity', () {
        // arrange
        final entity = UserEntity(
          id: 'entity-id',
          email: 'entity@example.com',
          displayName: 'Entity User',
          role: 'teacher',
          languages: ['fr'],
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        );

        // act
        final result = UserModel.fromEntity(entity);

        // assert
        expect(result.id, 'entity-id');
        expect(result.email, 'entity@example.com');
        expect(result.displayName, 'Entity User');
        expect(result.role, 'teacher');
        expect(result.languages, ['fr']);
        expect(result.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
      });
    });

    group('toEntity', () {
      test('should return a valid UserEntity', () {
        // act
        final result = tUserModel;

        // assert
        expect(result, isA<UserEntity>());
        expect(result.id, 'test-id');
        expect(result.email, 'test@example.com');
        expect(result.displayName, 'Test User');
        expect(result.role, 'learner');
        expect(result.languages, ['en', 'ewondo']);
        expect(result.isEmailVerified, true);
        expect(result.photoUrl, 'https://example.com/photo.jpg');
        expect(result.phoneNumber, '+237612345678');
        expect(result.preferences, {'language': 'en', 'theme': 'light'});
      });
    });

    group('copyWith', () {
      test('should return a new UserModel with updated fields', () {
        // act
        final result = tUserModel.copyWith(
          displayName: 'Updated Name',
          role: 'teacher',
          languages: ['fr', 'ewondo'],
        );

        // assert
        expect(result.id, 'test-id');
        expect(result.email, 'test@example.com');
        expect(result.displayName, 'Updated Name');
        expect(result.role, 'teacher');
        expect(result.languages, ['fr', 'ewondo']);
        expect(result.isEmailVerified, true); // unchanged
      });

      test('should return the same UserModel when no fields are updated', () {
        // act
        final result = tUserModel.copyWith();

        // assert
        expect(result.id, tUserModel.id);
        expect(result.email, tUserModel.email);
        expect(result.displayName, tUserModel.displayName);
        expect(result.role, tUserModel.role);
        expect(result.languages, tUserModel.languages);
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // arrange
        final userModel1 = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          displayName: 'Test User',
          role: 'learner',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        );

        final userModel2 = UserModel(
          id: 'test-id',
          email: 'test@example.com',
          displayName: 'Test User',
          role: 'learner',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        );

        // assert
        expect(userModel1.id, userModel2.id);
        expect(userModel1.email, userModel2.email);
        expect(userModel1.displayName, userModel2.displayName);
        expect(userModel1.role, userModel2.role);
      });

      test('should not be equal when properties are different', () {
        // arrange
        final userModel1 = UserModel(
          id: 'test-id-1',
          email: 'test1@example.com',
          displayName: 'Test User 1',
          role: 'learner',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        );

        final userModel2 = UserModel(
          id: 'test-id-2',
          email: 'test2@example.com',
          displayName: 'Test User 2',
          role: 'teacher',
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        );

        // assert
        expect(userModel1.id, isNot(userModel2.id));
        expect(userModel1.email, isNot(userModel2.email));
        expect(userModel1.displayName, isNot(userModel2.displayName));
        expect(userModel1.role, isNot(userModel2.role));
      });
    });

    group('role checks', () {
      test('should correctly identify admin role', () {
        // arrange
        final adminUser = UserModel(
          id: 'admin-id',
          email: 'admin@example.com',
          role: 'admin',
          createdAt: DateTime.now(),
        );

        // assert
        expect(adminUser.isAdmin, true);
        expect(adminUser.isTeacher, false);
        expect(adminUser.isLearner, false);
      });

      test('should correctly identify teacher role', () {
        // arrange
        final teacherUser = UserModel(
          id: 'teacher-id',
          email: 'teacher@example.com',
          role: 'teacher',
          createdAt: DateTime.now(),
        );

        // assert
        expect(teacherUser.isAdmin, false);
        expect(teacherUser.isTeacher, true);
        expect(teacherUser.isLearner, false);
      });

      test('should correctly identify learner role', () {
        // arrange
        final learnerUser = UserModel(
          id: 'learner-id',
          email: 'learner@example.com',
          role: 'learner',
          createdAt: DateTime.now(),
        );

        // assert
        expect(learnerUser.isAdmin, false);
        expect(learnerUser.isTeacher, false);
        expect(learnerUser.isLearner, true);
      });
    });
  });
}

// Mock Firebase User for testing
class MockFirebaseUser {
  String get uid => 'firebase-uid';
  String get email => 'firebase@example.com';
  String? get displayName => 'Firebase User';
  String? get phoneNumber => '+237612345678';
  String? get photoURL => 'https://firebase.com/photo.jpg';
  bool get emailVerified => true;

  MockFirebaseMetadata get metadata => MockFirebaseMetadata();
}

class MockFirebaseMetadata {
  DateTime get creationTime => DateTime.parse('2024-01-01T00:00:00.000Z');
  DateTime? get lastSignInTime => DateTime.parse('2024-01-02T00:00:00.000Z');
}
