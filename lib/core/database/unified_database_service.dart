import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

/// Unified Database Service for Ma'a yegue
/// Manages all SQLite operations for the hybrid architecture
///
/// This service replaces and consolidates:
/// - database_helper.dart
/// - sqlite_database_helper.dart
/// - cameroon_languages_database_helper.dart
/// - local_database_service.dart
class UnifiedDatabaseService {
  static const String _mainDatabaseName = 'maa_yegue_app.db';
  static const String _cameroonDatabaseName = 'cameroon_languages.db';
  static const int _databaseVersion = 2;

  static UnifiedDatabaseService? _instance;
  static Database? _database;

  /// Singleton instance
  static UnifiedDatabaseService get instance {
    _instance ??= UnifiedDatabaseService._internal();
    return _instance!;
  }

  UnifiedDatabaseService._internal();

  /// Get database instance (lazy initialization)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the unified database
  Future<Database> _initDatabase() async {
    debugPrint('🔄 Initializing Unified Database Service...');

    final databasesPath = await getDatabasesPath();
    final mainDbPath = join(databasesPath, _mainDatabaseName);
    final cameroonDbPath = join(databasesPath, _cameroonDatabaseName);

    // Step 1: Copy Cameroon languages database from assets if needed
    await _copyCameroonDatabaseFromAssets(cameroonDbPath);

    // Step 2: Open/Create main database with version control
    final db = await openDatabase(
      mainDbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );

    // Step 3: Attach Cameroon database for unified queries
    await _attachCameroonDatabase(db, cameroonDbPath);

    debugPrint('✅ Unified Database initialized successfully');
    return db;
  }

  /// Copy Cameroon languages database from assets
  Future<void> _copyCameroonDatabaseFromAssets(String path) async {
    final exists = await databaseExists(path);

    if (!exists) {
      debugPrint('📦 Copying Cameroon Languages database from assets...');

      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      final data = await rootBundle.load(
        'assets/databases/$_cameroonDatabaseName',
      );
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);

      debugPrint('✅ Cameroon Languages database copied successfully');
    } else {
      debugPrint('✓ Cameroon Languages database already exists');
    }
  }

  /// Attach Cameroon database for unified access
  Future<void> _attachCameroonDatabase(
    Database db,
    String cameroonDbPath,
  ) async {
    await db.execute("ATTACH DATABASE '$cameroonDbPath' AS cameroon");
    debugPrint('✅ Cameroon database attached');
  }

  /// Create all tables on first run
  Future<void> _onCreate(Database db, int version) async {
    debugPrint('🆕 Creating database schema version $version...');

    // Users table - stores local user data synced with Firebase auth
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        user_id TEXT PRIMARY KEY,
        firebase_uid TEXT UNIQUE,
        email TEXT,
        display_name TEXT,
        role TEXT CHECK(role IN ('guest', 'student', 'teacher', 'admin')) DEFAULT 'student',
        subscription_status TEXT DEFAULT 'free',
        subscription_expires_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        last_login INTEGER,
        is_active INTEGER DEFAULT 1,
        is_default_admin INTEGER DEFAULT 0,
        auth_provider TEXT DEFAULT 'email',
        two_factor_enabled INTEGER DEFAULT 0,
        two_factor_enabled_at TEXT,
        two_factor_disabled_at TEXT,
        last_two_factor_verification TEXT,
        backup_codes TEXT,
        backup_codes_generated_at TEXT,
        promoted_to_admin_at TEXT,
        demoted_from_admin_at TEXT,
        permissions TEXT,
        profile_data TEXT,
        fcm_token TEXT,
        fcm_token_updated_at TEXT
      )
    ''');

    // Daily limits tracking for guest users
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_limits (
        limit_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        device_id TEXT,
        limit_date TEXT NOT NULL,
        lessons_count INTEGER DEFAULT 0,
        readings_count INTEGER DEFAULT 0,
        quizzes_count INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        UNIQUE(user_id, limit_date),
        UNIQUE(device_id, limit_date),
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
      )
    ''');

    // User progress tracking
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_progress (
        progress_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        content_type TEXT CHECK(content_type IN ('lesson', 'quiz', 'translation', 'reading')) NOT NULL,
        content_id INTEGER NOT NULL,
        language_id TEXT,
        status TEXT CHECK(status IN ('started', 'in_progress', 'completed')) DEFAULT 'started',
        score REAL,
        time_spent INTEGER DEFAULT 0,
        attempts INTEGER DEFAULT 0,
        completed_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
      )
    ''');

    // User statistics
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_statistics (
        stat_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL UNIQUE,
        total_lessons_completed INTEGER DEFAULT 0,
        total_quizzes_completed INTEGER DEFAULT 0,
        total_words_learned INTEGER DEFAULT 0,
        total_readings_completed INTEGER DEFAULT 0,
        total_study_time INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        last_activity_date TEXT,
        level INTEGER DEFAULT 1,
        experience_points INTEGER DEFAULT 0,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
      )
    ''');

    // Quizzes (in main DB for user-created quizzes)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS quizzes (
        quiz_id INTEGER PRIMARY KEY AUTOINCREMENT,
        language_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        difficulty_level TEXT CHECK(difficulty_level IN ('beginner', 'intermediate', 'advanced')),
        category_id TEXT,
        creator_id TEXT,
        is_official INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (creator_id) REFERENCES users(user_id) ON DELETE SET NULL
      )
    ''');

    // Quiz questions
    await db.execute('''
      CREATE TABLE IF NOT EXISTS quiz_questions (
        question_id INTEGER PRIMARY KEY AUTOINCREMENT,
        quiz_id INTEGER NOT NULL,
        question_text TEXT NOT NULL,
        question_type TEXT CHECK(question_type IN ('multiple_choice', 'true_false', 'fill_blank', 'matching')) NOT NULL,
        correct_answer TEXT NOT NULL,
        options TEXT,
        points INTEGER DEFAULT 1,
        explanation TEXT,
        order_index INTEGER DEFAULT 0,
        FOREIGN KEY (quiz_id) REFERENCES quizzes(quiz_id) ON DELETE CASCADE
      )
    ''');

    // User created content (lessons, translations by teachers/admin)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_created_content (
        content_id INTEGER PRIMARY KEY AUTOINCREMENT,
        creator_id TEXT NOT NULL,
        content_type TEXT CHECK(content_type IN ('lesson', 'quiz', 'translation', 'reading')) NOT NULL,
        title TEXT NOT NULL,
        content_data TEXT NOT NULL,
        language_id TEXT,
        category_id TEXT,
        status TEXT CHECK(status IN ('draft', 'published', 'archived')) DEFAULT 'draft',
        difficulty_level TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (creator_id) REFERENCES users(user_id) ON DELETE CASCADE
      )
    ''');

    // Favorites (bookmarked translations, lessons, etc.)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorites (
        favorite_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        content_type TEXT CHECK(content_type IN ('translation', 'lesson', 'quiz')) NOT NULL,
        content_id INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        UNIQUE(user_id, content_type, content_id),
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
      )
    ''');

    // App metadata for versioning and configuration
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // OTP codes for two-factor authentication
    await db.execute('''
      CREATE TABLE IF NOT EXISTS otp_codes (
        otp_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        hashed_code TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        attempts INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        method TEXT DEFAULT 'email',
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
      )
    ''');

    // Admin activity logs
    await db.execute('''
      CREATE TABLE IF NOT EXISTS admin_logs (
        log_id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL,
        user_id TEXT,
        admin_id TEXT,
        details TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
        FOREIGN KEY (admin_id) REFERENCES users(user_id) ON DELETE SET NULL
      )
    ''');

    // Payments table for hybrid architecture
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        payment_id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT DEFAULT 'XAF',
        status TEXT CHECK(status IN ('pending', 'completed', 'failed', 'refunded')) DEFAULT 'pending',
        payment_method TEXT,
        transaction_id TEXT,
        reference TEXT,
        subscription_id TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        completed_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
      )
    ''');

    // Subscriptions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS subscriptions (
        subscription_id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        plan_type TEXT NOT NULL,
        status TEXT CHECK(status IN ('active', 'expired', 'cancelled', 'pending')) DEFAULT 'pending',
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        payment_id TEXT,
        auto_renew INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
        FOREIGN KEY (payment_id) REFERENCES payments(payment_id) ON DELETE SET NULL
      )
    ''');

    // Newsletter subscriptions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS newsletter_subscriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        subscribed_at INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1,
        source TEXT DEFAULT 'mobile',
        language TEXT DEFAULT 'fr',
        tags TEXT,
        unsubscribed_at INTEGER
      )
    ''');

    // Create indexes for performance
    await _createIndexes(db);

    // Insert initial metadata
    await _insertInitialMetadata(db);

    debugPrint('✅ Database schema created successfully');
  }

  /// Create performance indexes
  Future<void> _createIndexes(Database db) async {
    final indexes = [
      'CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON users(firebase_uid)',
      'CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)',
      'CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)',
      'CREATE INDEX IF NOT EXISTS idx_daily_limits_date ON daily_limits(limit_date)',
      'CREATE INDEX IF NOT EXISTS idx_daily_limits_device ON daily_limits(device_id)',
      'CREATE INDEX IF NOT EXISTS idx_user_progress_user ON user_progress(user_id)',
      'CREATE INDEX IF NOT EXISTS idx_user_progress_content ON user_progress(content_type, content_id)',
      'CREATE INDEX IF NOT EXISTS idx_user_statistics_user ON user_statistics(user_id)',
      'CREATE INDEX IF NOT EXISTS idx_quizzes_language ON quizzes(language_id)',
      'CREATE INDEX IF NOT EXISTS idx_quizzes_creator ON quizzes(creator_id)',
      'CREATE INDEX IF NOT EXISTS idx_quiz_questions_quiz ON quiz_questions(quiz_id)',
      'CREATE INDEX IF NOT EXISTS idx_user_content_creator ON user_created_content(creator_id)',
      'CREATE INDEX IF NOT EXISTS idx_user_content_type ON user_created_content(content_type)',
      'CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id)',
      'CREATE INDEX IF NOT EXISTS idx_otp_codes_user ON otp_codes(user_id)',
      'CREATE INDEX IF NOT EXISTS idx_otp_codes_expires ON otp_codes(expires_at)',
      'CREATE INDEX IF NOT EXISTS idx_admin_logs_user ON admin_logs(user_id)',
      'CREATE INDEX IF NOT EXISTS idx_admin_logs_admin ON admin_logs(admin_id)',
      'CREATE INDEX IF NOT EXISTS idx_admin_logs_timestamp ON admin_logs(timestamp)',
      'CREATE INDEX IF NOT EXISTS idx_payments_user ON payments(user_id)',
      'CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status)',
      'CREATE INDEX IF NOT EXISTS idx_subscriptions_user ON subscriptions(user_id)',
      'CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status)',
      'CREATE INDEX IF NOT EXISTS idx_newsletter_email ON newsletter_subscriptions(email)',
      'CREATE INDEX IF NOT EXISTS idx_newsletter_active ON newsletter_subscriptions(is_active)',
    ];

    for (final index in indexes) {
      await db.execute(index);
    }

    debugPrint('✅ Indexes created');
  }

  /// Insert initial metadata
  Future<void> _insertInitialMetadata(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('app_metadata', {
      'key': 'db_version',
      'value': _databaseVersion.toString(),
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('app_metadata', {
      'key': 'created_at',
      'value': DateTime.now().toIso8601String(),
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('app_metadata', {
      'key': 'total_languages',
      'value': '7',
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    debugPrint('✅ Initial metadata inserted');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('⬆️ Upgrading database from v$oldVersion to v$newVersion...');

    if (oldVersion < 2) {
      // Migration from v1 to v2
      await _migrateV1ToV2(db);
    }

    debugPrint('✅ Database upgraded successfully');
  }

  /// Migrate from version 1 to version 2
  Future<void> _migrateV1ToV2(Database db) async {
    debugPrint('🔄 Migrating database to v2...');

    // Add any necessary migration logic here
    // For example, add new columns, tables, or modify existing ones

    // Update metadata
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      'app_metadata',
      {'value': '2', 'updated_at': now},
      where: 'key = ?',
      whereArgs: ['db_version'],
    );
  }

  // ==================== USER OPERATIONS ====================

  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get user by Firebase UID
  Future<Map<String, dynamic>?> getUserByFirebaseUid(String firebaseUid) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'firebase_uid = ?',
      whereArgs: [firebaseUid],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Create or update user
  Future<String> upsertUser(Map<String, dynamic> userData) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    userData['updated_at'] = now;
    if (!userData.containsKey('created_at')) {
      userData['created_at'] = now;
    }

    await db.insert(
      'users',
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return userData['user_id'] as String;
  }

  /// Update user last login
  Future<void> updateUserLastLogin(String userId) async {
    final db = await database;
    await db.update(
      'users',
      {
        'last_login': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ==================== DAILY LIMITS OPERATIONS ====================

  /// Get today's limits for a user or device
  Future<Map<String, dynamic>?> getTodayLimits({
    String? userId,
    String? deviceId,
  }) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

    String whereClause;
    List<dynamic> whereArgs;

    if (userId != null) {
      whereClause = 'user_id = ? AND limit_date = ?';
      whereArgs = [userId, today];
    } else if (deviceId != null) {
      whereClause = 'device_id = ? AND limit_date = ?';
      whereArgs = [deviceId, today];
    } else {
      return null;
    }

    final results = await db.query(
      'daily_limits',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Increment daily limit counter
  Future<void> incrementDailyLimit({
    required String limitType, // 'lessons', 'readings', or 'quizzes'
    String? userId,
    String? deviceId,
  }) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final now = DateTime.now().millisecondsSinceEpoch;

    final existingLimit = await getTodayLimits(
      userId: userId,
      deviceId: deviceId,
    );

    if (existingLimit == null) {
      // Create new limit entry
      await db.insert('daily_limits', {
        'user_id': userId,
        'device_id': deviceId,
        'limit_date': today,
        '${limitType}_count': 1,
        'created_at': now,
      });
    } else {
      // Increment existing counter
      await db.rawUpdate(
        '''
        UPDATE daily_limits 
        SET ${limitType}_count = ${limitType}_count + 1
        WHERE limit_id = ?
      ''',
        [existingLimit['limit_id']],
      );
    }
  }

  /// Check if user/device has reached daily limit
  Future<bool> hasReachedDailyLimit({
    required String limitType,
    required int maxLimit,
    String? userId,
    String? deviceId,
  }) async {
    final limits = await getTodayLimits(userId: userId, deviceId: deviceId);
    if (limits == null) return false;

    final count = limits['${limitType}_count'] as int? ?? 0;
    return count >= maxLimit;
  }

  // ==================== PROGRESS OPERATIONS ====================

  /// Save or update user progress
  Future<void> saveProgress({
    required String userId,
    required String contentType,
    required int contentId,
    String? languageId,
    String status = 'started',
    double? score,
    int? timeSpent,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final existing = await db.query(
      'user_progress',
      where: 'user_id = ? AND content_type = ? AND content_id = ?',
      whereArgs: [userId, contentType, contentId],
    );

    if (existing.isEmpty) {
      // Insert new progress
      await db.insert('user_progress', {
        'user_id': userId,
        'content_type': contentType,
        'content_id': contentId,
        'language_id': languageId,
        'status': status,
        'score': score,
        'time_spent': timeSpent ?? 0,
        'attempts': 1,
        'completed_at': status == 'completed' ? now : null,
        'created_at': now,
        'updated_at': now,
      });
    } else {
      // Update existing progress
      await db.update(
        'user_progress',
        {
          'status': status,
          'score': score ?? existing.first['score'],
          'time_spent':
              (existing.first['time_spent'] as int? ?? 0) + (timeSpent ?? 0),
          'attempts': (existing.first['attempts'] as int? ?? 0) + 1,
          'completed_at': status == 'completed'
              ? now
              : existing.first['completed_at'],
          'updated_at': now,
        },
        where: 'progress_id = ?',
        whereArgs: [existing.first['progress_id']],
      );
    }
  }

  /// Get user progress for specific content
  Future<Map<String, dynamic>?> getProgress({
    required String userId,
    required String contentType,
    required int contentId,
  }) async {
    final db = await database;
    final results = await db.query(
      'user_progress',
      where: 'user_id = ? AND content_type = ? AND content_id = ?',
      whereArgs: [userId, contentType, contentId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get all progress for a user
  Future<List<Map<String, dynamic>>> getUserAllProgress(String userId) async {
    final db = await database;
    return await db.query(
      'user_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
  }

  // ==================== STATISTICS OPERATIONS ====================

  /// Get user statistics
  Future<Map<String, dynamic>?> getUserStatistics(String userId) async {
    final db = await database;
    final results = await db.query(
      'user_statistics',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Create or update user statistics
  Future<void> upsertUserStatistics(
    String userId,
    Map<String, dynamic> stats,
  ) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    stats['user_id'] = userId;
    stats['updated_at'] = now;

    await db.insert(
      'user_statistics',
      stats,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Increment a statistic
  Future<void> incrementStatistic(
    String userId,
    String statName, {
    int incrementBy = 1,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final existing = await getUserStatistics(userId);

    if (existing == null) {
      // Create new stats
      await upsertUserStatistics(userId, {statName: incrementBy});
    } else {
      // Increment existing
      await db.rawUpdate(
        '''
        UPDATE user_statistics 
        SET $statName = $statName + ?, updated_at = ?
        WHERE user_id = ?
      ''',
        [incrementBy, now, userId],
      );
    }
  }

  // ==================== CAMEROON DATABASE QUERIES ====================

  /// Get all languages from Cameroon database
  Future<List<Map<String, dynamic>>> getAllLanguages() async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM cameroon.languages');
  }

  /// Get all categories from Cameroon database
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM cameroon.categories');
  }

  /// Get translations by language
  Future<List<Map<String, dynamic>>> getTranslationsByLanguage(
    String languageId, {
    String? category,
    String? difficultyLevel,
    int? limit,
  }) async {
    final db = await database;

    String query = 'SELECT * FROM cameroon.translations WHERE language_id = ?';
    List<dynamic> args = [languageId];

    if (category != null) {
      query += ' AND category_id = ?';
      args.add(category);
    }

    if (difficultyLevel != null) {
      query += ' AND difficulty_level = ?';
      args.add(difficultyLevel);
    }

    query += ' ORDER BY french_text ASC';

    if (limit != null) {
      query += ' LIMIT ?';
      args.add(limit);
    }

    return await db.rawQuery(query, args);
  }

  /// Search translations by French text
  Future<List<Map<String, dynamic>>> searchTranslations(
    String searchTerm, {
    String? languageId,
    int limit = 50,
  }) async {
    final db = await database;

    String query =
        'SELECT * FROM cameroon.translations WHERE french_text LIKE ?';
    List<dynamic> args = ['%$searchTerm%'];

    if (languageId != null) {
      query += ' AND language_id = ?';
      args.add(languageId);
    }

    query += ' ORDER BY french_text ASC LIMIT ?';
    args.add(limit);

    return await db.rawQuery(query, args);
  }

  /// Get lessons by language
  Future<List<Map<String, dynamic>>> getLessonsByLanguage(
    String languageId, {
    String? level,
    int? limit,
  }) async {
    final db = await database;

    String query = 'SELECT * FROM cameroon.lessons WHERE language_id = ?';
    List<dynamic> args = [languageId];

    if (level != null) {
      query += ' AND level = ?';
      args.add(level);
    }

    query += ' ORDER BY order_index ASC';

    if (limit != null) {
      query += ' LIMIT ?';
      args.add(limit);
    }

    return await db.rawQuery(query, args);
  }

  /// Get lesson by ID
  Future<Map<String, dynamic>?> getLessonById(int lessonId) async {
    final db = await database;
    final results = await db.rawQuery(
      'SELECT * FROM cameroon.lessons WHERE lesson_id = ?',
      [lessonId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Search in translations by text
  Future<List<Map<String, dynamic>>> searchInTranslations(
    String searchQuery, {
    String? languageId,
    int limit = 50,
  }) async {
    final db = await database;

    String query = '''
      SELECT * FROM cameroon.translations 
      WHERE (french_text LIKE ? OR translation LIKE ?)
    ''';
    List<dynamic> args = ['%$searchQuery%', '%$searchQuery%'];

    if (languageId != null) {
      query += ' AND language_id = ?';
      args.add(languageId);
    }

    query += ' ORDER BY french_text ASC LIMIT ?';
    args.add(limit);

    return await db.rawQuery(query, args);
  }

  /// Get quiz by language and difficulty
  Future<List<Map<String, dynamic>>> getQuizzesByLanguageAndDifficulty(
    String languageId, {
    String? difficultyLevel,
    int? limit,
  }) async {
    final db = await database;

    String query = 'SELECT * FROM cameroon.quizzes WHERE language_id = ?';
    List<dynamic> args = [languageId];

    if (difficultyLevel != null) {
      query += ' AND difficulty_level = ?';
      args.add(difficultyLevel);
    }

    query += ' ORDER BY quiz_id';

    if (limit != null) {
      query += ' LIMIT ?';
      args.add(limit);
    }

    return await db.rawQuery(query, args);
  }

  /// Get all quizzes from Cameroon DB
  Future<List<Map<String, dynamic>>> getAllQuizzesFromCameroonDb() async {
    final db = await database;
    return await db.rawQuery(
      'SELECT * FROM cameroon.quizzes ORDER BY language_id, quiz_id',
    );
  }

  /// Get quizzes by language and lesson
  Future<List<Map<String, dynamic>>> getQuizzesByLanguageAndLesson({
    required String languageId,
    int? lessonId,
  }) async {
    final db = await database;

    String query = 'SELECT * FROM cameroon.quizzes WHERE language_id = ?';
    List<dynamic> args = [languageId];

    // If lessonId is provided, we can filter by category or other criteria
    // For now, just return quizzes for the language

    query += ' ORDER BY quiz_id';

    return await db.rawQuery(query, args);
  }

  // ==================== QUIZ OPERATIONS ====================

  /// Get quiz by ID (from Cameroon DB or user-created)
  Future<Map<String, dynamic>?> getQuizById(
    int quizId, {
    bool isFromCameroonDb = true,
  }) async {
    final db = await database;

    if (isFromCameroonDb) {
      final results = await db.rawQuery(
        'SELECT * FROM cameroon.quizzes WHERE quiz_id = ?',
        [quizId],
      );
      return results.isNotEmpty ? results.first : null;
    } else {
      final results = await db.query(
        'quizzes',
        where: 'quiz_id = ?',
        whereArgs: [quizId],
      );
      return results.isNotEmpty ? results.first : null;
    }
  }

  /// Get quiz questions
  Future<List<Map<String, dynamic>>> getQuizQuestions(
    int quizId, {
    bool isFromCameroonDb = true,
  }) async {
    final db = await database;

    if (isFromCameroonDb) {
      return await db.rawQuery(
        'SELECT * FROM cameroon.quiz_questions WHERE quiz_id = ? ORDER BY question_id',
        [quizId],
      );
    } else {
      return await db.query(
        'quiz_questions',
        where: 'quiz_id = ?',
        whereArgs: [quizId],
        orderBy: 'order_index ASC',
      );
    }
  }

  // ==================== FAVORITES OPERATIONS ====================

  /// Add to favorites
  Future<void> addFavorite({
    required String userId,
    required String contentType,
    required int contentId,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('favorites', {
      'user_id': userId,
      'content_type': contentType,
      'content_id': contentId,
      'created_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Remove from favorites
  Future<void> removeFavorite({
    required String userId,
    required String contentType,
    required int contentId,
  }) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'user_id = ? AND content_type = ? AND content_id = ?',
      whereArgs: [userId, contentType, contentId],
    );
  }

  /// Check if favorited
  Future<bool> isFavorite({
    required String userId,
    required String contentType,
    required int contentId,
  }) async {
    final db = await database;
    final results = await db.query(
      'favorites',
      where: 'user_id = ? AND content_type = ? AND content_id = ?',
      whereArgs: [userId, contentType, contentId],
    );
    return results.isNotEmpty;
  }

  /// Get all favorites for a user
  Future<List<Map<String, dynamic>>> getUserFavorites(
    String userId, {
    String? contentType,
  }) async {
    final db = await database;

    if (contentType != null) {
      return await db.query(
        'favorites',
        where: 'user_id = ? AND content_type = ?',
        whereArgs: [userId, contentType],
        orderBy: 'created_at DESC',
      );
    } else {
      return await db.query(
        'favorites',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
    }
  }

  // ==================== TEACHER/ADMIN CONTENT CREATION ====================

  /// Create a new translation (for teachers/admin)
  Future<int> createTranslation(Map<String, dynamic> translationData) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    translationData['created_date'] = now;

    // Insert into user_created_content as well
    final contentId = await db.insert('user_created_content', {
      'creator_id': translationData['creator_id'],
      'content_type': 'translation',
      'title': translationData['french_text'],
      'content_data': translationData.toString(),
      'language_id': translationData['language_id'],
      'status': 'published',
      'created_at': now,
      'updated_at': now,
    });

    return contentId;
  }

  /// Create a new lesson (for teachers/admin)
  Future<int> createLesson(Map<String, dynamic> lessonData) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final contentId = await db.insert('user_created_content', {
      'creator_id': lessonData['creator_id'],
      'content_type': 'lesson',
      'title': lessonData['title'],
      'content_data': lessonData['content'],
      'language_id': lessonData['language_id'],
      'difficulty_level': lessonData['level'],
      'status': lessonData['status'] ?? 'draft',
      'created_at': now,
      'updated_at': now,
    });

    return contentId;
  }

  /// Create a new quiz (for teachers/admin)
  Future<int> createQuiz({
    required String creatorId,
    required String languageId,
    required String title,
    String? description,
    String? difficultyLevel,
    String? categoryId,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final quizId = await db.insert('quizzes', {
      'language_id': languageId,
      'title': title,
      'description': description,
      'difficulty_level': difficultyLevel,
      'category_id': categoryId,
      'creator_id': creatorId,
      'is_official': 0,
      'created_at': now,
      'updated_at': now,
    });

    // Also record in user_created_content
    await db.insert('user_created_content', {
      'creator_id': creatorId,
      'content_type': 'quiz',
      'title': title,
      'content_data': 'Quiz ID: $quizId',
      'language_id': languageId,
      'difficulty_level': difficultyLevel,
      'category_id': categoryId,
      'status': 'draft',
      'created_at': now,
      'updated_at': now,
    });

    return quizId;
  }

  /// Add question to a quiz
  Future<int> addQuizQuestion({
    required int quizId,
    required String questionText,
    required String questionType,
    required String correctAnswer,
    String? options,
    int points = 1,
    String? explanation,
    int orderIndex = 0,
  }) async {
    final db = await database;

    return await db.insert('quiz_questions', {
      'quiz_id': quizId,
      'question_text': questionText,
      'question_type': questionType,
      'correct_answer': correctAnswer,
      'options': options,
      'points': points,
      'explanation': explanation,
      'order_index': orderIndex,
    });
  }

  /// Get all content created by a user (teacher/admin)
  Future<List<Map<String, dynamic>>> getUserCreatedContent(
    String userId, {
    String? contentType,
    String? status,
  }) async {
    final db = await database;

    String whereClause = 'creator_id = ?';
    List<dynamic> whereArgs = [userId];

    if (contentType != null) {
      whereClause += ' AND content_type = ?';
      whereArgs.add(contentType);
    }

    if (status != null) {
      whereClause += ' AND status = ?';
      whereArgs.add(status);
    }

    return await db.query(
      'user_created_content',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
  }

  /// Update content status (publish, archive, draft)
  Future<void> updateContentStatus({
    required int contentId,
    required String status,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'user_created_content',
      {'status': status, 'updated_at': now},
      where: 'content_id = ?',
      whereArgs: [contentId],
    );
  }

  /// Delete user-created content
  Future<void> deleteUserContent(int contentId) async {
    final db = await database;
    await db.delete(
      'user_created_content',
      where: 'content_id = ?',
      whereArgs: [contentId],
    );
  }

  // ==================== PAYMENT OPERATIONS ====================

  /// Create or update payment
  Future<String> upsertPayment(Map<String, dynamic> paymentData) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    paymentData['updated_at'] = now;
    if (!paymentData.containsKey('created_at')) {
      paymentData['created_at'] = now;
    }

    await db.insert(
      'payments',
      paymentData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return paymentData['payment_id'] as String;
  }

  /// Get payment by ID
  Future<Map<String, dynamic>?> getPaymentById(String paymentId) async {
    final db = await database;
    final results = await db.query(
      'payments',
      where: 'payment_id = ?',
      whereArgs: [paymentId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get user payments
  Future<List<Map<String, dynamic>>> getUserPayments(String userId) async {
    final db = await database;
    return await db.query(
      'payments',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  /// Update payment status
  Future<void> updatePaymentStatus({
    required String paymentId,
    required String status,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'payments',
      {
        'status': status,
        'updated_at': now,
        if (status == 'completed') 'completed_at': now,
      },
      where: 'payment_id = ?',
      whereArgs: [paymentId],
    );
  }

  /// Create or update subscription
  Future<String> upsertSubscription(
    Map<String, dynamic> subscriptionData,
  ) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    subscriptionData['updated_at'] = now;
    if (!subscriptionData.containsKey('created_at')) {
      subscriptionData['created_at'] = now;
    }

    await db.insert(
      'subscriptions',
      subscriptionData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return subscriptionData['subscription_id'] as String;
  }

  /// Get user active subscription
  Future<Map<String, dynamic>?> getUserActiveSubscription(String userId) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final results = await db.query(
      'subscriptions',
      where: 'user_id = ? AND status = ? AND end_date > ?',
      whereArgs: [userId, 'active', now],
      orderBy: 'end_date DESC',
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  // ==================== NEWSLETTER OPERATIONS ====================

  /// Subscribe to newsletter
  Future<void> subscribeToNewsletter({
    required String email,
    String source = 'mobile',
    String language = 'fr',
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('newsletter_subscriptions', {
      'email': email.toLowerCase().trim(),
      'subscribed_at': now,
      'is_active': 1,
      'source': source,
      'language': language,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Check if email is subscribed to newsletter
  Future<bool> isEmailSubscribedToNewsletter(String email) async {
    final db = await database;
    final results = await db.query(
      'newsletter_subscriptions',
      where: 'email = ? AND is_active = ?',
      whereArgs: [email.toLowerCase().trim(), 1],
      limit: 1,
    );
    return results.isNotEmpty;
  }

  /// Unsubscribe from newsletter
  Future<void> unsubscribeFromNewsletter(String email) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'newsletter_subscriptions',
      {'is_active': 0, 'unsubscribed_at': now},
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
  }

  // ==================== ADMIN OPERATIONS ====================

  /// Get all users (admin only)
  Future<List<Map<String, dynamic>>> getAllUsers({String? role}) async {
    final db = await database;

    if (role != null) {
      return await db.query(
        'users',
        where: 'role = ?',
        whereArgs: [role],
        orderBy: 'created_at DESC',
      );
    } else {
      return await db.query('users', orderBy: 'created_at DESC');
    }
  }

  /// Update user role (admin only)
  Future<void> updateUserRole(String userId, String newRole) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'users',
      {'role': newRole, 'updated_at': now},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Get platform statistics (admin only)
  Future<Map<String, dynamic>> getPlatformStatistics() async {
    final db = await database;

    final totalUsers =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM users'),
        ) ??
        0;

    final totalStudents =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM users WHERE role = ?', [
            'student',
          ]),
        ) ??
        0;

    final totalTeachers =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM users WHERE role = ?', [
            'teacher',
          ]),
        ) ??
        0;

    final totalLessonsCompleted =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT SUM(total_lessons_completed) FROM user_statistics',
          ),
        ) ??
        0;

    final totalQuizzesCompleted =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT SUM(total_quizzes_completed) FROM user_statistics',
          ),
        ) ??
        0;

    final totalWordsLearned =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT SUM(total_words_learned) FROM user_statistics',
          ),
        ) ??
        0;

    final totalTranslations =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM cameroon.translations'),
        ) ??
        0;

    final totalLessons =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM cameroon.lessons'),
        ) ??
        0;

    final totalQuizzes =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM cameroon.quizzes'),
        ) ??
        0;

    return {
      'total_users': totalUsers,
      'total_students': totalStudents,
      'total_teachers': totalTeachers,
      'total_lessons_completed': totalLessonsCompleted,
      'total_quizzes_completed': totalQuizzesCompleted,
      'total_words_learned': totalWordsLearned,
      'total_translations': totalTranslations,
      'total_lessons': totalLessons,
      'total_quizzes': totalQuizzes,
    };
  }

  // ==================== UTILITY METHODS ====================

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    debugPrint('🔒 Database connection closed');
  }

  /// Delete database (for testing/reset)
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _mainDatabaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
    debugPrint('🗑️ Database deleted');
  }

  /// Get metadata value
  Future<String?> getMetadata(String key) async {
    final db = await database;
    final results = await db.query(
      'app_metadata',
      where: 'key = ?',
      whereArgs: [key],
    );
    return results.isNotEmpty ? results.first['value'] as String? : null;
  }

  /// Set metadata value
  Future<void> setMetadata(String key, String value) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('app_metadata', {
      'key': key,
      'value': value,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ==================== SYNC OPERATIONS (Optional for hybrid architecture) ====================

  /// Update dictionary entry Firebase ID (for sync compatibility)
  Future<void> updateDictionaryEntryFirebaseId(
    String localId,
    String firebaseId,
  ) async {
    // Placeholder for compatibility - not critical for hybrid architecture
    await setMetadata('sync_$localId', firebaseId);
  }

  /// Get pending sync operations (placeholder)
  Future<List<Map<String, dynamic>>> getPendingSyncOperations() async {
    // Hybrid architecture doesn't require Firebase sync for primary data
    return [];
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final value = await getMetadata('last_sync_time');
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// Save pending sync operations (placeholder)
  Future<void> savePendingSyncOperations(List<dynamic> operations) async {
    // Hybrid architecture doesn't require Firebase sync for primary data
    await setMetadata('pending_operations_count', operations.length.toString());
  }

  /// Save last sync time
  Future<void> saveLastSyncTime(DateTime time) async {
    await setMetadata('last_sync_time', time.toIso8601String());
  }
}
