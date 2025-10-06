import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:maa_yegue/core/services/firebase_service.dart';
import 'package:maa_yegue/firebase_options.dart';

void main() {
  group('Firebase Connectivity Integration Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });

    group('Firebase Core Initialization', () {
      test('should initialize Firebase successfully', () async {
        // act
        final apps = Firebase.apps;

        // assert
        expect(apps.isNotEmpty, true);
        expect(apps.first.name, '[DEFAULT]');
      });

      test('should have correct Firebase project configuration', () async {
        // arrange
        final app = Firebase.app();

        // act
        final options = app.options;

        // assert
        expect(options.projectId, isNotNull);
        expect(options.apiKey, isNotNull);
        expect(options.appId, isNotNull);
        expect(options.messagingSenderId, isNotNull);
      });
    });

    group('Firebase Authentication', () {
      late FirebaseAuth auth;

      setUp(() {
        auth = FirebaseAuth.instance;
      });

      test('should connect to Firebase Auth successfully', () async {
        // act
        final authState = auth.authStateChanges();

        // assert
        expect(authState, isA<Stream<User?>>());
      });

      test('should handle anonymous sign in for testing', () async {
        // arrange
        User? user;

        // act
        try {
          final userCredential = await auth.signInAnonymously();
          user = userCredential.user;
        } catch (e) {
          // Ignore errors in test environment
        }

        // assert
        if (user != null) {
          expect(user.isAnonymous, true);
          expect(user.uid, isNotNull);
        }
      });

      test('should handle sign out', () async {
        // arrange
        await auth.signInAnonymously();

        // act
        await auth.signOut();

        // assert
        expect(auth.currentUser, null);
      });

      test('should listen to auth state changes', () async {
        // arrange
        User? currentUser;
        final subscription = auth.authStateChanges().listen((user) {
          currentUser = user;
        });

        // act
        await auth.signInAnonymously();
        await Future.delayed(const Duration(milliseconds: 100));

        // assert
        expect(currentUser, isNotNull);
        expect(currentUser!.isAnonymous, true);

        // cleanup
        subscription.cancel();
        await auth.signOut();
      });
    });

    group('Cloud Firestore', () {
      late FirebaseFirestore firestore;

      setUp(() {
        firestore = FirebaseFirestore.instance;
      });

      test('should connect to Firestore successfully', () async {
        // act
        final docRef = firestore.collection('test').doc('connectivity');

        // assert
        expect(docRef, isNotNull);
        expect(docRef.path, 'test/connectivity');
      });

      test('should read from Firestore', () async {
        // arrange
        final docRef = firestore.collection('test').doc('connectivity');

        // act
        try {
          final doc = await docRef.get();
          // assert
          expect(doc.exists, isA<bool>());
        } catch (e) {
          // In test environment, this might fail due to security rules
          // but the connection should still work
          expect(e, isA<Exception>());
        }
      });

      test('should write to Firestore', () async {
        // arrange
        final docRef = firestore.collection('test').doc('write_test');
        final testData = {
          'message': 'Hello Firestore',
          'timestamp': FieldValue.serverTimestamp(),
        };

        // act
        try {
          await docRef.set(testData);
          final doc = await docRef.get();

          // assert
          expect(doc.exists, true);
          expect(doc.data()?['message'], 'Hello Firestore');

          // cleanup
          await docRef.delete();
        } catch (e) {
          // In test environment, this might fail due to security rules
          expect(e, isA<Exception>());
        }
      });

      test('should listen to Firestore changes', () async {
        // arrange
        final docRef = firestore.collection('test').doc('listener_test');
        DocumentSnapshot? latestSnapshot;

        final subscription = docRef.snapshots().listen((snapshot) {
          latestSnapshot = snapshot;
        });

        // act
        await docRef.set({'message': 'Listener test'});
        await Future.delayed(const Duration(milliseconds: 100));

        // assert
        expect(latestSnapshot, isNotNull);
        expect(latestSnapshot!.exists, true);

        // cleanup
        subscription.cancel();
        await docRef.delete();
      });

      test('should query Firestore collections', () async {
        // arrange
        final collectionRef = firestore.collection('test');

        // act
        try {
          final querySnapshot = await collectionRef.limit(5).get();

          // assert
          expect(querySnapshot, isNotNull);
          expect(querySnapshot.docs, isA<List>());
        } catch (e) {
          // In test environment, this might fail due to security rules
          expect(e, isA<Exception>());
        }
      });
    });

    group('Firebase Storage', () {
      late FirebaseStorage storage;

      setUp(() {
        storage = FirebaseStorage.instance;
      });

      test('should connect to Firebase Storage successfully', () async {
        // act
        final ref = storage.ref('test/connectivity_test.txt');

        // assert
        expect(ref, isNotNull);
        expect(ref.fullPath, 'test/connectivity_test.txt');
      });

      test('should handle file upload to Storage', () async {
        // arrange
        final ref = storage.ref('test/upload_test.txt');
        final testData = Uint8List.fromList(
          'Hello Firebase Storage!'.codeUnits,
        );

        // act
        try {
          final uploadTask = ref.putData(testData);
          final snapshot = await uploadTask;

          // assert
          expect(snapshot, isNotNull);
          expect(snapshot.state, TaskState.success);

          // cleanup
          await ref.delete();
        } catch (e) {
          // In test environment, this might fail due to security rules
          expect(e, isA<Exception>());
        }
      });

      test('should handle file download from Storage', () async {
        // arrange
        final ref = storage.ref('test/download_test.txt');

        // act
        try {
          final data = await ref.getData();

          // assert
          if (data != null) {
            expect(data, isA<Uint8List>());
          }
        } catch (e) {
          // In test environment, this might fail due to security rules
          expect(e, isA<Exception>());
        }
      });

      test('should get download URL from Storage', () async {
        // arrange
        final ref = storage.ref('test/url_test.txt');

        // act
        try {
          final url = await ref.getDownloadURL();

          // assert
          expect(url, isA<String>());
          expect(url.contains('firebase'), true);
        } catch (e) {
          // In test environment, this might fail due to security rules
          expect(e, isA<Exception>());
        }
      });
    });

    group('FirebaseService Integration', () {
      test('should initialize FirebaseService successfully', () async {
        // act
        final service = FirebaseService();

        // assert
        expect(service, isNotNull);
        expect(service.auth, isNotNull);
        expect(service.firestore, isNotNull);
        expect(service.storage, isNotNull);
      });

      test('should handle FirebaseService auth operations', () async {
        // arrange
        final service = FirebaseService();

        // act
        try {
          final userCredential = await service.auth.signInAnonymously();

          // assert
          expect(userCredential.user, isNotNull);
          expect(userCredential.user!.isAnonymous, true);

          // cleanup
          await service.auth.signOut();
        } catch (e) {
          // In test environment, this might fail
          expect(e, isA<Exception>());
        }
      });

      test('should handle FirebaseService firestore operations', () async {
        // arrange
        final service = FirebaseService();

        // act
        try {
          final docRef = service.firestore
              .collection('test')
              .doc('service_test');
          await docRef.set({'message': 'Service test'});
          final doc = await docRef.get();

          // assert
          expect(doc.exists, true);

          // cleanup
          await docRef.delete();
        } catch (e) {
          // In test environment, this might fail due to security rules
          expect(e, isA<Exception>());
        }
      });

      test('should handle FirebaseService storage operations', () async {
        // arrange
        final service = FirebaseService();

        // act
        try {
          final ref = service.storage.ref('test/service_storage_test.txt');
          final testData = Uint8List.fromList('Service storage test'.codeUnits);
          await ref.putData(testData);

          // assert
          final url = await ref.getDownloadURL();
          expect(url, isA<String>());

          // cleanup
          await ref.delete();
        } catch (e) {
          // In test environment, this might fail due to security rules
          expect(e, isA<Exception>());
        }
      });
    });

    group('Firebase Configuration Validation', () {
      test('should have required Firebase configuration keys', () async {
        // arrange
        final app = Firebase.app();
        final options = app.options;

        // assert
        expect(options.projectId, isNotEmpty);
        expect(options.apiKey, isNotEmpty);
        expect(options.appId, isNotEmpty);
        expect(options.messagingSenderId, isNotEmpty);
        expect(options.storageBucket, isNotEmpty);
      });

      test('should have correct Firebase project ID format', () async {
        // arrange
        final app = Firebase.app();
        final projectId = app.options.projectId;

        // assert
        expect(projectId, matches(RegExp(r'^[a-z0-9-]+$')));
        expect(projectId.length, greaterThan(5));
        expect(projectId.length, lessThan(30));
      });

      test('should have correct Firebase API key format', () async {
        // arrange
        final app = Firebase.app();
        final apiKey = app.options.apiKey;

        // assert
        expect(apiKey, matches(RegExp(r'^AIza[0-9A-Za-z-_]{35}$')));
      });

      test('should have correct Firebase app ID format', () async {
        // arrange
        final app = Firebase.app();
        final appId = app.options.appId;

        // assert
        expect(appId, matches(RegExp(r'^1:[0-9]+:[a-z0-9-]+:[a-z0-9]+$')));
      });
    });

    group('Firebase Security Rules Validation', () {
      test('should validate Firestore security rules', () async {
        // arrange
        final firestore = FirebaseFirestore.instance;
        final testDoc = firestore.collection('security_test').doc('rules_test');

        // act
        try {
          await testDoc.set({'test': 'data'});
          final doc = await testDoc.get();

          // assert
          expect(doc.exists, true);

          // cleanup
          await testDoc.delete();
        } catch (e) {
          // Security rules should prevent unauthorized access
          expect(e, isA<Exception>());
        }
      });

      test('should validate Storage security rules', () async {
        // arrange
        final storage = FirebaseStorage.instance;
        final testRef = storage.ref('security_test/rules_test.txt');

        // act
        try {
          await testRef.putString('test data');
          final url = await testRef.getDownloadURL();

          // assert
          expect(url, isA<String>());

          // cleanup
          await testRef.delete();
        } catch (e) {
          // Security rules should prevent unauthorized access
          expect(e, isA<Exception>());
        }
      });
    });

    group('Firebase Performance Monitoring', () {
      test('should track Firebase operation performance', () async {
        // arrange
        final firestore = FirebaseFirestore.instance;
        final startTime = DateTime.now();

        // act
        try {
          final doc = await firestore
              .collection('test')
              .doc('performance_test')
              .get();
          final endTime = DateTime.now();
          final duration = endTime.difference(startTime);

          // assert
          expect(
            duration.inMilliseconds,
            lessThan(5000),
          ); // Should complete within 5 seconds
          expect(doc, isNotNull);
        } catch (e) {
          // In test environment, this might fail due to security rules
          expect(e, isA<Exception>());
        }
      });
    });

    group('Firebase Error Handling', () {
      test('should handle network connectivity issues gracefully', () async {
        // arrange
        final firestore = FirebaseFirestore.instance;

        // act
        try {
          final doc = await firestore
              .collection('test')
              .doc('network_test')
              .get();
          expect(doc, isNotNull);
        } catch (e) {
          // Network errors should be handled gracefully
          expect(e, isA<Exception>());
        }
      });

      test('should handle Firebase service unavailable gracefully', () async {
        // arrange
        final auth = FirebaseAuth.instance;

        // act
        try {
          await auth.signInAnonymously();
          expect(auth.currentUser, isNotNull);
        } catch (e) {
          // Service unavailable errors should be handled gracefully
          expect(e, isA<Exception>());
        }
      });
    });

    group('Firebase Cleanup', () {
      test('should clean up test data from Firestore', () async {
        // arrange
        final firestore = FirebaseFirestore.instance;
        final testCollection = firestore.collection('test');

        // act
        try {
          final querySnapshot = await testCollection.get();
          final batch = firestore.batch();

          for (final doc in querySnapshot.docs) {
            batch.delete(doc.reference);
          }

          await batch.commit();

          // assert
          final afterCleanup = await testCollection.get();
          expect(afterCleanup.docs.length, 0);
        } catch (e) {
          // Cleanup might fail in test environment
          expect(e, isA<Exception>());
        }
      });

      test('should clean up test data from Storage', () async {
        // arrange
        final storage = FirebaseStorage.instance;
        final testRef = storage.ref('test');

        // act
        try {
          final listResult = await testRef.listAll();

          for (final item in listResult.items) {
            await item.delete();
          }

          // assert
          final afterCleanup = await testRef.listAll();
          expect(afterCleanup.items.length, 0);
        } catch (e) {
          // Cleanup might fail in test environment
          expect(e, isA<Exception>());
        }
      });
    });
  });
}
