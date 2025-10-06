import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Test configuration and setup utilities
class TestConfig {
  static bool _isInitialized = false;

  /// Initialize test environment
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Flutter test binding
    TestWidgetsFlutterBinding.ensureInitialized();
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase for testing
    await _initializeFirebase();

    // Initialize database for testing
    await _initializeDatabase();

    // Initialize shared preferences for testing
    await _initializeSharedPreferences();

    _isInitialized = true;
  }

  /// Initialize Firebase for testing
  static Future<void> _initializeFirebase() async {
    try {
      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'test-api-key',
          appId: 'test-app-id',
          messagingSenderId: 'test-sender-id',
          projectId: 'test-project-id',
          storageBucket: 'test-storage-bucket',
        ),
      );

      // Clear any existing auth state
      await FirebaseAuth.instance.signOut();

      // Clear Firestore data (if possible in test environment)
      await _clearFirestoreData();

      // Clear Storage data (if possible in test environment)
      await _clearStorageData();
    } catch (e) {
      // In test environment, Firebase might not be fully available
      // Firebase initialization warning: $e
    }
  }

  /// Initialize database for testing
  static Future<void> _initializeDatabase() async {
    try {
      // Initialize FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } catch (e) {
      // Database initialization warning: $e
    }
  }

  /// Initialize shared preferences for testing
  static Future<void> _initializeSharedPreferences() async {
    SharedPreferences.setMockInitialValues({});
  }

  /// Clear Firestore test data
  static Future<void> _clearFirestoreData() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Clear test collections
      final testCollections = [
        'test',
        'test_users',
        'test_lessons',
        'test_conversations',
      ];

      for (final collectionName in testCollections) {
        try {
          final querySnapshot = await firestore
              .collection(collectionName)
              .get();
          final batch = firestore.batch();

          for (final doc in querySnapshot.docs) {
            batch.delete(doc.reference);
          }

          await batch.commit();
        } catch (e) {
          // Ignore errors in test environment
        }
      }
    } catch (e) {
      // Ignore errors in test environment
    }
  }

  /// Clear Storage test data
  static Future<void> _clearStorageData() async {
    try {
      final storage = FirebaseStorage.instance;

      // Clear test folder
      try {
        final testRef = storage.ref('test');
        final listResult = await testRef.listAll();

        for (final item in listResult.items) {
          await item.delete();
        }

        for (final prefix in listResult.prefixes) {
          final subListResult = await prefix.listAll();
          for (final item in subListResult.items) {
            await item.delete();
          }
        }
      } catch (e) {
        // Ignore errors in test environment
      }
    } catch (e) {
      // Ignore errors in test environment
    }
  }

  /// Clean up test environment
  static Future<void> cleanup() async {
    if (!_isInitialized) return;

    try {
      // Clear Firebase auth state
      await FirebaseAuth.instance.signOut();

      // Clear test data
      await _clearFirestoreData();
      await _clearStorageData();

      // Clear shared preferences
      SharedPreferences.setMockInitialValues({});

      _isInitialized = false;
    } catch (e) {
      // Test cleanup warning: $e
    }
  }

  /// Get test user credentials
  static Map<String, String> getTestUserCredentials() {
    return {
      'email': 'test@example.com',
      'password': 'testpassword123',
      'displayName': 'Test User',
    };
  }

  /// Get test lesson data
  static Map<String, dynamic> getTestLessonData() {
    return {
      'id': 'test-lesson-1',
      'title': 'Test Lesson',
      'description': 'This is a test lesson',
      'languageId': 'ewondo',
      'level': 1,
      'order': 1,
      'estimatedDuration': 15,
      'isCompleted': false,
      'isDownloaded': false,
      'content': [],
      'exercises': [],
      'prerequisites': [],
      'tags': ['test'],
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Get test course data
  static Map<String, dynamic> getTestCourseData() {
    return {
      'id': 'test-course-1',
      'title': 'Test Course',
      'description': 'This is a test course',
      'languageId': 'ewondo',
      'level': 1,
      'lessons': ['test-lesson-1', 'test-lesson-2'],
      'estimatedDuration': 120,
      'isCompleted': false,
      'progressPercentage': 0.0,
      'completedLessonsCount': 0,
      'totalLessonsCount': 2,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Get test AI conversation data
  static Map<String, dynamic> getTestConversationData() {
    return {
      'id': 'test-conversation-1',
      'userId': 'test-user-1',
      'title': 'Test Conversation',
      'messages': [
        {
          'id': 'msg-1',
          'conversationId': 'test-conversation-1',
          'content': 'Hello, how are you?',
          'role': 'user',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': 'msg-2',
          'conversationId': 'test-conversation-1',
          'content': 'I am doing well, thank you!',
          'role': 'assistant',
          'timestamp': DateTime.now().toIso8601String(),
        },
      ],
      'language': 'ewondo',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Get test translation data
  static Map<String, dynamic> getTestTranslationData() {
    return {
      'id': 'test-translation-1',
      'userId': 'test-user-1',
      'sourceText': 'Hello',
      'translatedText': 'Mbote',
      'sourceLanguage': 'en',
      'targetLanguage': 'ewondo',
      'confidence': 0.95,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get test pronunciation assessment data
  static Map<String, dynamic> getTestPronunciationData() {
    return {
      'id': 'test-pronunciation-1',
      'userId': 'test-user-1',
      'word': 'Mbote',
      'language': 'ewondo',
      'audioUrl': 'https://example.com/test-audio.mp3',
      'accuracy': 0.85,
      'fluency': 0.90,
      'completeness': 0.95,
      'pronunciationScore': 0.90,
      'feedback': 'Good pronunciation!',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get test content generation data
  static Map<String, dynamic> getTestContentGenerationData() {
    return {
      'id': 'test-generation-1',
      'userId': 'test-user-1',
      'type': 'lesson',
      'topic': 'Test Topic',
      'language': 'ewondo',
      'difficulty': 'beginner',
      'content': 'This is test generated content.',
      'exercises': [
        {
          'question': 'What is hello in Ewondo?',
          'answer': 'Mbote',
          'type': 'multiple_choice',
        },
      ],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get test AI recommendation data
  static Map<String, dynamic> getTestRecommendationData() {
    return {
      'id': 'test-recommendation-1',
      'userId': 'test-user-1',
      'type': 'lesson',
      'title': 'Recommended Lesson',
      'description': 'This is a recommended lesson for you.',
      'reason': 'Based on your progress, this lesson would be beneficial.',
      'priority': 'high',
      'estimatedDuration': 15,
      'language': 'ewondo',
      'difficulty': 'beginner',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get test payment data
  static Map<String, dynamic> getTestPaymentData() {
    return {
      'id': 'test-payment-1',
      'userId': 'test-user-1',
      'amount': 5000, // 5000 XAF
      'currency': 'XAF',
      'status': 'pending',
      'paymentMethod': 'mobile_money',
      'provider': 'mtn',
      'transactionId': 'test-transaction-123',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Get test gamification data
  static Map<String, dynamic> getTestGamificationData() {
    return {
      'id': 'test-gamification-1',
      'userId': 'test-user-1',
      'level': 3,
      'xp': 1500,
      'streak': 5,
      'badges': ['first_lesson', 'week_streak'],
      'achievements': ['lesson_master', 'pronunciation_expert'],
      'totalLearningTime': 3600,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Get test community data
  static Map<String, dynamic> getTestCommunityData() {
    return {
      'id': 'test-community-1',
      'userId': 'test-user-1',
      'title': 'Test Community Post',
      'content': 'This is a test community post.',
      'language': 'ewondo',
      'tags': ['greetings', 'basic'],
      'likes': 0,
      'comments': 0,
      'isPublic': true,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Wait for async operations to complete
  static Future<void> waitForAsyncOperations() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Wait for Firebase operations to complete
  static Future<void> waitForFirebaseOperations() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Wait for network operations to complete
  static Future<void> waitForNetworkOperations() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Get test timeout duration
  static Duration getTestTimeout() {
    return const Duration(seconds: 30);
  }

  /// Get integration test timeout duration
  static Duration getIntegrationTestTimeout() {
    return const Duration(minutes: 5);
  }

  /// Check if running in test environment
  static bool isTestEnvironment() {
    return true; // Always true in test files
  }

  /// Get test environment info
  static Map<String, dynamic> getTestEnvironmentInfo() {
    return {
      'isTestEnvironment': isTestEnvironment(),
      'firebaseInitialized': _isInitialized,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Test data factory for creating test objects
class TestDataFactory {
  /// Create test user
  static Map<String, dynamic> createTestUser({
    String id = 'test-user-1',
    String email = 'test@example.com',
    String displayName = 'Test User',
    String role = 'learner',
  }) {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
      'isEmailVerified': true,
      'photoUrl': null,
      'phoneNumber': null,
      'lastLoginAt': DateTime.now().toIso8601String(),
      'preferences': {'language': 'en', 'theme': 'light'},
      'subscriptionStatus': 'free',
      'subscriptionExpiresAt': null,
      'totalLearningTime': 0,
      'streak': 0,
      'level': 1,
      'xp': 0,
    };
  }

  /// Create test lesson
  static Map<String, dynamic> createTestLesson({
    String id = 'test-lesson-1',
    String title = 'Test Lesson',
    String languageId = 'ewondo',
    int level = 1,
  }) {
    return {
      'id': id,
      'title': title,
      'description': 'This is a test lesson',
      'languageId': languageId,
      'level': level,
      'order': 1,
      'estimatedDuration': 15,
      'isCompleted': false,
      'isDownloaded': false,
      'content': [],
      'exercises': [],
      'prerequisites': [],
      'tags': ['test'],
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Create test course
  static Map<String, dynamic> createTestCourse({
    String id = 'test-course-1',
    String title = 'Test Course',
    String languageId = 'ewondo',
    int level = 1,
  }) {
    return {
      'id': id,
      'title': title,
      'description': 'This is a test course',
      'languageId': languageId,
      'level': level,
      'lessons': ['test-lesson-1', 'test-lesson-2'],
      'estimatedDuration': 120,
      'isCompleted': false,
      'progressPercentage': 0.0,
      'completedLessonsCount': 0,
      'totalLessonsCount': 2,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Create test message
  static Map<String, dynamic> createTestMessage({
    String id = 'test-message-1',
    String conversationId = 'test-conversation-1',
    String content = 'Hello, how are you?',
    String role = 'user',
  }) {
    return {
      'id': id,
      'conversationId': conversationId,
      'content': content,
      'role': role,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Create test AI response
  static Map<String, dynamic> createTestAiResponse({
    String id = 'test-response-1',
    String conversationId = 'test-conversation-1',
    String content = 'I am doing well, thank you!',
    double confidence = 0.95,
    String language = 'ewondo',
  }) {
    return {
      'id': id,
      'conversationId': conversationId,
      'content': content,
      'confidence': confidence,
      'language': language,
      'suggestions': ['Mbote', 'Awo', 'Eyo'],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
