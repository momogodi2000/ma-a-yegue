import 'package:flutter/foundation.dart';
import '../../domain/entities/learner_entity.dart';
import '../../domain/repositories/learner_repository.dart';
import '../../domain/usecases/learner_usecases.dart';
import '../../../../core/errors/failures.dart';

/// ViewModel for learner functionality
class LearnerViewModel extends ChangeNotifier {
  // Use cases
  final GetLearnerProfile _getLearnerProfile;
  final UpdateLearnerProfile _updateLearnerProfile;
  final GetLanguageProgress _getLanguageProgress;
  final UpdateLanguageProgress _updateLanguageProgress;
  final RecordLessonCompletion _recordLessonCompletion;
  final RecordCourseCompletion _recordCourseCompletion;
  final GetRecommendedLessons _getRecommendedLessons;
  final GetLearningStatistics _getLearningStatistics;
  final GetLearnerAchievements _getLearnerAchievements;
  final AwardAchievement _awardAchievement;
  final GetStudyStreak _getStudyStreak;
  final UpdateStudyStreak _updateStudyStreak;
  final SaveLevelAssessment _saveLevelAssessment;
  final GetAdaptiveRecommendations _getAdaptiveRecommendations;
  final GetLearningGoals _getLearningGoals;
  final SetLearningGoal _setLearningGoal;
  final UpdateGoalProgress _updateGoalProgress;
  final GetPerformanceAnalytics _getPerformanceAnalytics;
  final GetStudyPatterns _getStudyPatterns;
  final GetPeerComparison _getPeerComparison;
  final GetLearningHistory _getLearningHistory;
  final GetCurrentLearningPath _getCurrentLearningPath;
  final UpdateLearningPath _updateLearningPath;
  final GetSkillAssessments _getSkillAssessments;
  final UpdateSkillAssessment _updateSkillAssessment;
  final GetLearningRecommendations _getLearningRecommendations;
  final CompleteLearningRecommendation _completeLearningRecommendation;
  final UpdateLearningPreferences _updateLearningPreferences;
  final ResetLearnerProgress _resetLearnerProgress;

  // State
  bool _isLoading = false;
  String? _errorMessage;
  LearnerEntity? _learnerProfile;
  final Map<String, LanguageProgress> _languageProgress = {};
  List<Achievement> _achievements = [];
  Map<String, dynamic> _learningStatistics = {};
  List<String> _recommendedLessons = [];
  List<LearningGoal> _learningGoals = [];
  List<LearningRecommendation> _learningRecommendations = [];
  Map<String, dynamic> _performanceAnalytics = {};
  Map<String, dynamic> _studyPatterns = {};
  Map<String, dynamic> _peerComparison = {};
  List<Map<String, dynamic>> _learningHistory = [];
  List<String> _currentLearningPath = [];
  Map<String, double> _skillAssessments = {};
  int _studyStreak = 0;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  LearnerEntity? get learnerProfile => _learnerProfile;
  Map<String, LanguageProgress> get languageProgress => _languageProgress;
  List<Achievement> get achievements => _achievements;
  Map<String, dynamic> get learningStatistics => _learningStatistics;
  List<String> get recommendedLessons => _recommendedLessons;
  List<LearningGoal> get learningGoals => _learningGoals;
  List<LearningRecommendation> get learningRecommendations =>
      _learningRecommendations;
  Map<String, dynamic> get performanceAnalytics => _performanceAnalytics;
  Map<String, dynamic> get studyPatterns => _studyPatterns;
  Map<String, dynamic> get peerComparison => _peerComparison;
  List<Map<String, dynamic>> get learningHistory => _learningHistory;
  List<String> get currentLearningPath => _currentLearningPath;
  Map<String, double> get skillAssessments => _skillAssessments;
  int get studyStreak => _studyStreak;

  LearnerViewModel({
    required GetLearnerProfile getLearnerProfile,
    required UpdateLearnerProfile updateLearnerProfile,
    required GetLanguageProgress getLanguageProgress,
    required UpdateLanguageProgress updateLanguageProgress,
    required RecordLessonCompletion recordLessonCompletion,
    required RecordCourseCompletion recordCourseCompletion,
    required GetRecommendedLessons getRecommendedLessons,
    required GetLearningStatistics getLearningStatistics,
    required GetLearnerAchievements getLearnerAchievements,
    required AwardAchievement awardAchievement,
    required GetStudyStreak getStudyStreak,
    required UpdateStudyStreak updateStudyStreak,
    required SaveLevelAssessment saveLevelAssessment,
    required GetAdaptiveRecommendations getAdaptiveRecommendations,
    required GetLearningGoals getLearningGoals,
    required SetLearningGoal setLearningGoal,
    required UpdateGoalProgress updateGoalProgress,
    required GetPerformanceAnalytics getPerformanceAnalytics,
    required GetStudyPatterns getStudyPatterns,
    required GetPeerComparison getPeerComparison,
    required GetLearningHistory getLearningHistory,
    required GetCurrentLearningPath getCurrentLearningPath,
    required UpdateLearningPath updateLearningPath,
    required GetSkillAssessments getSkillAssessments,
    required UpdateSkillAssessment updateSkillAssessment,
    required GetLearningRecommendations getLearningRecommendations,
    required CompleteLearningRecommendation completeLearningRecommendation,
    required UpdateLearningPreferences updateLearningPreferences,
    required ResetLearnerProgress resetLearnerProgress,
  }) : _getLearnerProfile = getLearnerProfile,
       _updateLearnerProfile = updateLearnerProfile,
       _getLanguageProgress = getLanguageProgress,
       _updateLanguageProgress = updateLanguageProgress,
       _recordLessonCompletion = recordLessonCompletion,
       _recordCourseCompletion = recordCourseCompletion,
       _getRecommendedLessons = getRecommendedLessons,
       _getLearningStatistics = getLearningStatistics,
       _getLearnerAchievements = getLearnerAchievements,
       _awardAchievement = awardAchievement,
       _getStudyStreak = getStudyStreak,
       _updateStudyStreak = updateStudyStreak,
       _saveLevelAssessment = saveLevelAssessment,
       _getAdaptiveRecommendations = getAdaptiveRecommendations,
       _getLearningGoals = getLearningGoals,
       _setLearningGoal = setLearningGoal,
       _updateGoalProgress = updateGoalProgress,
       _getPerformanceAnalytics = getPerformanceAnalytics,
       _getStudyPatterns = getStudyPatterns,
       _getPeerComparison = getPeerComparison,
       _getLearningHistory = getLearningHistory,
       _getCurrentLearningPath = getCurrentLearningPath,
       _updateLearningPath = updateLearningPath,
       _getSkillAssessments = getSkillAssessments,
       _updateSkillAssessment = updateSkillAssessment,
       _getLearningRecommendations = getLearningRecommendations,
       _completeLearningRecommendation = completeLearningRecommendation,
       _updateLearningPreferences = updateLearningPreferences,
       _resetLearnerProgress = resetLearnerProgress;

  /// Load learner profile
  Future<void> loadLearnerProfile(String userId) async {
    _setLoading(true);
    _clearError();

    final result = await _getLearnerProfile(userId);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      profile,
    ) {
      _learnerProfile = profile;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Update learner profile
  Future<void> updateLearnerProfile(LearnerEntity learner) async {
    _setLoading(true);
    _clearError();

    final result = await _updateLearnerProfile(learner);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      updatedProfile,
    ) {
      _learnerProfile = updatedProfile;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load language progress
  Future<void> loadLanguageProgress(String userId, String languageCode) async {
    _setLoading(true);
    _clearError();

    final result = await _getLanguageProgress(userId, languageCode);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      progress,
    ) {
      _languageProgress[languageCode] = progress;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Update language progress
  Future<void> updateLanguageProgress(
    String userId,
    String languageCode,
    LanguageProgress progress,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _updateLanguageProgress(
      userId,
      languageCode,
      progress,
    );
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      updatedProgress,
    ) {
      _languageProgress[languageCode] = updatedProgress;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Record lesson completion
  Future<void> recordLessonCompletion({
    required String userId,
    required String lessonId,
    required String languageCode,
    required int score,
    required int timeSpentMinutes,
    required Map<String, dynamic> metadata,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _recordLessonCompletion(
      userId: userId,
      lessonId: lessonId,
      languageCode: languageCode,
      score: score,
      timeSpentMinutes: timeSpentMinutes,
      metadata: metadata,
    );

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      success,
    ) {
      if (success) {
        // Reload language progress to reflect the update
        loadLanguageProgress(userId, languageCode);
        // Update study streak
        updateStudyStreak(userId, DateTime.now());
      }
    });

    _setLoading(false);
  }

  /// Record course completion
  Future<void> recordCourseCompletion({
    required String userId,
    required String courseId,
    required String languageCode,
    required int finalScore,
    required int totalTimeSpentMinutes,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _recordCourseCompletion(
      userId: userId,
      courseId: courseId,
      languageCode: languageCode,
      finalScore: finalScore,
      totalTimeSpentMinutes: totalTimeSpentMinutes,
    );

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      success,
    ) {
      if (success) {
        // Reload language progress to reflect the update
        loadLanguageProgress(userId, languageCode);
      }
    });

    _setLoading(false);
  }

  /// Load recommended lessons
  Future<void> loadRecommendedLessons(
    String userId,
    String languageCode,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _getRecommendedLessons(userId, languageCode);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      recommendations,
    ) {
      _recommendedLessons = recommendations;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load learning statistics
  Future<void> loadLearningStatistics(String userId) async {
    _setLoading(true);
    _clearError();

    final result = await _getLearningStatistics(userId);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      statistics,
    ) {
      _learningStatistics = statistics;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load learner achievements
  Future<void> loadLearnerAchievements(String userId) async {
    _setLoading(true);
    _clearError();

    final result = await _getLearnerAchievements(userId);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      achievements,
    ) {
      _achievements = achievements;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Award achievement
  Future<void> awardAchievement(String userId, String achievementId) async {
    _setLoading(true);
    _clearError();

    final result = await _awardAchievement(userId, achievementId);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      achievement,
    ) {
      _achievements.add(achievement);
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load study streak
  Future<void> loadStudyStreak(String userId) async {
    _setLoading(true);
    _clearError();

    final result = await _getStudyStreak(userId);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      streak,
    ) {
      _studyStreak = streak;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Update study streak
  Future<void> updateStudyStreak(String userId, DateTime studyDate) async {
    _setLoading(true);
    _clearError();

    final result = await _updateStudyStreak(userId, studyDate);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      streak,
    ) {
      _studyStreak = streak;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Save level assessment
  Future<void> saveLevelAssessment({
    required String userId,
    required String languageCode,
    required String level,
    required double score,
    required Map<String, dynamic> assessmentData,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _saveLevelAssessment(
      userId: userId,
      languageCode: languageCode,
      level: level,
      score: score,
      assessmentData: assessmentData,
    );

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      success,
    ) {
      if (success) {
        // Reload language progress to reflect the update
        loadLanguageProgress(userId, languageCode);
      }
    });

    _setLoading(false);
  }

  /// Load adaptive recommendations
  Future<void> loadAdaptiveRecommendations(
    String userId,
    String languageCode,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _getAdaptiveRecommendations(userId, languageCode);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      recommendations,
    ) {
      _recommendedLessons = recommendations;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load learning goals
  Future<void> loadLearningGoals(String userId) async {
    _setLoading(true);
    _clearError();

    final result = await _getLearningGoals(userId);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (goals) {
      _learningGoals = goals;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Set learning goal
  Future<void> setLearningGoal(String userId, LearningGoal goal) async {
    _setLoading(true);
    _clearError();

    final result = await _setLearningGoal(userId, goal);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      savedGoal,
    ) {
      _learningGoals.add(savedGoal);
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Update goal progress
  Future<void> updateGoalProgress(
    String userId,
    String goalId,
    double progress,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _updateGoalProgress(userId, goalId, progress);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      updatedGoal,
    ) {
      final index = _learningGoals.indexWhere((goal) => goal.id == goalId);
      if (index != -1) {
        _learningGoals[index] = updatedGoal;
        notifyListeners();
      }
    });

    _setLoading(false);
  }

  /// Load performance analytics
  Future<void> loadPerformanceAnalytics(
    String userId,
    String languageCode,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _getPerformanceAnalytics(userId, languageCode);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      analytics,
    ) {
      _performanceAnalytics = analytics;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load study patterns
  Future<void> loadStudyPatterns(String userId) async {
    _setLoading(true);
    _clearError();

    final result = await _getStudyPatterns(userId);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      patterns,
    ) {
      _studyPatterns = patterns;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load peer comparison
  Future<void> loadPeerComparison(String userId, String languageCode) async {
    _setLoading(true);
    _clearError();

    final result = await _getPeerComparison(userId, languageCode);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      comparison,
    ) {
      _peerComparison = comparison;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load learning history
  Future<void> loadLearningHistory(String userId, {int limit = 50}) async {
    _setLoading(true);
    _clearError();

    final result = await _getLearningHistory(userId, limit: limit);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      history,
    ) {
      _learningHistory = history;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load current learning path
  Future<void> loadCurrentLearningPath(
    String userId,
    String languageCode,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _getCurrentLearningPath(userId, languageCode);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (path) {
      _currentLearningPath = path;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Update learning path
  Future<void> updateLearningPath(
    String userId,
    String languageCode,
    List<String> lessonIds,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _updateLearningPath(userId, languageCode, lessonIds);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      success,
    ) {
      if (success) {
        _currentLearningPath = lessonIds;
        notifyListeners();
      }
    });

    _setLoading(false);
  }

  /// Load skill assessments
  Future<void> loadSkillAssessments(String userId, String languageCode) async {
    _setLoading(true);
    _clearError();

    final result = await _getSkillAssessments(userId, languageCode);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      assessments,
    ) {
      _skillAssessments = assessments;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Update skill assessment
  Future<void> updateSkillAssessment(
    String userId,
    String languageCode,
    String skill,
    double score,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _updateSkillAssessment(
      userId,
      languageCode,
      skill,
      score,
    );
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      success,
    ) {
      if (success) {
        _skillAssessments[skill] = score;
        notifyListeners();
      }
    });

    _setLoading(false);
  }

  /// Load learning recommendations
  Future<void> loadLearningRecommendations(
    String userId,
    String languageCode,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _getLearningRecommendations(userId, languageCode);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      recommendations,
    ) {
      _learningRecommendations = recommendations;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Complete learning recommendation
  Future<void> completeLearningRecommendation(
    String userId,
    String recommendationId,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _completeLearningRecommendation(
      userId,
      recommendationId,
    );
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      success,
    ) {
      if (success) {
        final index = _learningRecommendations.indexWhere(
          (rec) => rec.id == recommendationId,
        );
        if (index != -1) {
          _learningRecommendations[index] = _learningRecommendations[index]
              .copyWithLearningRecommendation(
                isCompleted: true,
                completedAt: DateTime.now(),
              );
          notifyListeners();
        }
      }
    });

    _setLoading(false);
  }

  /// Update learning preferences
  Future<void> updateLearningPreferences(
    String userId,
    LearningPreferences preferences,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _updateLearningPreferences(userId, preferences);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      updatedPreferences,
    ) {
      if (_learnerProfile != null) {
        _learnerProfile = _learnerProfile?.copyWith(
          preferences: updatedPreferences,
        );
        notifyListeners();
      }
    });

    _setLoading(false);
  }

  /// Reset learner progress
  Future<void> resetLearnerProgress(String userId, String languageCode) async {
    _setLoading(true);
    _clearError();

    final result = await _resetLearnerProgress(userId, languageCode);
    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      success,
    ) {
      if (success) {
        // Reload the learner profile to reflect the reset
        loadLearnerProfile(userId);
      }
    });

    _setLoading(false);
  }

  /// Load all learner data
  Future<void> loadAllLearnerData(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      // Load all data in parallel
      await Future.wait([
        loadLearnerProfile(userId),
        loadLearningStatistics(userId),
        loadLearnerAchievements(userId),
        loadStudyStreak(userId),
        loadLearningGoals(userId),
        loadLearningHistory(userId),
      ]);

      // Load language-specific data for each language the learner is studying
      if (_learnerProfile != null) {
        for (final languageCode in _learnerProfile?.learningLanguages ?? []) {
          await Future.wait([
            loadLanguageProgress(userId, languageCode),
            loadRecommendedLessons(userId, languageCode),
            loadPerformanceAnalytics(userId, languageCode),
            loadCurrentLearningPath(userId, languageCode),
            loadSkillAssessments(userId, languageCode),
            loadLearningRecommendations(userId, languageCode),
          ]);
        }
      }
    } catch (e) {
      _setError('Failed to load learner data: $e');
    }

    _setLoading(false);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is CacheFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return 'Server error: ${failure.message}';
    } else {
      return 'An unexpected error occurred';
    }
  }
}

// Extension to add copyWith method to LearningRecommendation
extension LearningRecommendationCopyWith on LearningRecommendation {
  LearningRecommendation copyWithLearningRecommendation({
    String? id,
    String? userId,
    String? languageCode,
    String? title,
    String? description,
    RecommendationType? type,
    String? contentId,
    String? contentType,
    double? priority,
    String? reason,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isCompleted,
    Map<String, dynamic>? metadata,
  }) {
    return LearningRecommendation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      languageCode: languageCode ?? this.languageCode,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      priority: priority ?? this.priority,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Extension to add copyWith method to LearnerEntity
extension LearnerEntityCopyWith on LearnerEntity {
  LearnerEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? profileImageUrl,
    String? currentLevel,
    int? totalExperiencePoints,
    int? currentStreak,
    int? longestStreak,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
    List<String>? learningLanguages,
    Map<String, LanguageProgress>? languageProgress,
    List<String>? completedLessons,
    List<String>? completedCourses,
    List<Achievement>? achievements,
    LearningPreferences? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LearnerEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      currentLevel: currentLevel ?? this.currentLevel,
      totalExperiencePoints:
          totalExperiencePoints ?? this.totalExperiencePoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      learningLanguages: learningLanguages ?? this.learningLanguages,
      languageProgress: languageProgress ?? this.languageProgress,
      completedLessons: completedLessons ?? this.completedLessons,
      completedCourses: completedCourses ?? this.completedCourses,
      achievements: achievements ?? this.achievements,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
