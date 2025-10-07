import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/teacher_entity.dart';
import '../repositories/teacher_repository.dart';

/// Get teacher profile use case
class GetTeacherProfile {
  final TeacherRepository repository;

  GetTeacherProfile(this.repository);

  Future<Either<Failure, TeacherEntity>> call(String teacherId) async {
    return await repository.getTeacherProfile(teacherId);
  }
}

/// Update teacher profile use case
class UpdateTeacherProfile {
  final TeacherRepository repository;

  UpdateTeacherProfile(this.repository);

  Future<Either<Failure, TeacherEntity>> call(TeacherEntity teacher) async {
    return await repository.updateTeacherProfile(teacher);
  }
}

/// Get teacher courses use case
class GetTeacherCourses {
  final TeacherRepository repository;

  GetTeacherCourses(this.repository);

  Future<Either<Failure, List<CourseEntity>>> call(String teacherId) async {
    return await repository.getTeacherCourses(teacherId);
  }
}

/// Get course use case
class GetCourse {
  final TeacherRepository repository;

  GetCourse(this.repository);

  Future<Either<Failure, CourseEntity>> call(String courseId) async {
    return await repository.getCourse(courseId);
  }
}

/// Create course use case
class CreateCourse {
  final TeacherRepository repository;

  CreateCourse(this.repository);

  Future<Either<Failure, CourseEntity>> call(CourseEntity course) async {
    return await repository.createCourse(course);
  }
}

/// Update course use case
class UpdateCourse {
  final TeacherRepository repository;

  UpdateCourse(this.repository);

  Future<Either<Failure, CourseEntity>> call(CourseEntity course) async {
    return await repository.updateCourse(course);
  }
}

/// Delete course use case
class DeleteCourse {
  final TeacherRepository repository;

  DeleteCourse(this.repository);

  Future<Either<Failure, bool>> call(String courseId) async {
    return await repository.deleteCourse(courseId);
  }
}

/// Toggle course status use case
class ToggleCourseStatus {
  final TeacherRepository repository;

  ToggleCourseStatus(this.repository);

  Future<Either<Failure, bool>> call(
    String courseId,
    CourseStatus status,
  ) async {
    return await repository.toggleCourseStatus(courseId, status);
  }
}

/// Get course lessons use case
class GetCourseLessons {
  final TeacherRepository repository;

  GetCourseLessons(this.repository);

  Future<Either<Failure, List<LessonEntity>>> call(String courseId) async {
    return await repository.getCourseLessons(courseId);
  }
}

/// Get lesson use case
class GetLesson {
  final TeacherRepository repository;

  GetLesson(this.repository);

  Future<Either<Failure, LessonEntity>> call(String lessonId) async {
    return await repository.getLesson(lessonId);
  }
}

/// Create lesson use case
class CreateLesson {
  final TeacherRepository repository;

  CreateLesson(this.repository);

  Future<Either<Failure, LessonEntity>> call(LessonEntity lesson) async {
    return await repository.createLesson(lesson);
  }
}

/// Update lesson use case
class UpdateLesson {
  final TeacherRepository repository;

  UpdateLesson(this.repository);

  Future<Either<Failure, LessonEntity>> call(LessonEntity lesson) async {
    return await repository.updateLesson(lesson);
  }
}

/// Delete lesson use case
class DeleteLesson {
  final TeacherRepository repository;

  DeleteLesson(this.repository);

  Future<Either<Failure, bool>> call(String lessonId) async {
    return await repository.deleteLesson(lessonId);
  }
}

/// Toggle lesson status use case
class ToggleLessonStatus {
  final TeacherRepository repository;

  ToggleLessonStatus(this.repository);

  Future<Either<Failure, bool>> call(String lessonId, bool isPublished) async {
    return await repository.toggleLessonStatus(lessonId, isPublished);
  }
}

/// Get teacher students use case
class GetTeacherStudents {
  final TeacherRepository repository;

  GetTeacherStudents(this.repository);

  Future<Either<Failure, List<StudentEntity>>> call(String teacherId) async {
    return await repository.getTeacherStudents(teacherId);
  }
}

/// Get course students use case
class GetCourseStudents {
  final TeacherRepository repository;

  GetCourseStudents(this.repository);

  Future<Either<Failure, List<StudentEntity>>> call(String courseId) async {
    return await repository.getCourseStudents(courseId);
  }
}

/// Get student use case
class GetStudent {
  final TeacherRepository repository;

  GetStudent(this.repository);

  Future<Either<Failure, StudentEntity>> call(String studentId) async {
    return await repository.getStudent(studentId);
  }
}

/// Get student progress use case
class GetStudentProgress {
  final TeacherRepository repository;

  GetStudentProgress(this.repository);

  Future<Either<Failure, StudentProgress>> call(
    String studentId,
    String courseId,
  ) async {
    return await repository.getStudentProgress(studentId, courseId);
  }
}

/// Get course assignments use case
class GetCourseAssignments {
  final TeacherRepository repository;

  GetCourseAssignments(this.repository);

  Future<Either<Failure, List<AssignmentEntity>>> call(String courseId) async {
    return await repository.getCourseAssignments(courseId);
  }
}

/// Get assignment use case
class GetAssignment {
  final TeacherRepository repository;

  GetAssignment(this.repository);

  Future<Either<Failure, AssignmentEntity>> call(String assignmentId) async {
    return await repository.getAssignment(assignmentId);
  }
}

/// Create assignment use case
class CreateAssignment {
  final TeacherRepository repository;

  CreateAssignment(this.repository);

  Future<Either<Failure, AssignmentEntity>> call(
    AssignmentEntity assignment,
  ) async {
    return await repository.createAssignment(assignment);
  }
}

/// Update assignment use case
class UpdateAssignment {
  final TeacherRepository repository;

  UpdateAssignment(this.repository);

  Future<Either<Failure, AssignmentEntity>> call(
    AssignmentEntity assignment,
  ) async {
    return await repository.updateAssignment(assignment);
  }
}

/// Delete assignment use case
class DeleteAssignment {
  final TeacherRepository repository;

  DeleteAssignment(this.repository);

  Future<Either<Failure, bool>> call(String assignmentId) async {
    return await repository.deleteAssignment(assignmentId);
  }
}

/// Toggle assignment status use case
class ToggleAssignmentStatus {
  final TeacherRepository repository;

  ToggleAssignmentStatus(this.repository);

  Future<Either<Failure, bool>> call(
    String assignmentId,
    bool isPublished,
  ) async {
    return await repository.toggleAssignmentStatus(assignmentId, isPublished);
  }
}

/// Get assignment submissions use case
class GetAssignmentSubmissions {
  final TeacherRepository repository;

  GetAssignmentSubmissions(this.repository);

  Future<Either<Failure, List<SubmissionEntity>>> call(
    String assignmentId,
  ) async {
    return await repository.getAssignmentSubmissions(assignmentId);
  }
}

/// Get submission use case
class GetSubmission {
  final TeacherRepository repository;

  GetSubmission(this.repository);

  Future<Either<Failure, SubmissionEntity>> call(String submissionId) async {
    return await repository.getSubmission(submissionId);
  }
}

/// Grade submission use case
class GradeSubmission {
  final TeacherRepository repository;

  GradeSubmission(this.repository);

  Future<Either<Failure, SubmissionEntity>> call(
    String submissionId,
    int score,
    String? feedback,
  ) async {
    return await repository.gradeSubmission(submissionId, score, feedback);
  }
}

/// Get student grades use case
class GetStudentGrades {
  final TeacherRepository repository;

  GetStudentGrades(this.repository);

  Future<Either<Failure, List<GradeEntity>>> call(
    String studentId,
    String? courseId,
  ) async {
    return await repository.getStudentGrades(studentId, courseId);
  }
}

/// Get course grades use case
class GetCourseGrades {
  final TeacherRepository repository;

  GetCourseGrades(this.repository);

  Future<Either<Failure, List<GradeEntity>>> call(String courseId) async {
    return await repository.getCourseGrades(courseId);
  }
}

/// Create grade use case
class CreateGrade {
  final TeacherRepository repository;

  CreateGrade(this.repository);

  Future<Either<Failure, GradeEntity>> call(GradeEntity grade) async {
    return await repository.createGrade(grade);
  }
}

/// Update grade use case
class UpdateGrade {
  final TeacherRepository repository;

  UpdateGrade(this.repository);

  Future<Either<Failure, GradeEntity>> call(GradeEntity grade) async {
    return await repository.updateGrade(grade);
  }
}

/// Get teacher analytics use case
class GetTeacherAnalytics {
  final TeacherRepository repository;

  GetTeacherAnalytics(this.repository);

  Future<Either<Failure, TeacherAnalyticsEntity>> call(String teacherId) async {
    return await repository.getTeacherAnalytics(teacherId);
  }
}

/// Get course analytics use case
class GetCourseAnalytics {
  final TeacherRepository repository;

  GetCourseAnalytics(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String courseId) async {
    return await repository.getCourseAnalytics(courseId);
  }
}

/// Get student analytics use case
class GetStudentAnalytics {
  final TeacherRepository repository;

  GetStudentAnalytics(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String studentId,
    String? courseId,
  ) async {
    return await repository.getStudentAnalytics(studentId, courseId);
  }
}

/// Get assignment analytics use case
class GetAssignmentAnalytics {
  final TeacherRepository repository;

  GetAssignmentAnalytics(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String assignmentId,
  ) async {
    return await repository.getAssignmentAnalytics(assignmentId);
  }
}

/// Send message to student use case
class SendMessageToStudent {
  final TeacherRepository repository;

  SendMessageToStudent(this.repository);

  Future<Either<Failure, bool>> call(
    String teacherId,
    String studentId,
    String message,
    String subject,
  ) async {
    return await repository.sendMessageToStudent(
      teacherId,
      studentId,
      message,
      subject,
    );
  }
}

/// Get messages with student use case
class GetMessagesWithStudent {
  final TeacherRepository repository;

  GetMessagesWithStudent(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    String teacherId,
    String studentId,
  ) async {
    return await repository.getMessagesWithStudent(teacherId, studentId);
  }
}

/// Get teacher messages use case
class GetTeacherMessages {
  final TeacherRepository repository;

  GetTeacherMessages(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    String teacherId,
  ) async {
    return await repository.getTeacherMessages(teacherId);
  }
}

/// Mark message as read use case
class MarkMessageAsRead {
  final TeacherRepository repository;

  MarkMessageAsRead(this.repository);

  Future<Either<Failure, bool>> call(String messageId) async {
    return await repository.markMessageAsRead(messageId);
  }
}

/// Create announcement use case
class CreateAnnouncement {
  final TeacherRepository repository;

  CreateAnnouncement(this.repository);

  Future<Either<Failure, bool>> call(
    String courseId,
    String title,
    String content,
  ) async {
    return await repository.createAnnouncement(courseId, title, content);
  }
}

/// Get course announcements use case
class GetCourseAnnouncements {
  final TeacherRepository repository;

  GetCourseAnnouncements(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    String courseId,
  ) async {
    return await repository.getCourseAnnouncements(courseId);
  }
}

/// Update announcement use case
class UpdateAnnouncement {
  final TeacherRepository repository;

  UpdateAnnouncement(this.repository);

  Future<Either<Failure, bool>> call(
    String announcementId,
    String title,
    String content,
  ) async {
    return await repository.updateAnnouncement(announcementId, title, content);
  }
}

/// Delete announcement use case
class DeleteAnnouncement {
  final TeacherRepository repository;

  DeleteAnnouncement(this.repository);

  Future<Either<Failure, bool>> call(String announcementId) async {
    return await repository.deleteAnnouncement(announcementId);
  }
}

/// Get teacher dashboard data use case
class GetTeacherDashboardData {
  final TeacherRepository repository;

  GetTeacherDashboardData(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String teacherId) async {
    return await repository.getTeacherDashboardData(teacherId);
  }
}

/// Search students use case
class SearchStudents {
  final TeacherRepository repository;

  SearchStudents(this.repository);

  Future<Either<Failure, List<StudentEntity>>> call(
    String query,
    String? teacherId,
  ) async {
    return await repository.searchStudents(query, teacherId);
  }
}

/// Search courses use case
class SearchCourses {
  final TeacherRepository repository;

  SearchCourses(this.repository);

  Future<Either<Failure, List<CourseEntity>>> call(
    String query,
    String? teacherId,
  ) async {
    return await repository.searchCourses(query, teacherId);
  }
}

/// Get teacher notifications use case
class GetTeacherNotifications {
  final TeacherRepository repository;

  GetTeacherNotifications(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    String teacherId,
  ) async {
    return await repository.getTeacherNotifications(teacherId);
  }
}

/// Mark notification as read use case
class MarkNotificationAsRead {
  final TeacherRepository repository;

  MarkNotificationAsRead(this.repository);

  Future<Either<Failure, bool>> call(String notificationId) async {
    return await repository.markNotificationAsRead(notificationId);
  }
}

/// Get teacher settings use case
class GetTeacherSettings {
  final TeacherRepository repository;

  GetTeacherSettings(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String teacherId) async {
    return await repository.getTeacherSettings(teacherId);
  }
}

/// Update teacher settings use case
class UpdateTeacherSettings {
  final TeacherRepository repository;

  UpdateTeacherSettings(this.repository);

  Future<Either<Failure, bool>> call(
    String teacherId,
    Map<String, dynamic> settings,
  ) async {
    return await repository.updateTeacherSettings(teacherId, settings);
  }
}

/// Get teacher calendar use case
class GetTeacherCalendar {
  final TeacherRepository repository;

  GetTeacherCalendar(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    String teacherId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await repository.getTeacherCalendar(teacherId, startDate, endDate);
  }
}

/// Create calendar event use case
class CreateCalendarEvent {
  final TeacherRepository repository;

  CreateCalendarEvent(this.repository);

  Future<Either<Failure, bool>> call(
    String teacherId,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
    String? courseId,
  ) async {
    return await repository.createCalendarEvent(
      teacherId,
      title,
      description,
      startTime,
      endTime,
      courseId,
    );
  }
}

/// Update calendar event use case
class UpdateCalendarEvent {
  final TeacherRepository repository;

  UpdateCalendarEvent(this.repository);

  Future<Either<Failure, bool>> call(
    String eventId,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
  ) async {
    return await repository.updateCalendarEvent(
      eventId,
      title,
      description,
      startTime,
      endTime,
    );
  }
}

/// Delete calendar event use case
class DeleteCalendarEvent {
  final TeacherRepository repository;

  DeleteCalendarEvent(this.repository);

  Future<Either<Failure, bool>> call(String eventId) async {
    return await repository.deleteCalendarEvent(eventId);
  }
}

/// Get teacher reports use case
class GetTeacherReports {
  final TeacherRepository repository;

  GetTeacherReports(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    String teacherId,
    String reportType,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await repository.getTeacherReports(
      teacherId,
      reportType,
      startDate,
      endDate,
    );
  }
}

/// Generate report use case
class GenerateReport {
  final TeacherRepository repository;

  GenerateReport(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String teacherId,
    String reportType,
    Map<String, dynamic> parameters,
  ) async {
    return await repository.generateReport(teacherId, reportType, parameters);
  }
}

/// Export course data use case
class ExportCourseData {
  final TeacherRepository repository;

  ExportCourseData(this.repository);

  Future<Either<Failure, String>> call(String courseId, String format) async {
    return await repository.exportCourseData(courseId, format);
  }
}

/// Export student data use case
class ExportStudentData {
  final TeacherRepository repository;

  ExportStudentData(this.repository);

  Future<Either<Failure, String>> call(String studentId, String format) async {
    return await repository.exportStudentData(studentId, format);
  }
}

/// Get teacher performance metrics use case
class GetTeacherPerformanceMetrics {
  final TeacherRepository repository;

  GetTeacherPerformanceMetrics(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String teacherId) async {
    return await repository.getTeacherPerformanceMetrics(teacherId);
  }
}

/// Get course performance metrics use case
class GetCoursePerformanceMetrics {
  final TeacherRepository repository;

  GetCoursePerformanceMetrics(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String courseId) async {
    return await repository.getCoursePerformanceMetrics(courseId);
  }
}

/// Get student performance metrics use case
class GetStudentPerformanceMetrics {
  final TeacherRepository repository;

  GetStudentPerformanceMetrics(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String studentId,
    String? courseId,
  ) async {
    return await repository.getStudentPerformanceMetrics(studentId, courseId);
  }
}

/// Bulk grade assignments use case
class BulkGradeAssignments {
  final TeacherRepository repository;

  BulkGradeAssignments(this.repository);

  Future<Either<Failure, bool>> call(
    String assignmentId,
    Map<String, int> grades,
  ) async {
    return await repository.bulkGradeAssignments(assignmentId, grades);
  }
}

/// Clone course use case
class CloneCourse {
  final TeacherRepository repository;

  CloneCourse(this.repository);

  Future<Either<Failure, CourseEntity>> call(
    String courseId,
    String newTitle,
  ) async {
    return await repository.cloneCourse(courseId, newTitle);
  }
}

/// Clone assignment use case
class CloneAssignment {
  final TeacherRepository repository;

  CloneAssignment(this.repository);

  Future<Either<Failure, AssignmentEntity>> call(
    String assignmentId,
    String newTitle,
  ) async {
    return await repository.cloneAssignment(assignmentId, newTitle);
  }
}

/// Archive course use case
class ArchiveCourse {
  final TeacherRepository repository;

  ArchiveCourse(this.repository);

  Future<Either<Failure, bool>> call(String courseId) async {
    return await repository.archiveCourse(courseId);
  }
}

/// Restore archived course use case
class RestoreArchivedCourse {
  final TeacherRepository repository;

  RestoreArchivedCourse(this.repository);

  Future<Either<Failure, bool>> call(String courseId) async {
    return await repository.restoreArchivedCourse(courseId);
  }
}

/// Get archived courses use case
class GetArchivedCourses {
  final TeacherRepository repository;

  GetArchivedCourses(this.repository);

  Future<Either<Failure, List<CourseEntity>>> call(String teacherId) async {
    return await repository.getArchivedCourses(teacherId);
  }
}

/// Get teacher statistics use case
class GetTeacherStatistics {
  final TeacherRepository repository;

  GetTeacherStatistics(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String teacherId) async {
    return await repository.getTeacherStatistics(teacherId);
  }
}

/// Update teacher rating use case
class UpdateTeacherRating {
  final TeacherRepository repository;

  UpdateTeacherRating(this.repository);

  Future<Either<Failure, bool>> call(String teacherId, double rating) async {
    return await repository.updateTeacherRating(teacherId, rating);
  }
}

/// Get teacher reviews use case
class GetTeacherReviews {
  final TeacherRepository repository;

  GetTeacherReviews(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    String teacherId,
  ) async {
    return await repository.getTeacherReviews(teacherId);
  }
}

/// Respond to review use case
class RespondToReview {
  final TeacherRepository repository;

  RespondToReview(this.repository);

  Future<Either<Failure, bool>> call(String reviewId, String response) async {
    return await repository.respondToReview(reviewId, response);
  }
}

/// Send notification to student use case
class SendNotificationToStudent {
  final TeacherRepository repository;

  SendNotificationToStudent(this.repository);

  Future<Either<Failure, bool>> call(
    String teacherId,
    String studentId,
    String message,
  ) async {
    // TODO: Implement notification sending
    return Left(CacheFailure('Notification sending not implemented'));
  }
}
