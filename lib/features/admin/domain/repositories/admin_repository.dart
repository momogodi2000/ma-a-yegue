import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_entity.dart';

/// Admin repository interface
abstract class AdminRepository {
  /// Get admin profile
  Future<Either<Failure, AdminEntity>> getAdminProfile(String adminId);

  /// Update admin profile
  Future<Either<Failure, AdminEntity>> updateAdminProfile(AdminEntity admin);

  /// Get system analytics
  Future<Either<Failure, SystemAnalyticsEntity>> getSystemAnalytics();

  /// Get all users
  Future<Either<Failure, List<UserManagementEntity>>> getAllUsers();

  /// Get users by type
  Future<Either<Failure, List<UserManagementEntity>>> getUsersByType(
    String userType,
  );

  /// Get user by ID
  Future<Either<Failure, UserManagementEntity>> getUserById(String userId);

  /// Create new user
  Future<Either<Failure, UserManagementEntity>> createUser(
    UserManagementEntity user,
  );

  /// Update user
  Future<Either<Failure, UserManagementEntity>> updateUser(
    UserManagementEntity user,
  );

  /// Delete user
  Future<Either<Failure, bool>> deleteUser(String userId);

  /// Activate/Deactivate user
  Future<Either<Failure, bool>> toggleUserStatus(String userId, bool isActive);

  /// Verify user
  Future<Either<Failure, bool>> verifyUser(String userId);

  /// Get pending content moderations
  Future<Either<Failure, List<ContentModerationEntity>>>
  getPendingModerations();

  /// Get all content moderations
  Future<Either<Failure, List<ContentModerationEntity>>> getAllModerations();

  /// Get moderation by ID
  Future<Either<Failure, ContentModerationEntity>> getModerationById(
    String moderationId,
  );

  /// Approve content
  Future<Either<Failure, bool>> approveContent(
    String moderationId,
    String adminId,
    String? notes,
  );

  /// Reject content
  Future<Either<Failure, bool>> rejectContent(
    String moderationId,
    String adminId,
    String notes,
  );

  /// Flag content
  Future<Either<Failure, bool>> flagContent(
    String contentType,
    String contentId,
    String reason,
    String reportedBy,
  );

  /// Get system settings
  Future<Either<Failure, List<SystemSettingsEntity>>> getSystemSettings();

  /// Get setting by key
  Future<Either<Failure, SystemSettingsEntity>> getSettingByKey(String key);

  /// Update system setting
  Future<Either<Failure, SystemSettingsEntity>> updateSystemSetting(
    String key,
    String value,
    String adminId,
  );

  /// Get platform statistics
  Future<Either<Failure, Map<String, dynamic>>> getPlatformStatistics();

  /// Get user growth analytics
  Future<Either<Failure, Map<String, dynamic>>> getUserGrowthAnalytics(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get course analytics
  Future<Either<Failure, Map<String, dynamic>>> getCourseAnalytics();

  /// Get revenue analytics (if applicable)
  Future<Either<Failure, Map<String, dynamic>>> getRevenueAnalytics(
    DateTime startDate,
    DateTime endDate,
  );

  /// Export data
  Future<Either<Failure, String>> exportData(
    String dataType,
    String format,
    DateTime? startDate,
    DateTime? endDate,
  );

  /// Send system notification
  Future<Either<Failure, bool>> sendSystemNotification(
    String title,
    String message,
    List<String> targetUserIds,
    String priority,
  );

  /// Broadcast announcement
  Future<Either<Failure, bool>> broadcastAnnouncement(
    String title,
    String content,
    String targetAudience,
  );

  /// Get system logs
  Future<Either<Failure, List<Map<String, dynamic>>>> getSystemLogs(
    String logType,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get audit trail
  Future<Either<Failure, List<Map<String, dynamic>>>> getAuditTrail(
    String? userId,
    String? action,
    DateTime startDate,
    DateTime endDate,
  );

  /// Backup database
  Future<Either<Failure, String>> backupDatabase();

  /// Restore database
  Future<Either<Failure, bool>> restoreDatabase(String backupPath);

  /// Clear cache
  Future<Either<Failure, bool>> clearCache(String cacheType);

  /// Get app version info
  Future<Either<Failure, Map<String, dynamic>>> getAppVersionInfo();

  /// Force update app version
  Future<Either<Failure, bool>> forceUpdateAppVersion(
    String version,
    String platform,
  );
}
