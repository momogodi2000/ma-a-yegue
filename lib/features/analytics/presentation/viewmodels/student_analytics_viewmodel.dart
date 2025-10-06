import 'package:flutter/material.dart';
import 'package:maa_yegue/features/analytics/data/services/student_analytics_service.dart';
import 'package:maa_yegue/features/analytics/data/models/student_analytics_models.dart';

/// ViewModel for student analytics dashboard
class StudentAnalyticsViewModel extends ChangeNotifier {
  final StudentAnalyticsService _analyticsService;

  StudentAnalyticsViewModel(this._analyticsService);

  StudentAnalytics? _analytics;
  bool _isLoading = false;
  String? _error;

  StudentAnalytics? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load student analytics data
  Future<void> loadAnalytics(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _analytics = await _analyticsService.getStudentAnalytics(userId);

      // Sync to Firebase in background
      _analyticsService.syncAnalyticsToFirebase(userId, _analytics!);
    } catch (e) {
      _error = 'Failed to load analytics: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh analytics data
  Future<void> refreshAnalytics(String userId) async {
    await loadAnalytics(userId);
  }
}
