import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'migrations/migration_v3.dart';
import 'migrations/migration_v4.dart';

/// Database helper for managing SQLite database operations
class DatabaseHelper {
  static const String _databaseName = 'maa_yegue_app.db';
  static const int _databaseVersion = 4;

  static Database? _database;

  /// Singleton instance
  static DatabaseHelper get instance => DatabaseHelper._();

  DatabaseHelper._();

  /// Get database instance (singleton pattern)
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  static Future<void> _onCreate(Database db, int version) async {
    print('Creating database version $version...');
    
    // Create all version 1 tables (original schema)
    await _createV1Tables(db);
    
    // If creating at version 2 or higher, add v2 tables
    if (version >= 2) {
      await _createV2Tables(db);
    }
    
    // If creating at version 3, add v3 tables
    if (version >= 3) {
      await DatabaseMigrationV3.createTablesV3(db);
    }
    
    // If creating at version 4, add v4 tables
    if (version >= 4) {
      await DatabaseMigrationV4.createTablesV4(db);
    }
    
    print('✅ Database created successfully at version $version');
  }

  /// Create version 1 tables
  static Future<void> _createV1Tables(Database db) async {
    // Create dictionary entries table
    await db.execute('''
      CREATE TABLE dictionary_entries (
        id TEXT PRIMARY KEY,
        language_code TEXT NOT NULL,
        canonical_form TEXT NOT NULL,
        orthography_variants TEXT,
        ipa TEXT,
        audio_file_references TEXT,
        part_of_speech TEXT NOT NULL,
        translations TEXT,
        example_sentences TEXT,
        tags TEXT,
        difficulty_level TEXT NOT NULL,
        contributor_id TEXT,
        review_status TEXT NOT NULL,
        verified_by TEXT,
        quality_score REAL DEFAULT 0.0,
        last_updated INTEGER NOT NULL,
        source_reference TEXT,
        metadata TEXT,
        search_terms TEXT,
        is_deleted INTEGER DEFAULT 0,
        needs_sync INTEGER DEFAULT 1,
        has_conflict INTEGER DEFAULT 0,
        conflict_data TEXT,
        last_synced INTEGER,
        deleted_at INTEGER,
        UNIQUE(id)
      )
    ''');

    // Create indexes for dictionary
    await db.execute(
        'CREATE INDEX idx_dictionary_language_code ON dictionary_entries(language_code)');
    await db.execute(
        'CREATE INDEX idx_dictionary_canonical_form ON dictionary_entries(canonical_form)');
    await db.execute(
        'CREATE INDEX idx_dictionary_review_status ON dictionary_entries(review_status)');
    await db.execute(
        'CREATE INDEX idx_dictionary_search_terms ON dictionary_entries(search_terms)');
    await db.execute(
        'CREATE INDEX idx_dictionary_sync_status ON dictionary_entries(needs_sync, has_conflict)');
    await db.execute(
        'CREATE INDEX idx_dictionary_last_updated ON dictionary_entries(last_updated)');

    // Create user progress table
    await db.execute('''
      CREATE TABLE user_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        language_code TEXT NOT NULL,
        entry_id TEXT NOT NULL,
        progress_type TEXT NOT NULL,
        progress_value REAL DEFAULT 0.0,
        last_practiced INTEGER,
        streak_count INTEGER DEFAULT 0,
        mastery_level TEXT DEFAULT 'novice',
        metadata TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        needs_sync INTEGER DEFAULT 1,
        FOREIGN KEY(entry_id) REFERENCES dictionary_entries(id),
        UNIQUE(user_id, entry_id, progress_type)
      )
    ''');

    // Create indexes for user progress
    await db.execute(
        'CREATE INDEX idx_progress_user_language ON user_progress(user_id, language_code)');
    await db.execute(
        'CREATE INDEX idx_progress_entry ON user_progress(entry_id)');
    await db.execute(
        'CREATE INDEX idx_progress_sync ON user_progress(needs_sync)');

    // Create offline actions table
    await db.execute('''
      CREATE TABLE offline_actions (
        id TEXT PRIMARY KEY,
        action_type TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        action_data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        user_id TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_retry INTEGER,
        is_processed INTEGER DEFAULT 0
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_offline_actions_user ON offline_actions(user_id)');
    await db.execute(
        'CREATE INDEX idx_offline_actions_processed ON offline_actions(is_processed)');

    // Create sync metadata table
    await db.execute('''
      CREATE TABLE sync_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  /// Create version 2 tables
  static Future<void> _createV2Tables(Database db) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        displayName TEXT,
        phoneNumber TEXT,
        photoUrl TEXT,
        role TEXT NOT NULL DEFAULT 'learner',
        createdAt TEXT NOT NULL,
        lastLoginAt TEXT,
        isEmailVerified INTEGER DEFAULT 0,
        preferences TEXT,
        last_sync TEXT,
        is_synced INTEGER DEFAULT 0,
        UNIQUE(id)
      )
    ''');

    // Create auth tokens table
    await db.execute('''
      CREATE TABLE auth_tokens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        token TEXT NOT NULL,
        refresh_token TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create indexes for users table
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_users_role ON users(role)');
    await db.execute(
        'CREATE INDEX idx_users_sync ON users(is_synced, last_sync)');
  }

  /// Handle database upgrades
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion...');

    // Migrate from version 1 to 2
    if (oldVersion < 2) {
      print('Migrating to version 2...');
      await _createV2Tables(db);
      print('✅ Migrated to version 2');
    }

    // Migrate from version 2 to 3
    if (oldVersion < 3) {
      print('Migrating to version 3...');
      await DatabaseMigrationV3.migrateToV3(db);
      print('✅ Migrated to version 3');
    }

    // Migrate from version 3 to 4
    if (oldVersion < 4) {
      print('Migrating to version 4...');
      await DatabaseMigrationV4.migrateToV4(db);
      print('✅ Migrated to version 4');
    }

    print('✅ Database upgrade completed');
  }

  /// Close database connection
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Clear all data (for testing or reset purposes)
  static Future<void> clearAllData() async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('dictionary_entries');
      await txn.delete('user_progress');
      await txn.delete('offline_actions');
      await txn.delete('sync_metadata');
      await txn.delete('users');
      await txn.delete('auth_tokens');
      await txn.delete('user_levels');
      await txn.delete('learning_progress');
      await txn.delete('lesson_progress');
      await txn.delete('milestones');
      await txn.delete('skill_progress');
    });
  }

  /// Get database size information
  static Future<Map<String, int>> getDatabaseInfo() async {
    final db = await database;

    final dictionaryCount = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM dictionary_entries WHERE is_deleted = 0')) ??
        0;

    final progressCount =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM user_progress')) ?? 0;

    final offlineActionsCount = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM offline_actions WHERE is_processed = 0')) ??
        0;

    final conflictsCount = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM dictionary_entries WHERE has_conflict = 1')) ??
        0;

    final pendingSyncCount = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM dictionary_entries WHERE needs_sync = 1')) ??
        0;

    final userLevelsCount =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM user_levels')) ?? 0;

    final learningProgressCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM learning_progress')) ??
        0;

    return {
      'dictionaryEntries': dictionaryCount,
      'userProgress': progressCount,
      'offlineActions': offlineActionsCount,
      'conflicts': conflictsCount,
      'pendingSync': pendingSyncCount,
      'userLevels': userLevelsCount,
      'learningProgress': learningProgressCount,
    };
  }

  /// Vacuum database to reclaim space
  static Future<void> vacuum() async {
    final db = await database;
    await db.execute('VACUUM');
  }

  /// Check if a table exists
  static Future<bool> tableExists(String tableName) async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  /// Get database version
  static Future<int> getDatabaseVersion() async {
    final db = await database;
    return await db.getVersion();
  }
}
