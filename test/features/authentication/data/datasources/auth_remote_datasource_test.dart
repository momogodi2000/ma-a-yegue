import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mayegue/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:mayegue/features/authentication/data/models/user_model.dart';
import 'package:mayegue/features/authentication/data/models/auth_response_model.dart';
import 'package:mayegue/core/services/firebase_service.dart';

import 'auth_remote_datasource_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  FirebaseService,
  FirebaseAuth,
  User,
  GoogleSignIn,
  GoogleSignInAuthentication,
  GoogleSignInAccount,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
])
void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockFirebaseService mockFirebaseService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockDocumentReference;
  late MockDocumentSnapshot mockDocumentSnapshot;

  final tUserModel = UserModel(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    role: 'learner',
    createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
    isEmailVerified: true,
  );

  setUp(() {
    mockFirebaseService = MockFirebaseService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();

    dataSource = AuthRemoteDataSourceImpl(
      firebaseService: mockFirebaseService,
      googleSignIn: mockGoogleSignIn,
    );

    // Setup common mocks
    when(mockFirebaseService.auth).thenReturn(mockFirebaseAuth);
    when(mockFirebaseService.firestore).thenReturn(mockFirestore);
    when(mockFirestore.collection('users')).thenReturn(mockCollectionReference as CollectionReference<Map<String, dynamic>>);
    when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
    when(
      mockDocumentReference.get(),
    ).thenAnswer((_) async => mockDocumentSnapshot);
  });

  group('AuthRemoteDataSourceImpl', () {
    group('signInWithEmailAndPassword', () {
      test(
        'should return AuthResponseModel when sign in is successful',
        () async {
          // arrange
          const email = 'test@example.com';
          const password = 'password123';

          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenAnswer((_) async => MockUserCredential());

          when(mockUser.uid).thenReturn('test-user-id');
          when(mockUser.email).thenReturn('test@example.com');
          when(mockUser.displayName).thenReturn('Test User');
          when(mockUser.emailVerified).thenReturn(true);
          when(mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
          when(mockUser.phoneNumber).thenReturn('+237612345678');
          when(mockUser.metadata).thenReturn(
            UserMetadata(DateTime.parse('2024-01-01T00:00:00.000Z').millisecondsSinceEpoch, DateTime.parse('2024-01-02T00:00:00.000Z').millisecondsSinceEpoch),
          );

          when(mockDocumentSnapshot.exists).thenReturn(true);
          when(mockDocumentSnapshot.data()).thenReturn({
            'role': 'learner',
            'subscriptionStatus': 'free',
            'totalLearningTime': 3600,
            'streak': 5,
            'level': 3,
            'xp': 1500,
          });

          // Mock the UserCredential
          final mockUserCredential = MockUserCredential();
          when(mockUserCredential.user).thenReturn(mockUser);
          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenAnswer((_) async => mockUserCredential);

          // act
          final result = await dataSource.signInWithEmailAndPassword(
            email,
            password,
          );

          // assert
          expect(result, isA<AuthResponseModel>());
          expect(result.success, true);
          expect(result.user.email, 'test@example.com');
          expect(result.user.displayName, 'Test User');
          expect(result.user.role, 'learner');

          verify(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).called(1);
        },
      );

      test('should throw exception when sign in fails', () async {
        // arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';

        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'wrong-password',
            message: 'The password is invalid',
          ),
        );

        // act & assert
        expect(
          () => dataSource.signInWithEmailAndPassword(email, password),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('signUpWithEmailAndPassword', () {
      test(
        'should return AuthResponseModel when sign up is successful',
        () async {
          // arrange
          const email = 'newuser@example.com';
          const password = 'password123';
          const displayName = 'New User';

          final mockUserCredential = MockUserCredential();
          when(mockUserCredential.user).thenReturn(mockUser);
          when(
            mockFirebaseAuth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenAnswer((_) async => mockUserCredential);

          when(mockUser.uid).thenReturn('new-user-id');
          when(mockUser.email).thenReturn(email);
          when(mockUser.displayName).thenReturn(displayName);
          when(mockUser.emailVerified).thenReturn(false);
          when(mockUser.metadata).thenReturn(
            UserMetadata(DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch),
          );

          when(mockDocumentReference.set(any)).thenAnswer((_) async => {});
          when(mockDocumentSnapshot.exists).thenReturn(false);

          // act
          final result = await dataSource.signUpWithEmailAndPassword(
            email,
            password,
            displayName,
          );

          // assert
          expect(result, isA<AuthResponseModel>());
          expect(result.success, true);
          expect(result.user.email, email);
          expect(result.user.displayName, displayName);

          verify(
            mockFirebaseAuth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).called(1);
          verify(mockDocumentReference.set(any)).called(1);
        },
      );

      test('should throw exception when sign up fails', () async {
        // arrange
        const email = 'invalid-email';
        const password = 'password123';
        const displayName = 'New User';

        when(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'invalid-email',
            message: 'The email address is badly formatted',
          ),
        );

        // act & assert
        expect(
          () => dataSource.signUpWithEmailAndPassword(
            email,
            password,
            displayName,
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('signInWithGoogle', () {
      test(
        'should return AuthResponseModel when Google sign in is successful',
        () async {
          // arrange
          when(
            mockGoogleSignIn.signIn(),
          ).thenAnswer((_) async => mockGoogleSignInAccount);
          when(
            mockGoogleSignInAccount.authentication,
          ).thenAnswer((_) async => mockGoogleSignInAuthentication);
          when(
            mockGoogleSignInAuthentication.accessToken,
          ).thenReturn('google-access-token');
          when(
            mockGoogleSignInAuthentication.idToken,
          ).thenReturn('google-id-token');

          when(
            mockFirebaseAuth.signInWithCredential(any),
          ).thenAnswer((_) async => MockUserCredential());

          when(mockUser.uid).thenReturn('google-user-id');
          when(mockUser.email).thenReturn('google@example.com');
          when(mockUser.displayName).thenReturn('Google User');
          when(mockUser.emailVerified).thenReturn(true);
          when(
            mockUser.photoURL,
          ).thenReturn('https://example.com/google-photo.jpg');

          when(mockDocumentSnapshot.exists).thenReturn(true);
          when(
            mockDocumentSnapshot.data(),
          ).thenReturn({'role': 'learner', 'subscriptionStatus': 'free'});

          // act
          final result = await dataSource.signInWithGoogle();

          // assert
          expect(result, isA<AuthResponseModel>());
          expect(result.success, true);
          expect(result.user.email, 'google@example.com');

          verify(mockGoogleSignIn.signIn()).called(1);
        },
      );

      test('should throw exception when Google sign in fails', () async {
        // arrange
        when(
          mockGoogleSignIn.signIn(),
        ).thenThrow(Exception('Google sign in failed'));

        // act & assert
        expect(() => dataSource.signInWithGoogle(), throwsA(isA<Exception>()));
      });

      test(
        'should return failure response when Google sign in is cancelled',
        () async {
          // arrange
          when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

          // act
          final result = await dataSource.signInWithGoogle();

          // assert
          expect(result.success, false);
          expect(result.message, contains('cancelled'));
        },
      );
    });

    group('signInWithFacebook', () {
      test(
        'should return AuthResponseModel when Facebook sign in is successful',
        () async {
          // arrange
          when(
            mockFirebaseAuth.signInWithCredential(any),
          ).thenAnswer((_) async => MockUserCredential());

          when(mockUser.uid).thenReturn('facebook-user-id');
          when(mockUser.email).thenReturn('facebook@example.com');
          when(mockUser.displayName).thenReturn('Facebook User');
          when(mockUser.emailVerified).thenReturn(true);

          when(mockDocumentSnapshot.exists).thenReturn(true);
          when(
            mockDocumentSnapshot.data(),
          ).thenReturn({'role': 'learner', 'subscriptionStatus': 'free'});

          // act
          final result = await dataSource.signInWithFacebook();

          // assert
          expect(result, isA<AuthResponseModel>());
          expect(result.success, true);
          expect(result.user.email, 'facebook@example.com');

          verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
        },
      );

      test('should throw exception when Facebook sign in fails', () async {
        // arrange
        when(mockFirebaseAuth.signInWithCredential(any)).thenThrow(
          FirebaseAuthException(
            code: 'account-exists-with-different-credential',
            message: 'An account already exists with the same email',
          ),
        );

        // act & assert
        expect(
          () => dataSource.signInWithFacebook(),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('signInWithApple', () {
      test(
        'should return AuthResponseModel when Apple sign in is successful',
        () async {
          // arrange
          when(
            mockFirebaseAuth.signInWithCredential(any),
          ).thenAnswer((_) async => MockUserCredential());

          when(mockUser.uid).thenReturn('apple-user-id');
          when(mockUser.email).thenReturn('apple@example.com');
          when(mockUser.displayName).thenReturn('Apple User');
          when(mockUser.emailVerified).thenReturn(true);

          when(mockDocumentSnapshot.exists).thenReturn(true);
          when(
            mockDocumentSnapshot.data(),
          ).thenReturn({'role': 'learner', 'subscriptionStatus': 'free'});

          // act
          final result = await dataSource.signInWithApple();

          // assert
          expect(result, isA<AuthResponseModel>());
          expect(result.success, true);
          expect(result.user.email, 'apple@example.com');

          verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
        },
      );
    });

    group('signInWithPhoneNumber', () {
      test(
        'should return verification ID when phone sign in is successful',
        () async {
          // arrange
          const phoneNumber = '+237612345678';

          when(
            mockFirebaseAuth.verifyPhoneNumber(
              phoneNumber: phoneNumber,
              verificationCompleted: anyNamed('verificationCompleted'),
              verificationFailed: anyNamed('verificationFailed'),
              codeSent: anyNamed('codeSent'),
              codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
            ),
          ).thenAnswer((_) async => {});

          // act
          final result = await dataSource.signInWithPhoneNumber(phoneNumber);

          // assert
          expect(result, isA<String>());
          verify(
            mockFirebaseAuth.verifyPhoneNumber(
              phoneNumber: phoneNumber,
              verificationCompleted: anyNamed('verificationCompleted'),
              verificationFailed: anyNamed('verificationFailed'),
              codeSent: anyNamed('codeSent'),
              codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
            ),
          ).called(1);
        },
      );
    });

    group('verifyPhoneNumber', () {
      test(
        'should return AuthResponseModel when phone verification is successful',
        () async {
          // arrange
          const verificationId = 'test-verification-id';
          const smsCode = '123456';

          when(
            mockFirebaseAuth.signInWithCredential(any),
          ).thenAnswer((_) async => MockUserCredential());

          when(mockUser.uid).thenReturn('phone-user-id');
          when(mockUser.phoneNumber).thenReturn('+237612345678');
          when(mockUser.emailVerified).thenReturn(false);

          when(mockDocumentSnapshot.exists).thenReturn(true);
          when(
            mockDocumentSnapshot.data(),
          ).thenReturn({'role': 'learner', 'subscriptionStatus': 'free'});

          // act
          final result = await dataSource.verifyPhoneNumber(
            verificationId,
            smsCode,
          );

          // assert
          expect(result, isA<AuthResponseModel>());
          expect(result.success, true);
          expect(result.user.phoneNumber, '+237612345678');

          verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
        },
      );

      test('should throw exception when phone verification fails', () async {
        // arrange
        const verificationId = 'test-verification-id';
        const smsCode = 'wrong-code';

        when(mockFirebaseAuth.signInWithCredential(any)).thenThrow(
          FirebaseAuthException(
            code: 'invalid-verification-code',
            message: 'The verification code is invalid',
          ),
        );

        // act & assert
        expect(
          () => dataSource.verifyPhoneNumber(verificationId, smsCode),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('signOut', () {
      test('should sign out successfully', () async {
        // arrange
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

        // act
        await dataSource.signOut();

        // assert
        verify(mockFirebaseAuth.signOut()).called(1);
        verify(mockGoogleSignIn.signOut()).called(1);
      });

      test('should throw exception when sign out fails', () async {
        // arrange
        when(
          mockFirebaseAuth.signOut(),
        ).thenThrow(Exception('Sign out failed'));

        // act & assert
        expect(() => dataSource.signOut(), throwsA(isA<Exception>()));
      });
    });

    group('getCurrentUser', () {
      test('should return user when current user exists', () async {
        // arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('current-user-id');
        when(mockUser.email).thenReturn('current@example.com');
        when(mockUser.displayName).thenReturn('Current User');
        when(mockUser.emailVerified).thenReturn(true);

        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(
          mockDocumentSnapshot.data(),
        ).thenReturn({'role': 'learner', 'subscriptionStatus': 'free'});

        // act
        final result = await dataSource.getCurrentUser();

        // assert
        expect(result, isA<UserModel>());
        expect(result?.email, 'current@example.com');
        expect(result?.displayName, 'Current User');
      });

      test('should return null when no current user', () async {
        // arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // act
        final result = await dataSource.getCurrentUser();

        // assert
        expect(result, null);
      });
    });

    group('sendPasswordResetEmail', () {
      test('should send password reset email successfully', () async {
        // arrange
        const email = 'test@example.com';
        when(
          mockFirebaseAuth.sendPasswordResetEmail(email: email),
        ).thenAnswer((_) async => {});

        // act
        await dataSource.sendPasswordResetEmail(email);

        // assert
        verify(mockFirebaseAuth.sendPasswordResetEmail(email: email)).called(1);
      });

      test('should throw exception when password reset fails', () async {
        // arrange
        const email = 'nonexistent@example.com';
        when(mockFirebaseAuth.sendPasswordResetEmail(email: email)).thenThrow(
          FirebaseAuthException(
            code: 'user-not-found',
            message: 'There is no user record corresponding to this email',
          ),
        );

        // act & assert
        expect(
          () => dataSource.sendPasswordResetEmail(email),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('updateUserProfile', () {
      test('should update user profile successfully', () async {
        // arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockDocumentReference.update(any)).thenAnswer((_) async => {});

        // act
        final result = await dataSource.updateUserProfile(tUserModel);

        // assert
        expect(result, isA<UserModel>());
        verify(mockDocumentReference.update(any)).called(1);
      });

      test('should throw exception when update fails', () async {
        // arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(
          mockDocumentReference.update(any),
        ).thenThrow(Exception('Update failed'));

        // act & assert
        expect(
          () => dataSource.updateUserProfile(tUserModel),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteUserAccount', () {
      test('should delete user account successfully', () async {
        // arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.delete()).thenAnswer((_) async => {});
        when(mockDocumentReference.delete()).thenAnswer((_) async => {});

        // act
        await dataSource.deleteUserAccount();

        // assert
        verify(mockUser.delete()).called(1);
        verify(mockDocumentReference.delete()).called(1);
      });

      test('should throw exception when deletion fails', () async {
        // arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.delete()).thenThrow(Exception('Deletion failed'));

        // act & assert
        expect(() => dataSource.deleteUserAccount(), throwsA(isA<Exception>()));
      });
    });

    group('isAuthenticated', () {
      test('should return true when user is authenticated', () async {
        // arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // act
        final result = await dataSource.isAuthenticated();

        // assert
        expect(result, true);
      });

      test('should return false when user is not authenticated', () async {
        // arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // act
        final result = await dataSource.isAuthenticated();

        // assert
        expect(result, false);
      });
    });

    group('authStateChanges', () {
      test('should return stream of auth state changes', () {
        // arrange
        final stream = Stream.value(mockUser);
        when(mockFirebaseAuth.authStateChanges()).thenReturn(stream);

        // act
        final result = dataSource.authStateChanges;

        // assert
        expect(result, isA<Stream<User?>>());
        verify(mockFirebaseAuth.authStateChanges()).called(1);
      });
    });
  });
}

// Mock classes for Firebase types
class MockUserCredential extends Mock implements UserCredential {
  @override
  User? get user =>
      super.noSuchMethod(Invocation.getter(#user), returnValue: null);
}

class MockAuthCredential extends Mock implements AuthCredential {
  @override
  String get providerId =>
      super.noSuchMethod(Invocation.getter(#providerId), returnValue: '');

  @override
  String get signInMethod =>
      super.noSuchMethod(Invocation.getter(#signInMethod), returnValue: '');
}
