import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/teacher_entity.dart';

/// Repository interface for teacher-related operations
abstract class TeacherRepository {
  /// Get teacher profile
  Future<Either<Failure, TeacherEntity>> getTeacherProfile(String teacherId);

  /// Update teacher profile
  Future<Either<Failure, TeacherEntity>> updateTeacherProfile(
    TeacherEntity teacher,
  );

  /// Get teacher's courses
  Future<Either<Failure, List<CourseEntity>>> getTeacherCourses(
    String teacherId,
  );

  /// Get specific course
  Future<Either<Failure, CourseEntity>> getCourse(String courseId);

  /// Create new course
  Future<Either<Failure, CourseEntity>> createCourse(CourseEntity course);

  /// Update course
  Future<Either<Failure, CourseEntity>> updateCourse(CourseEntity course);

  /// Delete course
  Future<Either<Failure, bool>> deleteCourse(String courseId);

  /// Publish/unpublish course
  Future<Either<Failure, bool>> toggleCourseStatus(
    String courseId,
    CourseStatus status,
  );

  /// Get course lessons
  Future<Either<Failure, List<LessonEntity>>> getCourseLessons(String courseId);

  /// Get specific lesson
  Future<Either<Failure, LessonEntity>> getLesson(String lessonId);

  /// Create new lesson
  Future<Either<Failure, LessonEntity>> createLesson(LessonEntity lesson);

  /// Update lesson
  Future<Either<Failure, LessonEntity>> updateLesson(LessonEntity lesson);

  /// Delete lesson
  Future<Either<Failure, bool>> deleteLesson(String lessonId);

  /// Publish/unpublish lesson
  Future<Either<Failure, bool>> toggleLessonStatus(
    String lessonId,
    bool isPublished,
  );

  /// Get teacher's students
  Future<Either<Failure, List<StudentEntity>>> getTeacherStudents(
    String teacherId,
  );

  /// Get students in specific course
  Future<Either<Failure, List<StudentEntity>>> getCourseStudents(
    String courseId,
  );

  /// Get specific student
  Future<Either<Failure, StudentEntity>> getStudent(String studentId);

  /// Get student progress in course
  Future<Either<Failure, StudentProgress>> getStudentProgress(
    String studentId,
    String courseId,
  );

  /// Get course assignments
  Future<Either<Failure, List<AssignmentEntity>>> getCourseAssignments(
    String courseId,
  );

  /// Get specific assignment
  Future<Either<Failure, AssignmentEntity>> getAssignment(String assignmentId);

  /// Create new assignment
  Future<Either<Failure, AssignmentEntity>> createAssignment(
    AssignmentEntity assignment,
  );

  /// Update assignment
  Future<Either<Failure, AssignmentEntity>> updateAssignment(
    AssignmentEntity assignment,
  );

  /// Delete assignment
  Future<Either<Failure, bool>> deleteAssignment(String assignmentId);

  /// Publish/unpublish assignment
  Future<Either<Failure, bool>> toggleAssignmentStatus(
    String assignmentId,
    bool isPublished,
  );

  /// Get assignment submissions
  Future<Either<Failure, List<SubmissionEntity>>> getAssignmentSubmissions(
    String assignmentId,
  );

  /// Get specific submission
  Future<Either<Failure, SubmissionEntity>> getSubmission(String submissionId);

  /// Grade submission
  Future<Either<Failure, SubmissionEntity>> gradeSubmission(
    String submissionId,
    int score,
    String? feedback,
  );

  /// Get student grades
  Future<Either<Failure, List<GradeEntity>>> getStudentGrades(
    String studentId,
    String? courseId,
  );

  /// Get course grades
  Future<Either<Failure, List<GradeEntity>>> getCourseGrades(String courseId);

  /// Create grade
  Future<Either<Failure, GradeEntity>> createGrade(GradeEntity grade);

  /// Update grade
  Future<Either<Failure, GradeEntity>> updateGrade(GradeEntity grade);

  /// Get teacher analytics
  Future<Either<Failure, TeacherAnalyticsEntity>> getTeacherAnalytics(
    String teacherId,
  );

  /// Get course analytics
  Future<Either<Failure, Map<String, dynamic>>> getCourseAnalytics(
    String courseId,
  );

  /// Get student analytics
  Future<Either<Failure, Map<String, dynamic>>> getStudentAnalytics(
    String studentId,
    String? courseId,
  );

  /// Get assignment analytics
  Future<Either<Failure, Map<String, dynamic>>> getAssignmentAnalytics(
    String assignmentId,
  );

  /// Send message to student
  Future<Either<Failure, bool>> sendMessageToStudent(
    String teacherId,
    String studentId,
    String message,
    String subject,
  );

  /// Get messages with student
  Future<Either<Failure, List<Map<String, dynamic>>>> getMessagesWithStudent(
    String teacherId,
    String studentId,
  );

  /// Get all teacher messages
  Future<Either<Failure, List<Map<String, dynamic>>>> getTeacherMessages(
    String teacherId,
  );

  /// Mark message as read
  Future<Either<Failure, bool>> markMessageAsRead(String messageId);

  /// Create announcement
  Future<Either<Failure, bool>> createAnnouncement(
    String courseId,
    String title,
    String content,
  );

  /// Get course announcements
  Future<Either<Failure, List<Map<String, dynamic>>>> getCourseAnnouncements(
    String courseId,
  );

  /// Update announcement
  Future<Either<Failure, bool>> updateAnnouncement(
    String announcementId,
    String title,
    String content,
  );

  /// Delete announcement
  Future<Either<Failure, bool>> deleteAnnouncement(String announcementId);

  /// Get teacher dashboard data
  Future<Either<Failure, Map<String, dynamic>>> getTeacherDashboardData(
    String teacherId,
  );

  /// Search students
  Future<Either<Failure, List<StudentEntity>>> searchStudents(
    String query,
    String? teacherId,
  );

  /// Search courses
  Future<Either<Failure, List<CourseEntity>>> searchCourses(
    String query,
    String? teacherId,
  );

  /// Get teacher notifications
  Future<Either<Failure, List<Map<String, dynamic>>>> getTeacherNotifications(
    String teacherId,
  );

  /// Mark notification as read
  Future<Either<Failure, bool>> markNotificationAsRead(String notificationId);

  /// Get teacher settings
  Future<Either<Failure, Map<String, dynamic>>> getTeacherSettings(
    String teacherId,
  );

  /// Update teacher settings
  Future<Either<Failure, bool>> updateTeacherSettings(
    String teacherId,
    Map<String, dynamic> settings,
  );

  /// Get teacher calendar events
  Future<Either<Failure, List<Map<String, dynamic>>>> getTeacherCalendar(
    String teacherId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Create calendar event
  Future<Either<Failure, bool>> createCalendarEvent(
    String teacherId,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
    String? courseId,
  );

  /// Update calendar event
  Future<Either<Failure, bool>> updateCalendarEvent(
    String eventId,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
  );

  /// Delete calendar event
  Future<Either<Failure, bool>> deleteCalendarEvent(String eventId);

  /// Get teacher reports
  Future<Either<Failure, List<Map<String, dynamic>>>> getTeacherReports(
    String teacherId,
    String reportType,
    DateTime startDate,
    DateTime endDate,
  );

  /// Generate report
  Future<Either<Failure, Map<String, dynamic>>> generateReport(
    String teacherId,
    String reportType,
    Map<String, dynamic> parameters,
  );

  /// Export course data
  Future<Either<Failure, String>> exportCourseData(
    String courseId,
    String format, // csv, pdf, excel
  );

  /// Export student data
  Future<Either<Failure, String>> exportStudentData(
    String studentId,
    String format,
  );

  /// Get teacher performance metrics
  Future<Either<Failure, Map<String, dynamic>>> getTeacherPerformanceMetrics(
    String teacherId,
  );

  /// Get course performance metrics
  Future<Either<Failure, Map<String, dynamic>>> getCoursePerformanceMetrics(
    String courseId,
  );

  /// Get student performance metrics
  Future<Either<Failure, Map<String, dynamic>>> getStudentPerformanceMetrics(
    String studentId,
    String? courseId,
  );

  /// Bulk grade assignments
  Future<Either<Failure, bool>> bulkGradeAssignments(
    String assignmentId,
    Map<String, int> grades, // studentId -> score
  );

  /// Clone course
  Future<Either<Failure, CourseEntity>> cloneCourse(
    String courseId,
    String newTitle,
  );

  /// Clone assignment
  Future<Either<Failure, AssignmentEntity>> cloneAssignment(
    String assignmentId,
    String newTitle,
  );

  /// Archive course
  Future<Either<Failure, bool>> archiveCourse(String courseId);

  /// Restore archived course
  Future<Either<Failure, bool>> restoreArchivedCourse(String courseId);

  /// Get archived courses
  Future<Either<Failure, List<CourseEntity>>> getArchivedCourses(
    String teacherId,
  );

  /// Get teacher statistics
  Future<Either<Failure, Map<String, dynamic>>> getTeacherStatistics(
    String teacherId,
  );

  /// Update teacher rating
  Future<Either<Failure, bool>> updateTeacherRating(
    String teacherId,
    double rating,
  );

  /// Get teacher reviews
  Future<Either<Failure, List<Map<String, dynamic>>>> getTeacherReviews(
    String teacherId,
  );

  /// Respond to review
  Future<Either<Failure, bool>> respondToReview(
    String reviewId,
    String response,
  );
}
