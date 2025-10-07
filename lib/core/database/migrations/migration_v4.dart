import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

/// Database migration for adding course management tables
class DatabaseMigrationV4 {
  /// Migrate database from version 3 to version 4
  static Future<void> migrateToV4(Database db) async {
    await createTablesV4(db);
  }

  /// Create version 4 tables (course management)
  static Future<void> createTablesV4(Database db) async {
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

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_courses_language_code ON courses(language_code)',
    );
    await db.execute('CREATE INDEX idx_courses_status ON courses(status)');
    await db.execute(
      'CREATE INDEX idx_courses_teacher_id ON courses(teacher_id)',
    );
    await db.execute(
      'CREATE INDEX idx_lessons_course_id ON lessons(course_id)',
    );
    await db.execute(
      'CREATE INDEX idx_lesson_contents_lesson_id ON lesson_contents(lesson_id)',
    );

    debugPrint('✅ Course management tables created (version 4)');
  }
}
