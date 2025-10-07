import 'package:flutter/foundation.dart';
import 'dart:async';

/// Firebase Request Optimizer
///
/// Batches and optimizes Firebase requests to reduce network calls
/// and improve performance
class FirebaseRequestOptimizer {
  // Batch analytics events
  static final List<Map<String, dynamic>> _pendingAnalyticsEvents = [];
  static Timer? _analyticsFlushTimer;
  static const Duration _flushInterval = Duration(seconds: 30);
  
  // Request throttling
  static final Map<String, DateTime> _lastRequestTimes = {};
  static const Duration _throttleDuration = Duration(milliseconds: 500);

  // ==================== ANALYTICS BATCHING ====================

  /// Queue analytics event (will be flushed periodically)
  static void queueAnalyticsEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) {
    _pendingAnalyticsEvents.add({
      'name': name,
      'parameters': parameters,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Start flush timer if not already running
    _analyticsFlushTimer ??= Timer.periodic(_flushInterval, (_) {
      flushAnalyticsEvents();
    });

    // Flush immediately if batch is large
    if (_pendingAnalyticsEvents.length >= 50) {
      flushAnalyticsEvents();
    }
  }

  /// Flush all pending analytics events
  static Future<void> flushAnalyticsEvents() async {
    if (_pendingAnalyticsEvents.isEmpty) return;

    final eventsToFlush = List<Map<String, dynamic>>.from(_pendingAnalyticsEvents);
    _pendingAnalyticsEvents.clear();

    try {
      // Here you would send events to Firebase Analytics
      // For hybrid architecture, we batch them to reduce requests
      debugPrint('📊 Flushing ${eventsToFlush.length} analytics events');
      
      // TODO: Implement actual Firebase Analytics batch send
      // await _firebaseAnalytics.logEvents(eventsToFlush);
      
    } catch (e) {
      debugPrint('⚠️ Failed to flush analytics events: $e');
      // Re-queue failed events
      _pendingAnalyticsEvents.addAll(eventsToFlush);
    }
  }

  // ==================== REQUEST THROTTLING ====================

  /// Check if a request type can be made (throttling)
  static bool canMakeRequest(String requestType) {
    final lastTime = _lastRequestTimes[requestType];
    if (lastTime == null) return true;

    final timeSinceLastRequest = DateTime.now().difference(lastTime);
    return timeSinceLastRequest >= _throttleDuration;
  }

  /// Record that a request was made
  static void recordRequest(String requestType) {
    _lastRequestTimes[requestType] = DateTime.now();
  }

  /// Throttled request wrapper
  static Future<T?> throttledRequest<T>({
    required String requestType,
    required Future<T> Function() request,
  }) async {
    if (!canMakeRequest(requestType)) {
      debugPrint('⏸️ Request "$requestType" throttled');
      return null;
    }

    recordRequest(requestType);
    return await request();
  }

  // ==================== NOTIFICATION BATCHING ====================

  static final List<Map<String, dynamic>> _pendingNotifications = [];

  /// Queue notification to be sent
  static void queueNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    _pendingNotifications.add({
      'userId': userId,
      'title': title,
      'body': body,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Flush if batch is large
    if (_pendingNotifications.length >= 20) {
      flushNotifications();
    }
  }

  /// Flush all pending notifications
  static Future<void> flushNotifications() async {
    if (_pendingNotifications.isEmpty) return;

    final notificationsToFlush = List<Map<String, dynamic>>.from(_pendingNotifications);
    _pendingNotifications.clear();

    try {
      debugPrint('🔔 Flushing ${notificationsToFlush.length} notifications');
      
      // TODO: Implement actual Firebase Cloud Messaging batch send
      // await _firebaseMessaging.sendBatchNotifications(notificationsToFlush);
      
    } catch (e) {
      debugPrint('⚠️ Failed to flush notifications: $e');
    }
  }

  // ==================== CONNECTION POOLING ====================

  static int _activeConnections = 0;
  static const int _maxConnections = 5;

  /// Check if can make new connection
  static bool canMakeConnection() {
    return _activeConnections < _maxConnections;
  }

  /// Acquire connection
  static void acquireConnection() {
    _activeConnections++;
  }

  /// Release connection
  static void releaseConnection() {
    if (_activeConnections > 0) {
      _activeConnections--;
    }
  }

  /// Get connection pool stats
  static Map<String, dynamic> getConnectionStats() {
    return {
      'active_connections': _activeConnections,
      'max_connections': _maxConnections,
      'available': _maxConnections - _activeConnections,
    };
  }

  // ==================== CLEANUP ====================

  /// Clean up optimizer state
  static void dispose() {
    _analyticsFlushTimer?.cancel();
    _analyticsFlushTimer = null;
    _pendingAnalyticsEvents.clear();
    _pendingNotifications.clear();
    _lastRequestTimes.clear();
    _activeConnections = 0;
    debugPrint('🧹 Firebase optimizer disposed');
  }

  /// Get optimizer statistics
  static Map<String, dynamic> getStatistics() {
    return {
      'pending_analytics_events': _pendingAnalyticsEvents.length,
      'pending_notifications': _pendingNotifications.length,
      'throttled_request_types': _lastRequestTimes.length,
      'connection_stats': getConnectionStats(),
      'timer_active': _analyticsFlushTimer?.isActive ?? false,
    };
  }

  // ==================== PERIODIC MAINTENANCE ====================

  /// Schedule periodic maintenance tasks
  static void scheduleMaintenance() {
    // Flush analytics every 30 seconds
    Timer.periodic(const Duration(seconds: 30), (_) {
      flushAnalyticsEvents();
    });

    // Flush notifications every minute
    Timer.periodic(const Duration(minutes: 1), (_) {
      flushNotifications();
    });

    // Clean up old throttle records every 5 minutes
    Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanupOldThrottleRecords();
    });

    debugPrint('✅ Firebase maintenance scheduled');
  }

  static void _cleanupOldThrottleRecords() {
    final now = DateTime.now();
    _lastRequestTimes.removeWhere((key, time) {
      return now.difference(time) > const Duration(minutes: 10);
    });
  }
}
