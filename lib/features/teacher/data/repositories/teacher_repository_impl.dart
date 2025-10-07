import 'package:dartz/dartz.dart';
import '../../domain/entities/teacher_entity.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/teacher_datasource.dart';
import '../models/teacher_model.dart';

/// Teacher repository implementation
class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherDataSource _dataSource;

  TeacherRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, TeacherEntity>> getTeacherProfile(
    String teacherId,
  ) async {
    try {
      final teacher = await _dataSource.getTeacherProfile(teacherId);
      if (teacher == null) {
        return Left(CacheFailure('Teacher profile not found'));
      }
      return Right(teacher.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get teacher profile: $e'));
    }
  }

  @override
  Future<Either<Failure, TeacherEntity>> updateTeacherProfile(
    TeacherEntity teacher,
  ) async {
    try {
      final teacherModel = TeacherModel.fromEntity(teacher);
      await _dataSource.saveTeacherProfile(teacherModel);
      return Right(teacher);
    } catch (e) {
      return Left(CacheFailure('Failed to update teacher profile: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getTeacherCourses(
    String teacherId,
  ) async {
    try {
      final courses = await _dataSource.getTeacherCourses(teacherId);
      return Right(courses.map((course) => course.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get teacher courses: $e'));
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> createCourse(
    CourseEntity course,
  ) async {
    try {
      final courseModel = CourseModel.fromEntity(course);
      await _dataSource.saveCourse(courseModel);
      return Right(course);
    } catch (e) {
      return Left(CacheFailure('Failed to create course: $e'));
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> updateCourse(
    CourseEntity course,
  ) async {
    try {
      final courseModel = CourseModel.fromEntity(course);
      await _dataSource.saveCourse(courseModel);
      return Right(course);
    } catch (e) {
      return Left(CacheFailure('Failed to update course: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCourse(String courseId) async {
    try {
      await _dataSource.deleteCourse(courseId);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to delete course: $e'));
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> getCourseById(String courseId) async {
    try {
      final course = await _dataSource.getCourse(courseId);
      if (course == null) {
        return Left(CacheFailure('Course not found'));
      }
      return Right(course.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get course: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LessonEntity>>> getCourseLessons(
    String courseId,
  ) async {
    try {
      final lessons = await _dataSource.getCourseLessons(courseId);
      return Right(lessons.map((lesson) => lesson.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get course lessons: $e'));
    }
  }

  @override
  Future<Either<Failure, LessonEntity>> createLesson(
    LessonEntity lesson,
  ) async {
    try {
      final lessonModel = LessonModel.fromEntity(lesson);
      await _dataSource.saveLesson(lessonModel);
      return Right(lesson);
    } catch (e) {
      return Left(CacheFailure('Failed to create lesson: $e'));
    }
  }

  @override
  Future<Either<Failure, LessonEntity>> updateLesson(
    LessonEntity lesson,
  ) async {
    try {
      final lessonModel = LessonModel.fromEntity(lesson);
      await _dataSource.saveLesson(lessonModel);
      return Right(lesson);
    } catch (e) {
      return Left(CacheFailure('Failed to update lesson: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteLesson(String lessonId) async {
    try {
      await _dataSource.deleteLesson(lessonId);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to delete lesson: $e'));
    }
  }

  @override
  Future<Either<Failure, LessonEntity>> getLessonById(String lessonId) async {
    try {
      final lesson = await _dataSource.getLesson(lessonId);
      if (lesson == null) {
        return Left(CacheFailure('Lesson not found'));
      }
      return Right(lesson.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get lesson: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StudentEntity>>> getTeacherStudents(
    String teacherId,
  ) async {
    try {
      final students = await _dataSource.getTeacherStudents(teacherId);
      return Right(students.map((student) => student.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get teacher students: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StudentEntity>>> getCourseStudents(
    String courseId,
  ) async {
    try {
      final students = await _dataSource.getCourseStudents(courseId);
      return Right(students.map((student) => student.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get course students: $e'));
    }
  }

  @override
  Future<Either<Failure, StudentEntity>> getStudentById(
    String studentId,
  ) async {
    try {
      final student = await _dataSource.getStudent(studentId);
      if (student == null) {
        return Left(CacheFailure('Student not found'));
      }
      return Right(student.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get student: $e'));
    }
  }

  @override
  Future<Either<Failure, StudentProgress>> getStudentProgress(
    String studentId,
    String courseId,
  ) async {
    try {
      final progress = await _dataSource.getStudentProgress(
        studentId,
        courseId,
      );
      if (progress == null) {
        return Left(CacheFailure('Student progress not found'));
      }
      return Right(progress.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get student progress: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AssignmentEntity>>> getCourseAssignments(
    String courseId,
  ) async {
    try {
      final assignments = await _dataSource.getCourseAssignments(courseId);
      return Right(
        assignments.map((assignment) => assignment.toEntity()).toList(),
      );
    } catch (e) {
      return Left(CacheFailure('Failed to get course assignments: $e'));
    }
  }

  @override
  Future<Either<Failure, AssignmentEntity>> createAssignment(
    AssignmentEntity assignment,
  ) async {
    try {
      final assignmentModel = AssignmentModel.fromEntity(assignment);
      await _dataSource.saveAssignment(assignmentModel);
      return Right(assignment);
    } catch (e) {
      return Left(CacheFailure('Failed to create assignment: $e'));
    }
  }

  @override
  Future<Either<Failure, AssignmentEntity>> updateAssignment(
    AssignmentEntity assignment,
  ) async {
    try {
      final assignmentModel = AssignmentModel.fromEntity(assignment);
      await _dataSource.saveAssignment(assignmentModel);
      return Right(assignment);
    } catch (e) {
      return Left(CacheFailure('Failed to update assignment: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAssignment(String assignmentId) async {
    try {
      await _dataSource.deleteAssignment(assignmentId);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to delete assignment: $e'));
    }
  }

  @override
  Future<Either<Failure, AssignmentEntity>> getAssignmentById(
    String assignmentId,
  ) async {
    try {
      final assignment = await _dataSource.getAssignment(assignmentId);
      if (assignment == null) {
        return Left(CacheFailure('Assignment not found'));
      }
      return Right(assignment.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get assignment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SubmissionEntity>>> getAssignmentSubmissions(
    String assignmentId,
  ) async {
    try {
      final submissions = await _dataSource.getAssignmentSubmissions(
        assignmentId,
      );
      return Right(
        submissions.map((submission) => submission.toEntity()).toList(),
      );
    } catch (e) {
      return Left(CacheFailure('Failed to get assignment submissions: $e'));
    }
  }

  @override
  Future<Either<Failure, SubmissionEntity>> getSubmissionById(
    String submissionId,
  ) async {
    try {
      final submission = await _dataSource.getSubmission(submissionId);
      if (submission == null) {
        return Left(CacheFailure('Submission not found'));
      }
      return Right(submission.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get submission: $e'));
    }
  }

  @override
  Future<Either<Failure, SubmissionEntity>> gradeSubmission(
    String submissionId,
    int score,
    String? feedback,
  ) async {
    try {
      await _dataSource.updateSubmissionGrade(submissionId, score, feedback);
      final submission = await _dataSource.getSubmission(submissionId);
      if (submission == null) {
        return Left(CacheFailure('Submission not found after grading'));
      }
      return Right(submission.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to grade submission: $e'));
    }
  }

  @override
  Future<Either<Failure, List<GradeEntity>>> getStudentGrades(
    String studentId,
    String? courseId,
  ) async {
    try {
      final grades = await _dataSource.getStudentGrades(studentId, courseId);
      return Right(grades.map((grade) => grade.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get student grades: $e'));
    }
  }

  @override
  Future<Either<Failure, List<GradeEntity>>> getCourseGrades(
    String courseId,
  ) async {
    try {
      final grades = await _dataSource.getCourseGrades(courseId);
      return Right(grades.map((grade) => grade.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get course grades: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveGrade(GradeEntity grade) async {
    try {
      final gradeModel = GradeModel.fromEntity(grade);
      await _dataSource.saveGrade(gradeModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save grade: $e'));
    }
  }

  @override
  Future<Either<Failure, TeacherAnalyticsEntity>> getTeacherAnalytics(
    String teacherId,
  ) async {
    try {
      final analytics = await _dataSource.getTeacherAnalytics(teacherId);
      if (analytics == null) {
        return Left(CacheFailure('Teacher analytics not found'));
      }
      return Right(analytics.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get teacher analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveTeacherAnalytics(
    TeacherAnalyticsEntity analytics,
  ) async {
    try {
      final analyticsModel = TeacherAnalyticsModel.fromEntity(analytics);
      await _dataSource.saveTeacherAnalytics(analyticsModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save teacher analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTeacherMessages(
    String teacherId,
  ) async {
    try {
      final messages = await _dataSource.getTeacherMessages(teacherId);
      return Right(messages);
    } catch (e) {
      return Left(CacheFailure('Failed to get teacher messages: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getMessagesWithStudent(
    String teacherId,
    String studentId,
  ) async {
    try {
      final messages = await _dataSource.getMessagesWithStudent(
        teacherId,
        studentId,
      );
      return Right(messages);
    } catch (e) {
      return Left(CacheFailure('Failed to get messages with student: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage(
    Map<String, dynamic> message,
  ) async {
    try {
      await _dataSource.saveMessage(message);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to send message: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCourseAnnouncements(
    String courseId,
  ) async {
    try {
      final announcements = await _dataSource.getCourseAnnouncements(courseId);
      return Right(announcements);
    } catch (e) {
      return Left(CacheFailure('Failed to get course announcements: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> createAnnouncement(
    String courseId,
    String title,
    String content,
  ) async {
    try {
      final announcement = {
        'courseId': courseId,
        'title': title,
        'content': content,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await _dataSource.saveAnnouncement(announcement);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to create announcement: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTeacherNotifications(
    String teacherId,
  ) async {
    try {
      final notifications = await _dataSource.getTeacherNotifications(
        teacherId,
      );
      return Right(notifications);
    } catch (e) {
      return Left(CacheFailure('Failed to get teacher notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendNotification(
    Map<String, dynamic> notification,
  ) async {
    try {
      await _dataSource.saveNotification(notification);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to send notification: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTeacherSettings(
    String teacherId,
  ) async {
    try {
      final settings = await _dataSource.getTeacherSettings(teacherId);
      if (settings == null) {
        return Left(CacheFailure('Teacher settings not found'));
      }
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure('Failed to get teacher settings: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateTeacherSettings(
    String teacherId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _dataSource.saveTeacherSettings(teacherId, settings);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to update teacher settings: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTeacherCalendar(
    String teacherId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final calendar = await _dataSource.getTeacherCalendar(
        teacherId,
        startDate,
        endDate,
      );
      return Right(calendar);
    } catch (e) {
      return Left(CacheFailure('Failed to get teacher calendar: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> createCalendarEvent(
    String teacherId,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
    String? location,
  ) async {
    try {
      final event = {
        'teacherId': teacherId,
        'title': title,
        'description': description,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'location': location,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await _dataSource.saveCalendarEvent(event);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to create calendar event: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTeacherReports(
    String teacherId,
    String reportType,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final reports = await _dataSource.getTeacherReports(
        teacherId,
        reportType,
        startDate,
        endDate,
      );
      return Right(reports);
    } catch (e) {
      return Left(CacheFailure('Failed to get teacher reports: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateReport(
    String teacherId,
    String reportType,
    Map<String, dynamic> data,
  ) async {
    try {
      final report = {
        'teacherId': teacherId,
        'reportType': reportType,
        'data': data,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await _dataSource.saveReport(report);
      return Right(report);
    } catch (e) {
      return Left(CacheFailure('Failed to generate report: $e'));
    }
  }
}
