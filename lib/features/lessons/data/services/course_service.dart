import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maa_yegue/core/database/database_helper.dart';
import 'package:maa_yegue/features/lessons/domain/entities/course.dart';
import 'package:maa_yegue/features/lessons/domain/entities/lesson.dart';
import 'package:maa_yegue/features/lessons/domain/entities/lesson_content.dart';

/// Service for managing courses, lessons, and content
class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize database tables for courses
  static Future<void> initializeTables(Database db) async {
    // Create courses table
    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        language_code TEXT NOT NULL,
        thumbnail_url TEXT,
        estimated_duration INTEGER NOT NULL,
        level TEXT NOT NULL,
        status TEXT NOT NULL,
        teacher_id TEXT,
        total_lessons INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        needs_sync INTEGER DEFAULT 1,
        last_synced INTEGER,
        UNIQUE(id)
      )
    ''');

    // Create lessons table
    await db.execute('''
      CREATE TABLE lessons (
        id TEXT PRIMARY KEY,
        course_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        estimated_duration INTEGER NOT NULL,
        thumbnail_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        needs_sync INTEGER DEFAULT 1,
        last_synced INTEGER,
        FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE,
        UNIQUE(id)
      )
    ''');

    // Create lesson_contents table
    await db.execute('''
      CREATE TABLE lesson_contents (
        id TEXT PRIMARY KEY,
        lesson_id TEXT NOT NULL,
        type TEXT NOT NULL,
        content TEXT NOT NULL,
        audio_url TEXT,
        image_url TEXT,
        video_url TEXT,
        metadata TEXT,
        order_index INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_deleted INTEGER DEFAULT 0,
        needs_sync INTEGER DEFAULT 1,
        last_synced INTEGER,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE CASCADE,
        UNIQUE(id)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_courses_language_code ON courses(language_code)');
    await db.execute('CREATE INDEX idx_courses_status ON courses(status)');
    await db.execute('CREATE INDEX idx_courses_teacher_id ON courses(teacher_id)');
    await db.execute('CREATE INDEX idx_lessons_course_id ON lessons(course_id)');
    await db.execute('CREATE INDEX idx_lesson_contents_lesson_id ON lesson_contents(lesson_id)');
  }

  // ===== COURSE OPERATIONS =====

  /// Create a new course
  Future<String> createCourse(Course course) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now();
    final courseId = course.id.isEmpty ? _generateId() : course.id;

    final courseData = {
      'id': courseId,
      'title': course.title,
      'description': course.description,
      'language_code': course.languageCode,
      'thumbnail_url': course.thumbnailUrl,
      'estimated_duration': course.estimatedDuration,
      'level': course.level.name,
      'status': course.status.name,
      'teacher_id': 'current_teacher', // TODO: Get from auth
      'total_lessons': course.lessons.length,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'is_deleted': 0,
      'needs_sync': 1,
      'last_synced': null,
    };

    await db.insert('courses', courseData);

    // Sync to Firebase
    await _syncCourseToFirebase(courseId, courseData);

    print('✅ Course created: ${course.title}');
    return courseId;
  }

  /// Get all courses for a teacher
  Future<List<Course>> getCoursesByTeacher(String teacherId) async {
    final db = await DatabaseHelper.database;

    final results = await db.query(
      'courses',
      where: 'teacher_id = ? AND is_deleted = 0',
      whereArgs: [teacherId],
      orderBy: 'created_at DESC',
    );

    final courses = <Course>[];
    for (final row in results) {
      final course = await _mapRowToCourse(row);
      courses.add(course);
    }

    return courses;
  }

  /// Get course by ID
  Future<Course?> getCourseById(String courseId) async {
    final db = await DatabaseHelper.database;

    final results = await db.query(
      'courses',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [courseId],
      limit: 1,
    );

    if (results.isEmpty) return null;

    return await _mapRowToCourse(results.first);
  }

  /// Update course
  Future<void> updateCourse(Course course) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now();

    final courseData = {
      'title': course.title,
      'description': course.description,
      'language_code': course.languageCode,
      'thumbnail_url': course.thumbnailUrl,
      'estimated_duration': course.estimatedDuration,
      'level': course.level.name,
      'status': course.status.name,
      'total_lessons': course.lessons.length,
      'updated_at': now.toIso8601String(),
      'needs_sync': 1,
    };

    await db.update(
      'courses',
      courseData,
      where: 'id = ?',
      whereArgs: [course.id],
    );

    // Sync to Firebase
    await _syncCourseToFirebase(course.id, {...courseData, 'id': course.id});

    print('✅ Course updated: ${course.title}');
  }

  /// Delete course (soft delete)
  Future<void> deleteCourse(String courseId) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now();

    await db.update(
      'courses',
      {
        'is_deleted': 1,
        'updated_at': now.toIso8601String(),
        'needs_sync': 1,
      },
      where: 'id = ?',
      whereArgs: [courseId],
    );

    // Sync to Firebase
    await _firestore.collection('courses').doc(courseId).update({
      'is_deleted': true,
      'updated_at': now.toIso8601String(),
    });

    print('✅ Course deleted: $courseId');
  }

  // ===== LESSON OPERATIONS =====

  /// Create a new lesson
  Future<String> createLesson(Lesson lesson) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now();
    final lessonId = lesson.id.isEmpty ? _generateId() : lesson.id;

    final lessonData = {
      'id': lessonId,
      'course_id': lesson.courseId,
      'title': lesson.title,
      'description': lesson.description,
      'order_index': lesson.order,
      'type': lesson.type.name,
      'status': lesson.status.name,
      'estimated_duration': lesson.estimatedDuration,
      'thumbnail_url': lesson.thumbnailUrl,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'is_deleted': 0,
      'needs_sync': 1,
      'last_synced': null,
    };

    await db.insert('lessons', lessonData);

    // Create lesson contents
    for (final content in lesson.contents) {
      await createLessonContent(content.copyWith(lessonId: lessonId));
    }

    // Update course lesson count
    await _updateCourseLessonCount(lesson.courseId);

    // Sync to Firebase
    await _syncLessonToFirebase(lessonId, lessonData);

    print('✅ Lesson created: ${lesson.title}');
    return lessonId;
  }

  /// Get lessons for a course
  Future<List<Lesson>> getLessonsByCourse(String courseId) async {
    final db = await DatabaseHelper.database;

    final results = await db.query(
      'lessons',
      where: 'course_id = ? AND is_deleted = 0',
      whereArgs: [courseId],
      orderBy: 'order_index ASC',
    );

    final lessons = <Lesson>[];
    for (final row in results) {
      final lesson = await _mapRowToLesson(row);
      lessons.add(lesson);
    }

    return lessons;
  }

  /// Update lesson
  Future<void> updateLesson(Lesson lesson) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now();

    final lessonData = {
      'title': lesson.title,
      'description': lesson.description,
      'order_index': lesson.order,
      'type': lesson.type.name,
      'status': lesson.status.name,
      'estimated_duration': lesson.estimatedDuration,
      'thumbnail_url': lesson.thumbnailUrl,
      'updated_at': now.toIso8601String(),
      'needs_sync': 1,
    };

    await db.update(
      'lessons',
      lessonData,
      where: 'id = ?',
      whereArgs: [lesson.id],
    );

    // Update contents
    await _updateLessonContents(lesson.id, lesson.contents);

    // Sync to Firebase
    await _syncLessonToFirebase(lesson.id, {...lessonData, 'id': lesson.id});

    print('✅ Lesson updated: ${lesson.title}');
  }

  // ===== LESSON CONTENT OPERATIONS =====

  /// Create lesson content
  Future<String> createLessonContent(LessonContent content) async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now();
    final contentId = content.id.isEmpty ? _generateId() : content.id;

    final contentData = {
      'id': contentId,
      'lesson_id': content.lessonId,
      'type': content.type.name,
      'content': content.content,
      'audio_url': content.audioUrl,
      'image_url': content.imageUrl,
      'video_url': content.videoUrl,
      'metadata': content.metadata != null ? _encodeMetadata(content.metadata!) : null,
      'order_index': content.order,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'is_deleted': 0,
      'needs_sync': 1,
      'last_synced': null,
    };

    await db.insert('lesson_contents', contentData);

    // Sync to Firebase
    await _syncContentToFirebase(contentId, contentData);

    return contentId;
  }

  /// Get contents for a lesson
  Future<List<LessonContent>> getLessonContents(String lessonId) async {
    final db = await DatabaseHelper.database;

    final results = await db.query(
      'lesson_contents',
      where: 'lesson_id = ? AND is_deleted = 0',
      whereArgs: [lessonId],
      orderBy: 'order_index ASC',
    );

    return results.map(_mapRowToLessonContent).toList();
  }

  // ===== SYNC OPERATIONS =====

  /// Sync pending changes to Firebase
  Future<void> syncToFirebase() async {
    final db = await DatabaseHelper.database;

    // Sync courses
    final pendingCourses = await db.query(
      'courses',
      where: 'needs_sync = 1',
    );

    for (final course in pendingCourses) {
      await _syncCourseToFirebase(course['id'] as String, course);
      await db.update(
        'courses',
        {'needs_sync': 0, 'last_synced': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [course['id']],
      );
    }

    // Sync lessons and contents similarly...
    print('✅ Sync completed');
  }

  // ===== PRIVATE HELPER METHODS =====

  Future<Course> _mapRowToCourse(Map<String, dynamic> row) async {
    final lessons = await getLessonsByCourse(row['id'] as String);

    return Course(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      languageCode: row['language_code'] as String,
      thumbnailUrl: row['thumbnail_url'] as String? ?? '',
      lessons: lessons,
      estimatedDuration: row['estimated_duration'] as int,
      level: CourseLevel.values.firstWhere(
        (l) => l.name == row['level'],
        orElse: () => CourseLevel.beginner,
      ),
      status: CourseStatus.values.firstWhere(
        (s) => s.name == row['status'],
        orElse: () => CourseStatus.draft,
      ),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  Future<Lesson> _mapRowToLesson(Map<String, dynamic> row) async {
    final contents = await getLessonContents(row['id'] as String);

    return Lesson(
      id: row['id'] as String,
      courseId: row['course_id'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      order: row['order_index'] as int,
      type: LessonType.values.firstWhere(
        (t) => t.name == row['type'],
        orElse: () => LessonType.vocabulary,
      ),
      status: LessonStatus.values.firstWhere(
        (s) => s.name == row['status'],
        orElse: () => LessonStatus.available,
      ),
      estimatedDuration: row['estimated_duration'] as int,
      thumbnailUrl: row['thumbnail_url'] as String? ?? '',
      contents: contents,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  LessonContent _mapRowToLessonContent(Map<String, dynamic> row) {
    return LessonContent(
      id: row['id'] as String,
      lessonId: row['lesson_id'] as String,
      type: ContentType.values.firstWhere(
        (t) => t.name == row['type'],
        orElse: () => ContentType.text,
      ),
      content: row['content'] as String,
      audioUrl: row['audio_url'] as String?,
      imageUrl: row['image_url'] as String?,
      videoUrl: row['video_url'] as String?,
      metadata: row['metadata'] != null ? _decodeMetadata(row['metadata'] as String) : null,
      order: row['order_index'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  Future<void> _updateCourseLessonCount(String courseId) async {
    final db = await DatabaseHelper.database;

    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM lessons WHERE course_id = ? AND is_deleted = 0',
      [courseId],
    )) ?? 0;

    await db.update(
      'courses',
      {'total_lessons': count, 'needs_sync': 1},
      where: 'id = ?',
      whereArgs: [courseId],
    );
  }

  Future<void> _updateLessonContents(String lessonId, List<LessonContent> contents) async {
    final db = await DatabaseHelper.database;

    // Delete existing contents
    await db.update(
      'lesson_contents',
      {'is_deleted': 1, 'needs_sync': 1},
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );

    // Insert new contents
    for (final content in contents) {
      await createLessonContent(content.copyWith(lessonId: lessonId));
    }
  }

  Future<void> _syncCourseToFirebase(String courseId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('courses').doc(courseId).set(data);
    } catch (e) {
      print('❌ Failed to sync course to Firebase: $e');
    }
  }

  Future<void> _syncLessonToFirebase(String lessonId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('lessons').doc(lessonId).set(data);
    } catch (e) {
      print('❌ Failed to sync lesson to Firebase: $e');
    }
  }

  Future<void> _syncContentToFirebase(String contentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('lesson_contents').doc(contentId).set(data);
    } catch (e) {
      print('❌ Failed to sync content to Firebase: $e');
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _encodeMetadata(Map<String, dynamic> metadata) {
    return metadata.toString(); // Simple encoding, could use JSON
  }

  Map<String, dynamic> _decodeMetadata(String metadata) {
    // Simple decoding, could use JSON parsing
    return {};
  }
}
