import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/admin_entity.dart';
import '../repositories/admin_repository.dart';

// Get Admin Profile
class GetAdminProfile implements UseCase<AdminEntity, String> {
  final AdminRepository repository;
  const GetAdminProfile(this.repository);

  @override
  Future<Either<Failure, AdminEntity>> call(String adminId) async {
    return await repository.getAdminProfile(adminId);
  }
}

// Update Admin Profile
class UpdateAdminProfile implements UseCase<AdminEntity, AdminEntity> {
  final AdminRepository repository;
  const UpdateAdminProfile(this.repository);

  @override
  Future<Either<Failure, AdminEntity>> call(AdminEntity admin) async {
    return await repository.updateAdminProfile(admin);
  }
}

// Get System Analytics
class GetSystemAnalytics implements UseCase<SystemAnalyticsEntity, NoParams> {
  final AdminRepository repository;
  const GetSystemAnalytics(this.repository);

  @override
  Future<Either<Failure, SystemAnalyticsEntity>> call(NoParams params) async {
    return await repository.getSystemAnalytics();
  }
}

// Get All Users
class GetAllUsers implements UseCase<List<UserManagementEntity>, NoParams> {
  final AdminRepository repository;
  const GetAllUsers(this.repository);

  @override
  Future<Either<Failure, List<UserManagementEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getAllUsers();
  }
}

// Get Users By Type
class GetUsersByType implements UseCase<List<UserManagementEntity>, String> {
  final AdminRepository repository;
  const GetUsersByType(this.repository);

  @override
  Future<Either<Failure, List<UserManagementEntity>>> call(
    String userType,
  ) async {
    return await repository.getUsersByType(userType);
  }
}

// Get User By ID
class GetUserById implements UseCase<UserManagementEntity, String> {
  final AdminRepository repository;
  const GetUserById(this.repository);

  @override
  Future<Either<Failure, UserManagementEntity>> call(String userId) async {
    return await repository.getUserById(userId);
  }
}

// Create User
class CreateUser
    implements UseCase<UserManagementEntity, UserManagementEntity> {
  final AdminRepository repository;
  const CreateUser(this.repository);

  @override
  Future<Either<Failure, UserManagementEntity>> call(
    UserManagementEntity user,
  ) async {
    return await repository.createUser(user);
  }
}

// Update User
class UpdateUser
    implements UseCase<UserManagementEntity, UserManagementEntity> {
  final AdminRepository repository;
  const UpdateUser(this.repository);

  @override
  Future<Either<Failure, UserManagementEntity>> call(
    UserManagementEntity user,
  ) async {
    return await repository.updateUser(user);
  }
}

// Delete User
class DeleteUser implements UseCase<bool, String> {
  final AdminRepository repository;
  const DeleteUser(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.deleteUser(userId);
  }
}

// Toggle User Status
class ToggleUserStatus implements UseCase<bool, ToggleUserStatusParams> {
  final AdminRepository repository;
  const ToggleUserStatus(this.repository);

  @override
  Future<Either<Failure, bool>> call(ToggleUserStatusParams params) async {
    return await repository.toggleUserStatus(params.userId, params.isActive);
  }
}

class ToggleUserStatusParams extends Equatable {
  final String userId;
  final bool isActive;

  const ToggleUserStatusParams({required this.userId, required this.isActive});

  @override
  List<Object?> get props => [userId, isActive];
}

// Verify User
class VerifyUser implements UseCase<bool, String> {
  final AdminRepository repository;
  const VerifyUser(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.verifyUser(userId);
  }
}

// Get Pending Moderations
class GetPendingModerations
    implements UseCase<List<ContentModerationEntity>, NoParams> {
  final AdminRepository repository;
  const GetPendingModerations(this.repository);

  @override
  Future<Either<Failure, List<ContentModerationEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getPendingModerations();
  }
}

// Get All Moderations
class GetAllModerations
    implements UseCase<List<ContentModerationEntity>, NoParams> {
  final AdminRepository repository;
  const GetAllModerations(this.repository);

  @override
  Future<Either<Failure, List<ContentModerationEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getAllModerations();
  }
}

// Approve Content
class ApproveContent implements UseCase<bool, ApproveContentParams> {
  final AdminRepository repository;
  const ApproveContent(this.repository);

  @override
  Future<Either<Failure, bool>> call(ApproveContentParams params) async {
    return await repository.approveContent(
      params.moderationId,
      params.adminId,
      params.notes,
    );
  }
}

class ApproveContentParams extends Equatable {
  final String moderationId;
  final String adminId;
  final String? notes;

  const ApproveContentParams({
    required this.moderationId,
    required this.adminId,
    this.notes,
  });

  @override
  List<Object?> get props => [moderationId, adminId, notes];
}

// Reject Content
class RejectContent implements UseCase<bool, RejectContentParams> {
  final AdminRepository repository;
  const RejectContent(this.repository);

  @override
  Future<Either<Failure, bool>> call(RejectContentParams params) async {
    return await repository.rejectContent(
      params.moderationId,
      params.adminId,
      params.notes,
    );
  }
}

class RejectContentParams extends Equatable {
  final String moderationId;
  final String adminId;
  final String notes;

  const RejectContentParams({
    required this.moderationId,
    required this.adminId,
    required this.notes,
  });

  @override
  List<Object?> get props => [moderationId, adminId, notes];
}

// Get System Settings
class GetSystemSettings
    implements UseCase<List<SystemSettingsEntity>, NoParams> {
  final AdminRepository repository;
  const GetSystemSettings(this.repository);

  @override
  Future<Either<Failure, List<SystemSettingsEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getSystemSettings();
  }
}

// Update System Setting
class UpdateSystemSetting
    implements UseCase<SystemSettingsEntity, UpdateSystemSettingParams> {
  final AdminRepository repository;
  const UpdateSystemSetting(this.repository);

  @override
  Future<Either<Failure, SystemSettingsEntity>> call(
    UpdateSystemSettingParams params,
  ) async {
    return await repository.updateSystemSetting(
      params.key,
      params.value,
      params.adminId,
    );
  }
}

class UpdateSystemSettingParams extends Equatable {
  final String key;
  final String value;
  final String adminId;

  const UpdateSystemSettingParams({
    required this.key,
    required this.value,
    required this.adminId,
  });

  @override
  List<Object?> get props => [key, value, adminId];
}

// Get Platform Statistics
class GetPlatformStatistics implements UseCase<Map<String, dynamic>, NoParams> {
  final AdminRepository repository;
  const GetPlatformStatistics(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    return await repository.getPlatformStatistics();
  }
}

// Send System Notification
class SendSystemNotification
    implements UseCase<bool, SendSystemNotificationParams> {
  final AdminRepository repository;
  const SendSystemNotification(this.repository);

  @override
  Future<Either<Failure, bool>> call(
    SendSystemNotificationParams params,
  ) async {
    return await repository.sendSystemNotification(
      params.title,
      params.message,
      params.targetUserIds,
      params.priority,
    );
  }
}

class SendSystemNotificationParams extends Equatable {
  final String title;
  final String message;
  final List<String> targetUserIds;
  final String priority;

  const SendSystemNotificationParams({
    required this.title,
    required this.message,
    required this.targetUserIds,
    required this.priority,
  });

  @override
  List<Object?> get props => [title, message, targetUserIds, priority];
}

// Broadcast Announcement
class BroadcastAnnouncement
    implements UseCase<bool, BroadcastAnnouncementParams> {
  final AdminRepository repository;
  const BroadcastAnnouncement(this.repository);

  @override
  Future<Either<Failure, bool>> call(BroadcastAnnouncementParams params) async {
    return await repository.broadcastAnnouncement(
      params.title,
      params.content,
      params.targetAudience,
    );
  }
}

class BroadcastAnnouncementParams extends Equatable {
  final String title;
  final String content;
  final String targetAudience;

  const BroadcastAnnouncementParams({
    required this.title,
    required this.content,
    required this.targetAudience,
  });

  @override
  List<Object?> get props => [title, content, targetAudience];
}
