import 'package:sqflite/sqflite.dart';
import '../../domain/entities/teacher_entity.dart';
import '../models/teacher_model.dart';
import '../../../../core/errors/failures.dart';

/// Abstract data source for teacher data
abstract class TeacherDataSource {
  /// Get teacher profile from local database
  Future<TeacherModel?> getTeacherProfile(String teacherId);

  /// Save teacher profile to local database
  Future<void> saveTeacherProfile(TeacherModel teacher);

  /// Get teacher courses from local database
  Future<List<CourseModel>> getTeacherCourses(String teacherId);

  /// Get specific course from local database
  Future<CourseModel?> getCourse(String courseId);

  /// Save course to local database
  Future<void> saveCourse(CourseModel course);

  /// Delete course from local database
  Future<void> deleteCourse(String courseId);

  /// Update course status in local database
  Future<void> updateCourseStatus(String courseId, CourseStatus status);

  /// Get course lessons from local database
  Future<List<LessonModel>> getCourseLessons(String courseId);

  /// Get specific lesson from local database
  Future<LessonModel?> getLesson(String lessonId);

  /// Save lesson to local database
  Future<void> saveLesson(LessonModel lesson);

  /// Delete lesson from local database
  Future<void> deleteLesson(String lessonId);

  /// Update lesson status in local database
  Future<void> updateLessonStatus(String lessonId, bool isPublished);

  /// Get teacher students from local database
  Future<List<StudentModel>> getTeacherStudents(String teacherId);

  /// Get course students from local database
  Future<List<StudentModel>> getCourseStudents(String courseId);

  /// Get specific student from local database
  Future<StudentModel?> getStudent(String studentId);

  /// Get student progress from local database
  Future<StudentProgressModel?> getStudentProgress(
    String studentId,
    String courseId,
  );

  /// Get course assignments from local database
  Future<List<AssignmentModel>> getCourseAssignments(String courseId);

  /// Get specific assignment from local database
  Future<AssignmentModel?> getAssignment(String assignmentId);

  /// Save assignment to local database
  Future<void> saveAssignment(AssignmentModel assignment);

  /// Delete assignment from local database
  Future<void> deleteAssignment(String assignmentId);

  /// Update assignment status in local database
  Future<void> updateAssignmentStatus(String assignmentId, bool isPublished);

  /// Get assignment submissions from local database
  Future<List<SubmissionModel>> getAssignmentSubmissions(String assignmentId);

  /// Get specific submission from local database
  Future<SubmissionModel?> getSubmission(String submissionId);

  /// Save submission to local database
  Future<void> saveSubmission(SubmissionModel submission);

  /// Update submission grade in local database
  Future<void> updateSubmissionGrade(
    String submissionId,
    int score,
    String? feedback,
  );

  /// Get student grades from local database
  Future<List<GradeModel>> getStudentGrades(String studentId, String? courseId);

  /// Get course grades from local database
  Future<List<GradeModel>> getCourseGrades(String courseId);

  /// Save grade to local database
  Future<void> saveGrade(GradeModel grade);

  /// Get teacher analytics from local database
  Future<TeacherAnalyticsModel?> getTeacherAnalytics(String teacherId);

  /// Save teacher analytics to local database
  Future<void> saveTeacherAnalytics(TeacherAnalyticsModel analytics);

  /// Get teacher messages from local database
  Future<List<Map<String, dynamic>>> getTeacherMessages(String teacherId);

  /// Get messages with student from local database
  Future<List<Map<String, dynamic>>> getMessagesWithStudent(
    String teacherId,
    String studentId,
  );

  /// Save message to local database
  Future<void> saveMessage(Map<String, dynamic> message);

  /// Get course announcements from local database
  Future<List<Map<String, dynamic>>> getCourseAnnouncements(String courseId);

  /// Save announcement to local database
  Future<void> saveAnnouncement(Map<String, dynamic> announcement);

  /// Get teacher notifications from local database
  Future<List<Map<String, dynamic>>> getTeacherNotifications(String teacherId);

  /// Save notification to local database
  Future<void> saveNotification(Map<String, dynamic> notification);

  /// Get teacher settings from local database
  Future<Map<String, dynamic>?> getTeacherSettings(String teacherId);

  /// Save teacher settings to local database
  Future<void> saveTeacherSettings(
    String teacherId,
    Map<String, dynamic> settings,
  );

  /// Get teacher calendar events from local database
  Future<List<Map<String, dynamic>>> getTeacherCalendar(
    String teacherId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Save calendar event to local database
  Future<void> saveCalendarEvent(Map<String, dynamic> event);

  /// Get teacher reports from local database
  Future<List<Map<String, dynamic>>> getTeacherReports(
    String teacherId,
    String reportType,
    DateTime startDate,
    DateTime endDate,
  );

  /// Save report to local database
  Future<void> saveReport(Map<String, dynamic> report);
}

/// Local teacher data source implementation
class TeacherDataSourceImpl implements TeacherDataSource {
  final Database _database;

  TeacherDataSourceImpl(this._database);

  @override
  Future<TeacherModel?> getTeacherProfile(String teacherId) async {
    try {
      final result = await _database.query(
        'teachers',
        where: 'id = ?',
        whereArgs: [teacherId],
        limit: 1,
      );

      if (result.isEmpty) return null;

      return TeacherModel.fromJson(result.first);
    } catch (e) {
      throw CacheFailure('Failed to get teacher profile: $e');
    }
  }

  @override
  Future<void> saveTeacherProfile(TeacherModel teacher) async {
    try {
      await _database.insert(
        'teachers',
        teacher.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save teacher profile: $e');
    }
  }

  @override
  Future<List<CourseModel>> getTeacherCourses(String teacherId) async {
    try {
      final result = await _database.query(
        'courses',
        where: 'teacherId = ?',
        whereArgs: [teacherId],
        orderBy: 'createdAt DESC',
      );

      return result.map((course) => CourseModel.fromJson(course)).toList();
    } catch (e) {
      throw CacheFailure('Failed to get teacher courses: $e');
    }
  }

  @override
  Future<CourseModel?> getCourse(String courseId) async {
    try {
      final result = await _database.query(
        'courses',
        where: 'id = ?',
        whereArgs: [courseId],
        limit: 1,
      );

      if (result.isEmpty) return null;

      return CourseModel.fromJson(result.first);
    } catch (e) {
      throw CacheFailure('Failed to get course: $e');
    }
  }

  @override
  Future<void> saveCourse(CourseModel course) async {
    try {
      await _database.insert(
        'courses',
        course.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save course: $e');
    }
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    try {
      await _database.delete('courses', where: 'id = ?', whereArgs: [courseId]);
    } catch (e) {
      throw CacheFailure('Failed to delete course: $e');
    }
  }

  @override
  Future<void> updateCourseStatus(String courseId, CourseStatus status) async {
    try {
      await _database.update(
        'courses',
        {'status': status.name, 'updatedAt': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [courseId],
      );
    } catch (e) {
      throw CacheFailure('Failed to update course status: $e');
    }
  }

  @override
  Future<List<LessonModel>> getCourseLessons(String courseId) async {
    try {
      final result = await _database.query(
        'lessons',
        where: 'courseId = ?',
        whereArgs: [courseId],
        orderBy: 'order ASC',
      );

      return result.map((lesson) => LessonModel.fromJson(lesson)).toList();
    } catch (e) {
      throw CacheFailure('Failed to get course lessons: $e');
    }
  }

  @override
  Future<LessonModel?> getLesson(String lessonId) async {
    try {
      final result = await _database.query(
        'lessons',
        where: 'id = ?',
        whereArgs: [lessonId],
        limit: 1,
      );

      if (result.isEmpty) return null;

      return LessonModel.fromJson(result.first);
    } catch (e) {
      throw CacheFailure('Failed to get lesson: $e');
    }
  }

  @override
  Future<void> saveLesson(LessonModel lesson) async {
    try {
      await _database.insert(
        'lessons',
        lesson.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save lesson: $e');
    }
  }

  @override
  Future<void> deleteLesson(String lessonId) async {
    try {
      await _database.delete('lessons', where: 'id = ?', whereArgs: [lessonId]);
    } catch (e) {
      throw CacheFailure('Failed to delete lesson: $e');
    }
  }

  @override
  Future<void> updateLessonStatus(String lessonId, bool isPublished) async {
    try {
      await _database.update(
        'lessons',
        {
          'isPublished': isPublished,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [lessonId],
      );
    } catch (e) {
      throw CacheFailure('Failed to update lesson status: $e');
    }
  }

  @override
  Future<List<StudentModel>> getTeacherStudents(String teacherId) async {
    try {
      final result = await _database.query(
        'students',
        where: 'teacherId = ?',
        whereArgs: [teacherId],
        orderBy: 'joinedAt DESC',
      );

      return result.map((student) => StudentModel.fromJson(student)).toList();
    } catch (e) {
      throw CacheFailure('Failed to get teacher students: $e');
    }
  }

  @override
  Future<List<StudentModel>> getCourseStudents(String courseId) async {
    try {
      final result = await _database.query(
        'course_enrollments',
        columns: ['studentId'],
        where: 'courseId = ?',
        whereArgs: [courseId],
      );

      if (result.isEmpty) return [];

      final studentIds = result.map((e) => e['studentId'] as String).toList();

      final students = await _database.query(
        'students',
        where: 'id IN (${studentIds.map((_) => '?').join(',')})',
        whereArgs: studentIds,
        orderBy: 'joinedAt DESC',
      );

      return students.map((student) => StudentModel.fromJson(student)).toList();
    } catch (e) {
      throw CacheFailure('Failed to get course students: $e');
    }
  }

  @override
  Future<StudentModel?> getStudent(String studentId) async {
    try {
      final result = await _database.query(
        'students',
        where: 'id = ?',
        whereArgs: [studentId],
        limit: 1,
      );

      if (result.isEmpty) return null;

      return StudentModel.fromJson(result.first);
    } catch (e) {
      throw CacheFailure('Failed to get student: $e');
    }
  }

  @override
  Future<StudentProgressModel?> getStudentProgress(
    String studentId,
    String courseId,
  ) async {
    try {
      final result = await _database.query(
        'student_progress',
        where: 'studentId = ? AND courseId = ?',
        whereArgs: [studentId, courseId],
        limit: 1,
      );

      if (result.isEmpty) return null;

      return StudentProgressModel.fromJson(result.first);
    } catch (e) {
      throw CacheFailure('Failed to get student progress: $e');
    }
  }

  @override
  Future<List<AssignmentModel>> getCourseAssignments(String courseId) async {
    try {
      final result = await _database.query(
        'assignments',
        where: 'courseId = ?',
        whereArgs: [courseId],
        orderBy: 'createdAt DESC',
      );

      return result
          .map((assignment) => AssignmentModel.fromJson(assignment))
          .toList();
    } catch (e) {
      throw CacheFailure('Failed to get course assignments: $e');
    }
  }

  @override
  Future<AssignmentModel?> getAssignment(String assignmentId) async {
    try {
      final result = await _database.query(
        'assignments',
        where: 'id = ?',
        whereArgs: [assignmentId],
        limit: 1,
      );

      if (result.isEmpty) return null;

      return AssignmentModel.fromJson(result.first);
    } catch (e) {
      throw CacheFailure('Failed to get assignment: $e');
    }
  }

  @override
  Future<void> saveAssignment(AssignmentModel assignment) async {
    try {
      await _database.insert(
        'assignments',
        assignment.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save assignment: $e');
    }
  }

  @override
  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _database.delete(
        'assignments',
        where: 'id = ?',
        whereArgs: [assignmentId],
      );
    } catch (e) {
      throw CacheFailure('Failed to delete assignment: $e');
    }
  }

  @override
  Future<void> updateAssignmentStatus(
    String assignmentId,
    bool isPublished,
  ) async {
    try {
      await _database.update(
        'assignments',
        {
          'isPublished': isPublished,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [assignmentId],
      );
    } catch (e) {
      throw CacheFailure('Failed to update assignment status: $e');
    }
  }

  @override
  Future<List<SubmissionModel>> getAssignmentSubmissions(
    String assignmentId,
  ) async {
    try {
      final result = await _database.query(
        'submissions',
        where: 'assignmentId = ?',
        whereArgs: [assignmentId],
        orderBy: 'submittedAt DESC',
      );

      return result
          .map((submission) => SubmissionModel.fromJson(submission))
          .toList();
    } catch (e) {
      throw CacheFailure('Failed to get assignment submissions: $e');
    }
  }

  @override
  Future<SubmissionModel?> getSubmission(String submissionId) async {
    try {
      final result = await _database.query(
        'submissions',
        where: 'id = ?',
        whereArgs: [submissionId],
        limit: 1,
      );

      if (result.isEmpty) return null;

      return SubmissionModel.fromJson(result.first);
    } catch (e) {
      throw CacheFailure('Failed to get submission: $e');
    }
  }

  @override
  Future<void> saveSubmission(SubmissionModel submission) async {
    try {
      await _database.insert(
        'submissions',
        submission.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save submission: $e');
    }
  }

  @override
  Future<void> updateSubmissionGrade(
    String submissionId,
    int score,
    String? feedback,
  ) async {
    try {
      await _database.update(
        'submissions',
        {
          'score': score,
          'feedback': feedback,
          'gradedAt': DateTime.now().toIso8601String(),
          'status': SubmissionStatus.graded.name,
        },
        where: 'id = ?',
        whereArgs: [submissionId],
      );
    } catch (e) {
      throw CacheFailure('Failed to update submission grade: $e');
    }
  }

  @override
  Future<List<GradeModel>> getStudentGrades(
    String studentId,
    String? courseId,
  ) async {
    try {
      String whereClause = 'studentId = ?';
      List<dynamic> whereArgs = [studentId];

      if (courseId != null) {
        whereClause += ' AND courseId = ?';
        whereArgs.add(courseId);
      }

      final result = await _database.query(
        'grades',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'gradedAt DESC',
      );

      return result.map((grade) => GradeModel.fromJson(grade)).toList();
    } catch (e) {
      throw CacheFailure('Failed to get student grades: $e');
    }
  }

  @override
  Future<List<GradeModel>> getCourseGrades(String courseId) async {
    try {
      final result = await _database.query(
        'grades',
        where: 'courseId = ?',
        whereArgs: [courseId],
        orderBy: 'gradedAt DESC',
      );

      return result.map((grade) => GradeModel.fromJson(grade)).toList();
    } catch (e) {
      throw CacheFailure('Failed to get course grades: $e');
    }
  }

  @override
  Future<void> saveGrade(GradeModel grade) async {
    try {
      await _database.insert(
        'grades',
        grade.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save grade: $e');
    }
  }

  @override
  Future<TeacherAnalyticsModel?> getTeacherAnalytics(String teacherId) async {
    try {
      final result = await _database.query(
        'teacher_analytics',
        where: 'teacherId = ?',
        whereArgs: [teacherId],
        limit: 1,
      );

      if (result.isEmpty) return null;

      return TeacherAnalyticsModel.fromJson(result.first);
    } catch (e) {
      throw CacheFailure('Failed to get teacher analytics: $e');
    }
  }

  @override
  Future<void> saveTeacherAnalytics(TeacherAnalyticsModel analytics) async {
    try {
      await _database.insert(
        'teacher_analytics',
        analytics.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save teacher analytics: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTeacherMessages(
    String teacherId,
  ) async {
    try {
      final result = await _database.query(
        'messages',
        where:
            'teacherId = ? OR studentId IN (SELECT id FROM students WHERE teacherId = ?)',
        whereArgs: [teacherId, teacherId],
        orderBy: 'createdAt DESC',
      );

      return result;
    } catch (e) {
      throw CacheFailure('Failed to get teacher messages: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMessagesWithStudent(
    String teacherId,
    String studentId,
  ) async {
    try {
      final result = await _database.query(
        'messages',
        where:
            '(teacherId = ? AND studentId = ?) OR (teacherId = ? AND studentId = ?)',
        whereArgs: [teacherId, studentId, studentId, teacherId],
        orderBy: 'createdAt ASC',
      );

      return result;
    } catch (e) {
      throw CacheFailure('Failed to get messages with student: $e');
    }
  }

  @override
  Future<void> saveMessage(Map<String, dynamic> message) async {
    try {
      await _database.insert(
        'messages',
        message,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save message: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCourseAnnouncements(
    String courseId,
  ) async {
    try {
      final result = await _database.query(
        'announcements',
        where: 'courseId = ?',
        whereArgs: [courseId],
        orderBy: 'createdAt DESC',
      );

      return result;
    } catch (e) {
      throw CacheFailure('Failed to get course announcements: $e');
    }
  }

  @override
  Future<void> saveAnnouncement(Map<String, dynamic> announcement) async {
    try {
      await _database.insert(
        'announcements',
        announcement,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save announcement: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTeacherNotifications(
    String teacherId,
  ) async {
    try {
      final result = await _database.query(
        'notifications',
        where: 'teacherId = ?',
        whereArgs: [teacherId],
        orderBy: 'createdAt DESC',
      );

      return result;
    } catch (e) {
      throw CacheFailure('Failed to get teacher notifications: $e');
    }
  }

  @override
  Future<void> saveNotification(Map<String, dynamic> notification) async {
    try {
      await _database.insert(
        'notifications',
        notification,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save notification: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getTeacherSettings(String teacherId) async {
    try {
      final result = await _database.query(
        'teacher_settings',
        where: 'teacherId = ?',
        whereArgs: [teacherId],
        limit: 1,
      );

      if (result.isEmpty) return null;

      return result.first;
    } catch (e) {
      throw CacheFailure('Failed to get teacher settings: $e');
    }
  }

  @override
  Future<void> saveTeacherSettings(
    String teacherId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _database.insert('teacher_settings', {
        'teacherId': teacherId,
        'settings': settings.toString(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw CacheFailure('Failed to save teacher settings: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTeacherCalendar(
    String teacherId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final result = await _database.query(
        'calendar_events',
        where: 'teacherId = ? AND startTime >= ? AND endTime <= ?',
        whereArgs: [
          teacherId,
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: 'startTime ASC',
      );

      return result;
    } catch (e) {
      throw CacheFailure('Failed to get teacher calendar: $e');
    }
  }

  @override
  Future<void> saveCalendarEvent(Map<String, dynamic> event) async {
    try {
      await _database.insert(
        'calendar_events',
        event,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save calendar event: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTeacherReports(
    String teacherId,
    String reportType,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final result = await _database.query(
        'reports',
        where:
            'teacherId = ? AND reportType = ? AND createdAt >= ? AND createdAt <= ?',
        whereArgs: [
          teacherId,
          reportType,
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: 'createdAt DESC',
      );

      return result;
    } catch (e) {
      throw CacheFailure('Failed to get teacher reports: $e');
    }
  }

  @override
  Future<void> saveReport(Map<String, dynamic> report) async {
    try {
      await _database.insert(
        'reports',
        report,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheFailure('Failed to save report: $e');
    }
  }
}
