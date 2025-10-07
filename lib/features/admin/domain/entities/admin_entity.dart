import 'package:equatable/equatable.dart';

/// Admin entity representing an administrator user
class AdminEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String role; // e.g., "super_admin", "admin", "moderator"
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final bool isActive;

  const AdminEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.permissions = const [],
    required this.createdAt,
    required this.lastActiveAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    email,
    role,
    permissions,
    createdAt,
    lastActiveAt,
    isActive,
  ];

  AdminEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? role,
    List<String>? permissions,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? isActive,
  }) {
    return AdminEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// System analytics entity
class SystemAnalyticsEntity extends Equatable {
  final int totalUsers;
  final int totalLearners;
  final int totalTeachers;
  final int totalAdmins;
  final int totalCourses;
  final int totalLessons;
  final int totalCertificates;
  final int activeUsers;
  final int newUsersToday;
  final int newUsersThisWeek;
  final int newUsersThisMonth;
  final double averageCompletionRate;
  final double averageUserRating;
  final Map<String, int> usersByLanguage;
  final Map<String, int> coursesByCategory;
  final DateTime lastUpdated;

  const SystemAnalyticsEntity({
    required this.totalUsers,
    required this.totalLearners,
    required this.totalTeachers,
    required this.totalAdmins,
    required this.totalCourses,
    required this.totalLessons,
    required this.totalCertificates,
    required this.activeUsers,
    required this.newUsersToday,
    required this.newUsersThisWeek,
    required this.newUsersThisMonth,
    required this.averageCompletionRate,
    required this.averageUserRating,
    required this.usersByLanguage,
    required this.coursesByCategory,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    totalUsers,
    totalLearners,
    totalTeachers,
    totalAdmins,
    totalCourses,
    totalLessons,
    totalCertificates,
    activeUsers,
    newUsersToday,
    newUsersThisWeek,
    newUsersThisMonth,
    averageCompletionRate,
    averageUserRating,
    usersByLanguage,
    coursesByCategory,
    lastUpdated,
  ];
}

/// User management entity
class UserManagementEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String userType; // "learner", "teacher", "admin"
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final int coursesEnrolled;
  final int coursesCompleted;

  const UserManagementEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    this.lastLoginAt,
    this.coursesEnrolled = 0,
    this.coursesCompleted = 0,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    userType,
    isActive,
    isVerified,
    createdAt,
    lastLoginAt,
    coursesEnrolled,
    coursesCompleted,
  ];

  UserManagementEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? userType,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? coursesEnrolled,
    int? coursesCompleted,
  }) {
    return UserManagementEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      coursesEnrolled: coursesEnrolled ?? this.coursesEnrolled,
      coursesCompleted: coursesCompleted ?? this.coursesCompleted,
    );
  }
}

/// Content moderation entity
class ContentModerationEntity extends Equatable {
  final String id;
  final String contentType; // "course", "lesson", "comment", "review"
  final String contentId;
  final String reportedBy;
  final String reason;
  final String status; // "pending", "approved", "rejected", "flagged"
  final DateTime reportedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? reviewNotes;

  const ContentModerationEntity({
    required this.id,
    required this.contentType,
    required this.contentId,
    required this.reportedBy,
    required this.reason,
    required this.status,
    required this.reportedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewNotes,
  });

  @override
  List<Object?> get props => [
    id,
    contentType,
    contentId,
    reportedBy,
    reason,
    status,
    reportedAt,
    reviewedAt,
    reviewedBy,
    reviewNotes,
  ];

  ContentModerationEntity copyWith({
    String? id,
    String? contentType,
    String? contentId,
    String? reportedBy,
    String? reason,
    String? status,
    DateTime? reportedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewNotes,
  }) {
    return ContentModerationEntity(
      id: id ?? this.id,
      contentType: contentType ?? this.contentType,
      contentId: contentId ?? this.contentId,
      reportedBy: reportedBy ?? this.reportedBy,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      reportedAt: reportedAt ?? this.reportedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewNotes: reviewNotes ?? this.reviewNotes,
    );
  }
}

/// System settings entity
class SystemSettingsEntity extends Equatable {
  final String id;
  final String key;
  final String value;
  final String description;
  final DateTime updatedAt;
  final String updatedBy;

  const SystemSettingsEntity({
    required this.id,
    required this.key,
    required this.value,
    required this.description,
    required this.updatedAt,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [
    id,
    key,
    value,
    description,
    updatedAt,
    updatedBy,
  ];

  SystemSettingsEntity copyWith({
    String? id,
    String? key,
    String? value,
    String? description,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return SystemSettingsEntity(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      description: description ?? this.description,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
