import 'package:flutter/foundation.dart';
import '../../domain/entities/teacher_entity.dart';
import '../../domain/usecases/teacher_usecases.dart';

/// Teacher ViewModel for state management
class TeacherViewModel extends ChangeNotifier {
  final GetTeacherProfile _getTeacherProfile;
  final UpdateTeacherProfile _updateTeacherProfile;
  final GetTeacherCourses _getTeacherCourses;
  final CreateCourse _createCourse;
  final UpdateCourse _updateCourse;
  final DeleteCourse _deleteCourse;
  final GetCourseLessons _getCourseLessons;
  final CreateLesson _createLesson;
  final UpdateLesson _updateLesson;
  final DeleteLesson _deleteLesson;
  final GetTeacherStudents _getTeacherStudents;
  final GetCourseStudents _getCourseStudents;
  final GetCourseAssignments _getCourseAssignments;
  final CreateAssignment _createAssignment;
  final UpdateAssignment _updateAssignment;
  final DeleteAssignment _deleteAssignment;
  final GetAssignmentSubmissions _getAssignmentSubmissions;
  final GradeSubmission _gradeSubmission;
  final GetStudentGrades _getStudentGrades;
  final GetCourseGrades _getCourseGrades;
  final GetTeacherAnalytics _getTeacherAnalytics;
  final GetTeacherMessages _getTeacherMessages;
  final GetMessagesWithStudent _getMessagesWithStudent;
  final SendMessageToStudent _sendMessage;
  final GetCourseAnnouncements _getCourseAnnouncements;
  final CreateAnnouncement _createAnnouncement;
  final GetTeacherNotifications _getTeacherNotifications;
  final SendNotificationToStudent _sendNotification;
  final GetTeacherSettings _getTeacherSettings;
  final UpdateTeacherSettings _updateTeacherSettings;
  final GetTeacherCalendar _getTeacherCalendar;
  final CreateCalendarEvent _createCalendarEvent;
  final GetTeacherReports _getTeacherReports;
  final GenerateReport _generateReport;

  TeacherViewModel({
    required GetTeacherProfile getTeacherProfile,
    required UpdateTeacherProfile updateTeacherProfile,
    required GetTeacherCourses getTeacherCourses,
    required CreateCourse createCourse,
    required UpdateCourse updateCourse,
    required DeleteCourse deleteCourse,
    required GetCourseLessons getCourseLessons,
    required CreateLesson createLesson,
    required UpdateLesson updateLesson,
    required DeleteLesson deleteLesson,
    required GetTeacherStudents getTeacherStudents,
    required GetCourseStudents getCourseStudents,
    required GetCourseAssignments getCourseAssignments,
    required CreateAssignment createAssignment,
    required UpdateAssignment updateAssignment,
    required DeleteAssignment deleteAssignment,
    required GetAssignmentSubmissions getAssignmentSubmissions,
    required GradeSubmission gradeSubmission,
    required GetStudentGrades getStudentGrades,
    required GetCourseGrades getCourseGrades,
    required GetTeacherAnalytics getTeacherAnalytics,
    required GetTeacherMessages getTeacherMessages,
    required GetMessagesWithStudent getMessagesWithStudent,
    required SendMessage sendMessage,
    required GetCourseAnnouncements getCourseAnnouncements,
    required CreateAnnouncement createAnnouncement,
    required GetTeacherNotifications getTeacherNotifications,
    required SendNotification sendNotification,
    required GetTeacherSettings getTeacherSettings,
    required UpdateTeacherSettings updateTeacherSettings,
    required GetTeacherCalendar getTeacherCalendar,
    required CreateCalendarEvent createCalendarEvent,
    required GetTeacherReports getTeacherReports,
    required GenerateReport generateReport,
  }) : _getTeacherProfile = getTeacherProfile,
       _updateTeacherProfile = updateTeacherProfile,
       _getTeacherCourses = getTeacherCourses,
       _createCourse = createCourse,
       _updateCourse = updateCourse,
       _deleteCourse = deleteCourse,
       _getCourseLessons = getCourseLessons,
       _createLesson = createLesson,
       _updateLesson = updateLesson,
       _deleteLesson = deleteLesson,
       _getTeacherStudents = getTeacherStudents,
       _getCourseStudents = getCourseStudents,
       _getCourseAssignments = getCourseAssignments,
       _createAssignment = createAssignment,
       _updateAssignment = updateAssignment,
       _deleteAssignment = deleteAssignment,
       _getAssignmentSubmissions = getAssignmentSubmissions,
       _gradeSubmission = gradeSubmission,
       _getStudentGrades = getStudentGrades,
       _getCourseGrades = getCourseGrades,
       _getTeacherAnalytics = getTeacherAnalytics,
       _getTeacherMessages = getTeacherMessages,
       _getMessagesWithStudent = getMessagesWithStudent,
       _sendMessage = sendMessage,
       _getCourseAnnouncements = getCourseAnnouncements,
       _createAnnouncement = createAnnouncement,
       _getTeacherNotifications = getTeacherNotifications,
       _sendNotification = sendNotification,
       _getTeacherSettings = getTeacherSettings,
       _updateTeacherSettings = updateTeacherSettings,
       _getTeacherCalendar = getTeacherCalendar,
       _createCalendarEvent = createCalendarEvent,
       _getTeacherReports = getTeacherReports,
       _generateReport = generateReport;

  // State variables
  TeacherEntity? _teacherProfile;
  List<CourseEntity> _courses = [];
  List<LessonEntity> _lessons = [];
  List<StudentEntity> _students = [];
  List<AssignmentEntity> _assignments = [];
  List<SubmissionEntity> _submissions = [];
  List<GradeEntity> _grades = [];
  TeacherAnalyticsEntity? _analytics;
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _announcements = [];
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _calendar = [];
  List<Map<String, dynamic>> _reports = [];
  Map<String, dynamic>? _settings;

  bool _isLoading = false;
  String? _error;

  // Getters
  TeacherEntity? get teacherProfile => _teacherProfile;
  List<CourseEntity> get courses => _courses;
  List<LessonEntity> get lessons => _lessons;
  List<StudentEntity> get students => _students;
  List<AssignmentEntity> get assignments => _assignments;
  List<SubmissionEntity> get submissions => _submissions;
  List<GradeEntity> get grades => _grades;
  TeacherAnalyticsEntity? get analytics => _analytics;
  List<Map<String, dynamic>> get messages => _messages;
  List<Map<String, dynamic>> get announcements => _announcements;
  List<Map<String, dynamic>> get notifications => _notifications;
  List<Map<String, dynamic>> get calendar => _calendar;
  List<Map<String, dynamic>> get reports => _reports;
  Map<String, dynamic>? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Load teacher profile
  Future<void> loadTeacherProfile(String teacherId) async {
    _setLoading(true);
    _clearError();

    final result = await _getTeacherProfile(teacherId);
    result.fold((failure) => _setError(failure.message), (teacher) {
      _teacherProfile = teacher;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Update teacher profile
  Future<void> updateTeacherProfile(TeacherEntity teacher) async {
    _setLoading(true);
    _clearError();

    final result = await _updateTeacherProfile(teacher);
    result.fold((failure) => _setError(failure.message), (updatedTeacher) {
      _teacherProfile = updatedTeacher;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load teacher courses
  Future<void> loadTeacherCourses(String teacherId) async {
    _setLoading(true);
    _clearError();

    final result = await _getTeacherCourses(teacherId);
    result.fold((failure) => _setError(failure.message), (courses) {
      _courses = courses;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Create new course
  Future<void> createCourse(CourseEntity course) async {
    _setLoading(true);
    _clearError();

    final result = await _createCourse(course);
    result.fold((failure) => _setError(failure.message), (createdCourse) {
      _courses.add(createdCourse);
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Update course
  Future<void> updateCourse(CourseEntity course) async {
    _setLoading(true);
    _clearError();

    final result = await _updateCourse(course);
    result.fold((failure) => _setError(failure.message), (updatedCourse) {
      final index = _courses.indexWhere((c) => c.id == updatedCourse.id);
      if (index != -1) {
        _courses[index] = updatedCourse;
        notifyListeners();
      }
    });

    _setLoading(false);
  }

  /// Delete course
  Future<void> deleteCourse(String courseId) async {
    _setLoading(true);
    _clearError();

    final result = await _deleteCourse(courseId);
    result.fold((failure) => _setError(failure.message), (_) {
      _courses.removeWhere((c) => c.id == courseId);
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load course lessons
  Future<void> loadCourseLessons(String courseId) async {
    _setLoading(true);
    _clearError();

    final result = await _getCourseLessons(courseId);
    result.fold((failure) => _setError(failure.message), (lessons) {
      _lessons = lessons;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Create new lesson
  Future<void> createLesson(LessonEntity lesson) async {
    _setLoading(true);
    _clearError();

    final result = await _createLesson(lesson);
    result.fold((failure) => _setError(failure.message), (createdLesson) {
      _lessons.add(createdLesson);
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Update lesson
  Future<void> updateLesson(LessonEntity lesson) async {
    _setLoading(true);
    _clearError();

    final result = await _updateLesson(lesson);
    result.fold((failure) => _setError(failure.message), (updatedLesson) {
      final index = _lessons.indexWhere((l) => l.id == updatedLesson.id);
      if (index != -1) {
        _lessons[index] = updatedLesson;
        notifyListeners();
      }
    });

    _setLoading(false);
  }

  /// Delete lesson
  Future<void> deleteLesson(String lessonId) async {
    _setLoading(true);
    _clearError();

    final result = await _deleteLesson(lessonId);
    result.fold((failure) => _setError(failure.message), (_) {
      _lessons.removeWhere((l) => l.id == lessonId);
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load teacher students
  Future<void> loadTeacherStudents(String teacherId) async {
    _setLoading(true);
    _clearError();

    final result = await _getTeacherStudents(teacherId);
    result.fold((failure) => _setError(failure.message), (students) {
      _students = students;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load course students
  Future<void> loadCourseStudents(String courseId) async {
    _setLoading(true);
    _clearError();

    final result = await _getCourseStudents(courseId);
    result.fold((failure) => _setError(failure.message), (students) {
      _students = students;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load course assignments
  Future<void> loadCourseAssignments(String courseId) async {
    _setLoading(true);
    _clearError();

    final result = await _getCourseAssignments(courseId);
    result.fold((failure) => _setError(failure.message), (assignments) {
      _assignments = assignments;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Create new assignment
  Future<void> createAssignment(AssignmentEntity assignment) async {
    _setLoading(true);
    _clearError();

    final result = await _createAssignment(assignment);
    result.fold((failure) => _setError(failure.message), (createdAssignment) {
      _assignments.add(createdAssignment);
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Update assignment
  Future<void> updateAssignment(AssignmentEntity assignment) async {
    _setLoading(true);
    _clearError();

    final result = await _updateAssignment(assignment);
    result.fold((failure) => _setError(failure.message), (updatedAssignment) {
      final index = _assignments.indexWhere(
        (a) => a.id == updatedAssignment.id,
      );
      if (index != -1) {
        _assignments[index] = updatedAssignment;
        notifyListeners();
      }
    });

    _setLoading(false);
  }

  /// Delete assignment
  Future<void> deleteAssignment(String assignmentId) async {
    _setLoading(true);
    _clearError();

    final result = await _deleteAssignment(assignmentId);
    result.fold((failure) => _setError(failure.message), (_) {
      _assignments.removeWhere((a) => a.id == assignmentId);
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load assignment submissions
  Future<void> loadAssignmentSubmissions(String assignmentId) async {
    _setLoading(true);
    _clearError();

    final result = await _getAssignmentSubmissions(assignmentId);
    result.fold((failure) => _setError(failure.message), (submissions) {
      _submissions = submissions;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Grade submission
  Future<void> gradeSubmission(
    String submissionId,
    int score,
    String? feedback,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _gradeSubmission(submissionId, score, feedback);
    result.fold((failure) => _setError(failure.message), (updatedSubmission) {
      final index = _submissions.indexWhere((s) => s.id == submissionId);
      if (index != -1) {
        _submissions[index] = updatedSubmission;
        notifyListeners();
      }
    });

    _setLoading(false);
  }

  /// Load student grades
  Future<void> loadStudentGrades(String studentId, String? courseId) async {
    _setLoading(true);
    _clearError();

    final result = await _getStudentGrades(studentId, courseId);
    result.fold((failure) => _setError(failure.message), (grades) {
      _grades = grades;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load course grades
  Future<void> loadCourseGrades(String courseId) async {
    _setLoading(true);
    _clearError();

    final result = await _getCourseGrades(courseId);
    result.fold((failure) => _setError(failure.message), (grades) {
      _grades = grades;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load teacher analytics
  Future<void> loadTeacherAnalytics(String teacherId) async {
    _setLoading(true);
    _clearError();

    final result = await _getTeacherAnalytics(teacherId);
    result.fold((failure) => _setError(failure.message), (analytics) {
      _analytics = analytics;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load teacher messages
  Future<void> loadTeacherMessages(String teacherId) async {
    _setLoading(true);
    _clearError();

    final result = await _getTeacherMessages(teacherId);
    result.fold((failure) => _setError(failure.message), (messages) {
      _messages = messages;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load messages with student
  Future<void> loadMessagesWithStudent(
    String teacherId,
    String studentId,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _getMessagesWithStudent(teacherId, studentId);
    result.fold((failure) => _setError(failure.message), (messages) {
      _messages = messages;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Send message
  Future<void> sendMessage(
    String teacherId,
    String studentId,
    String message,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _sendMessage(teacherId, studentId, message, 'Message from teacher');
    result.fold((failure) => _setError(failure.message), (_) {
      _messages.add({
        'teacherId': teacherId,
        'studentId': studentId,
        'message': message,
        'createdAt': DateTime.now().toIso8601String(),
      });
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load course announcements
  Future<void> loadCourseAnnouncements(String courseId) async {
    _setLoading(true);
    _clearError();

    final result = await _getCourseAnnouncements(courseId);
    result.fold((failure) => _setError(failure.message), (announcements) {
      _announcements = announcements;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Create announcement
  Future<void> createAnnouncement(
    String courseId,
    String title,
    String content,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _createAnnouncement(courseId, title, content);
    result.fold((failure) => _setError(failure.message), (_) {
      _announcements.add({
        'courseId': courseId,
        'title': title,
        'content': content,
        'createdAt': DateTime.now().toIso8601String(),
      });
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load teacher notifications
  Future<void> loadTeacherNotifications(String teacherId) async {
    _setLoading(true);
    _clearError();

    final result = await _getTeacherNotifications(teacherId);
    result.fold((failure) => _setError(failure.message), (notifications) {
      _notifications = notifications;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Send notification
  Future<void> sendNotification(
    String teacherId,
    String studentId,
    String message,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _sendNotification(teacherId, studentId, message);
    result.fold((failure) => _setError(failure.message), (_) {
      _notifications.add({
        'teacherId': teacherId,
        'studentId': studentId,
        'message': message,
        'createdAt': DateTime.now().toIso8601String(),
      });
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load teacher settings
  Future<void> loadTeacherSettings(String teacherId) async {
    _setLoading(true);
    _clearError();

    final result = await _getTeacherSettings(teacherId);
    result.fold((failure) => _setError(failure.message), (settings) {
      _settings = settings;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Update teacher settings
  Future<void> updateTeacherSettings(
    String teacherId,
    Map<String, dynamic> settings,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _updateTeacherSettings(teacherId, settings);
    result.fold((failure) => _setError(failure.message), (_) {
      _settings = settings;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load teacher calendar
  Future<void> loadTeacherCalendar(
    String teacherId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _getTeacherCalendar(teacherId, startDate, endDate);
    result.fold((failure) => _setError(failure.message), (calendar) {
      _calendar = calendar;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Create calendar event
  Future<void> createCalendarEvent(
    String teacherId,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
    String? location,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _createCalendarEvent(
      teacherId,
      title,
      description,
      startTime,
      endTime,
      location,
    );
    result.fold((failure) => _setError(failure.message), (_) {
      _calendar.add({
        'teacherId': teacherId,
        'title': title,
        'description': description,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'location': location,
        'createdAt': DateTime.now().toIso8601String(),
      });
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Load teacher reports
  Future<void> loadTeacherReports(
    String teacherId,
    String reportType,
    DateTime startDate,
    DateTime endDate,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _getTeacherReports(
      teacherId,
      reportType,
      startDate,
      endDate,
    );
    result.fold((failure) => _setError(failure.message), (reports) {
      _reports = reports;
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Generate report
  Future<void> generateReport(
    String teacherId,
    String reportType,
    Map<String, dynamic> data,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _generateReport(teacherId, reportType, data);
    result.fold((failure) => _setError(failure.message), (generatedReport) {
      _reports.add(generatedReport);
      notifyListeners();
    });

    _setLoading(false);
  }

  /// Clear all data
  void clearData() {
    _teacherProfile = null;
    _courses.clear();
    _lessons.clear();
    _students.clear();
    _assignments.clear();
    _submissions.clear();
    _grades.clear();
    _analytics = null;
    _messages.clear();
    _announcements.clear();
    _notifications.clear();
    _calendar.clear();
    _reports.clear();
    _settings = null;
    _error = null;
    notifyListeners();
  }
}
