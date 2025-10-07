import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import '../database/unified_database_service.dart';

/// Firebase service for centralized Firebase operations
///
/// ✅ HYBRID ARCHITECTURE IMPLEMENTATION:
/// - Firebase Services: Authentication, FCM, Analytics, Crashlytics, Storage, Firestore (limited use)
/// - SQLite: PRIMARY data storage (users, progress, lessons, quizzes, dictionary, etc.)
///
/// ⚠️ FIRESTORE USAGE POLICY:
/// - Primary data MUST use UnifiedDatabaseService (SQLite)
/// - Firestore ONLY for: AI conversations, real-time features, temporary data
///
/// Firebase is used for:
/// 1. Authentication (sign in, sign up, password reset)
/// 2. Push Notifications (FCM)
/// 3. Analytics and Crash Reporting
/// 4. File Storage (images, audio, video)
/// 5. Firestore (limited: AI conversations, real-time chat, newsletter)
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late final FirebaseAuth _auth;
  late final FirebaseStorage _storage;
  late final FirebaseMessaging _messaging;
  late final FirebaseAnalytics _analytics;
  late final FirebaseCrashlytics _crashlytics;
  late final FirebaseFirestore _firestore;

  // Reference to unified database service for ALL data operations
  final UnifiedDatabaseService _database = UnifiedDatabaseService.instance;

  bool _initialized = false;

  /// Initialize Firebase services
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();

      _auth = FirebaseAuth.instance;
      _storage = FirebaseStorage.instance;
      _messaging = FirebaseMessaging.instance;
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;
      _firestore = FirebaseFirestore.instance;

      // Configure Crashlytics
      await _crashlytics.setCrashlyticsCollectionEnabled(true);

      // Request notification permissions
      await _requestNotificationPermissions();

      _initialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Get Firebase Auth instance
  FirebaseAuth get auth => _auth;

  /// Get Storage instance
  FirebaseStorage get storage => _storage;

  /// Get Messaging instance
  FirebaseMessaging get messaging => _messaging;

  /// Get Analytics instance
  FirebaseAnalytics get analytics => _analytics;

  /// Get Crashlytics instance
  FirebaseCrashlytics get crashlytics => _crashlytics;

  /// Get Firestore instance (use sparingly - prefer SQLite for data storage)
  FirebaseFirestore get firestore => _firestore;

  /// Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      final token = await _messaging.getToken();

      // Save token to user profile in SQLite if user is authenticated
      if (token != null && currentUser != null) {
        try {
          // Get user from SQLite by Firebase UID
          final existingUser = await _database.getUserByFirebaseUid(
            currentUser!.uid,
          );

          if (existingUser != null) {
            // Update FCM token in SQLite
            await _database.upsertUser({
              'user_id': existingUser['user_id'],
              'firebase_uid': currentUser!.uid,
              'fcm_token': token,
              'fcm_token_updated_at': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          // Silently fail if user doesn't exist yet
          // Token will be saved on next login
          await _crashlytics.recordError(
            e,
            null,
            reason: 'Failed to save FCM token',
          );
        }
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        if (currentUser != null) {
          try {
            final existingUser = await _database.getUserByFirebaseUid(
              currentUser!.uid,
            );

            if (existingUser != null) {
              await _database.upsertUser({
                'user_id': existingUser['user_id'],
                'firebase_uid': currentUser!.uid,
                'fcm_token': newToken,
                'fcm_token_updated_at': DateTime.now().toIso8601String(),
              });
            }
          } catch (e) {
            await _crashlytics.recordError(
              e,
              null,
              reason: 'Failed to update FCM token',
            );
          }
        }
      });
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Log analytics event
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  /// Set user properties for analytics
  Future<void> setUserProperties({
    required String userId,
    String? userRole,
    String? subscriptionStatus,
  }) async {
    await _analytics.setUserId(id: userId);

    if (userRole != null) {
      await _analytics.setUserProperty(name: 'user_role', value: userRole);
    }

    if (subscriptionStatus != null) {
      await _analytics.setUserProperty(
        name: 'subscription_status',
        value: subscriptionStatus,
      );
    }
  }

  /// Get user from SQLite database by Firebase UID
  Future<Map<String, dynamic>?> getUserData(String firebaseUid) async {
    return await _database.getUserByFirebaseUid(firebaseUid);
  }

  /// Record error to Crashlytics
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    await _crashlytics.recordError(error, stackTrace, reason: reason);
  }

  /// Upload file to Firebase Storage
  Future<String?> uploadFile(
    String path,
    Uint8List bytes,
    String filename,
  ) async {
    try {
      final ref = _storage.ref().child(path).child(filename);
      await ref.putData(bytes);
      return await ref.getDownloadURL();
    } catch (e) {
      await recordError(e, StackTrace.current, reason: 'Storage upload failed');
      return null;
    }
  }

  /// Delete file from Firebase Storage
  Future<bool> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
      return true;
    } catch (e) {
      await recordError(e, StackTrace.current, reason: 'Storage delete failed');
      return false;
    }
  }
}
