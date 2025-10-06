import 'package:sqflite/sqflite.dart';

/// Database migration for adding learner progress and level tracking
class DatabaseMigrationV3 {
  /// Migrate database from version 2 to version 3
  static Future<void> migrateToV3(Database db) async {
    // Create user_levels table
    await db.execute('''
      CREATE TABLE user_levels (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        language_code TEXT NOT NULL,
        current_level TEXT NOT NULL,
        current_points INTEGER DEFAULT 0,
        points_to_next_level INTEGER NOT NULL,
        completion_percentage REAL DEFAULT 0.0,
        level_achieved_at TEXT NOT NULL,
        last_assessment_date TEXT,
        completed_lessons TEXT,
        unlocked_courses TEXT,
        skill_scores TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id, language_code)
      )
    ''');

    // Create learning_progress table
    await db.execute('''
      CREATE TABLE learning_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        language_code TEXT NOT NULL,
        total_lessons_completed INTEGER DEFAULT 0,
        total_courses_completed INTEGER DEFAULT 0,
        total_points INTEGER DEFAULT 0,
        total_time_spent_minutes INTEGER DEFAULT 0,
        current_level TEXT NOT NULL,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        last_study_date TEXT,
        study_dates TEXT,
        recently_completed_lessons TEXT,
        in_progress_lessons TEXT,
        recommended_lessons TEXT,
        unlocked_achievements TEXT,
        average_quiz_score REAL DEFAULT 0.0,
        total_quizzes_taken INTEGER DEFAULT 0,
        total_correct_answers INTEGER DEFAULT 0,
        total_answers INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_synced_at TEXT,
        UNIQUE(user_id, language_code)
      )
    ''');

    // Create lesson_progress table (detailed per-lesson tracking)
    await db.execute('''
      CREATE TABLE lesson_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        lesson_id TEXT NOT NULL,
        course_id TEXT NOT NULL,
        status TEXT NOT NULL,
        current_position INTEGER DEFAULT 0,
        total_duration INTEGER DEFAULT 0,
        completed_exercises TEXT,
        quiz_score INTEGER DEFAULT 0,
        time_spent_seconds INTEGER DEFAULT 0,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        last_accessed_at TEXT NOT NULL,
        attempts INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id, lesson_id)
      )
    ''');

    // Create milestones table
    await db.execute('''
      CREATE TABLE milestones (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        target_value INTEGER NOT NULL,
        current_value INTEGER DEFAULT 0,
        completed_at TEXT,
        reward_description TEXT,
        reward_points INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create skill_progress table
    await db.execute('''
      CREATE TABLE skill_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        language_code TEXT NOT NULL,
        skill_name TEXT NOT NULL,
        proficiency REAL DEFAULT 0.0,
        lessons_completed INTEGER DEFAULT 0,
        exercises_completed INTEGER DEFAULT 0,
        last_practiced TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id, language_code, skill_name)
      )
    ''');

    // Create indexes for better query performance
    await db.execute(
        'CREATE INDEX idx_user_levels_user ON user_levels(user_id)');
    await db.execute(
        'CREATE INDEX idx_user_levels_language ON user_levels(user_id, language_code)');

    await db.execute(
        'CREATE INDEX idx_learning_progress_user ON learning_progress(user_id)');
    await db.execute(
        'CREATE INDEX idx_learning_progress_language ON learning_progress(user_id, language_code)');

    await db.execute(
        'CREATE INDEX idx_lesson_progress_user ON lesson_progress(user_id)');
    await db.execute(
        'CREATE INDEX idx_lesson_progress_lesson ON lesson_progress(lesson_id)');
    await db.execute(
        'CREATE INDEX idx_lesson_progress_status ON lesson_progress(user_id, status)');

    await db.execute('CREATE INDEX idx_milestones_user ON milestones(user_id)');
    await db.execute(
        'CREATE INDEX idx_milestones_completed ON milestones(user_id, completed_at)');

    await db.execute(
        'CREATE INDEX idx_skill_progress_user ON skill_progress(user_id, language_code)');
    // Create quiz_attempts table
    await db.execute('''
      CREATE TABLE quiz_attempts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        quiz_id TEXT NOT NULL,
        answers TEXT NOT NULL,
        total_score INTEGER NOT NULL,
        max_score INTEGER NOT NULL,
        percentage REAL NOT NULL,
        passed INTEGER NOT NULL,
        time_spent_seconds INTEGER NOT NULL,
        started_at INTEGER NOT NULL,
        completed_at INTEGER NOT NULL,
        metadata TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');

    // Create indexes for quiz attempts
    await db.execute(
        'CREATE INDEX idx_quiz_attempts_user ON quiz_attempts(user_id)');
    await db.execute(
        'CREATE INDEX idx_quiz_attempts_quiz ON quiz_attempts(quiz_id)');
    await db.execute(
        'CREATE INDEX idx_quiz_attempts_passed ON quiz_attempts(passed)');
    await db.execute(
        'CREATE INDEX idx_quiz_attempts_completed ON quiz_attempts(completed_at)');

    print('✅ Database migrated to version 3 successfully');
  }

  /// Create initial tables if creating database from scratch at v3
  static Future<void> createTablesV3(Database db) async {
    // This will be called if someone installs the app fresh at v3
    // All existing tables + new tables
    await migrateToV3(db);
  }
}
