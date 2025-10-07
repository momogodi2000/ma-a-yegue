import 'unified_database_service.dart';
import 'package:sqflite/sqflite.dart';

/// Compatibility layer for old DatabaseHelper references
/// 
/// ⚠️ DEPRECATED: Use UnifiedDatabaseService directly instead
/// This exists only for backwards compatibility during migration
class DatabaseHelper {
  static UnifiedDatabaseService get _instance => UnifiedDatabaseService.instance;

  /// Get database instance
  static Future<Database> get database async {
    return await _instance.database;
  }

  /// Initialize database (now handled automatically by UnifiedDatabaseService)
  @Deprecated('Use UnifiedDatabaseService.instance.database instead')
  static Future<void> initDatabase() async {
    await _instance.database;
  }

  /// Close database
  @Deprecated('Database is managed by UnifiedDatabaseService')
  static Future<void> closeDatabase() async {
    // No-op - database lifecycle managed by UnifiedDatabaseService
  }
}
