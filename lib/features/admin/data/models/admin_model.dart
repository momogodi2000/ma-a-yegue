import '../../domain/entities/admin_entity.dart';

/// Admin data model
class AdminModel extends AdminEntity {
  const AdminModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    required super.role,
    super.permissions,
    required super.createdAt,
    required super.lastActiveAt,
    super.isActive,
  });

  factory AdminModel.fromEntity(AdminEntity entity) {
    return AdminModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      permissions: entity.permissions,
      createdAt: entity.createdAt,
      lastActiveAt: entity.lastActiveAt,
      isActive: entity.isActive,
    );
  }

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      permissions: List<String>.from(json['permissions'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      'permissions': permissions,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  AdminEntity toEntity() {
    return AdminEntity(
      id: id,
      userId: userId,
      name: name,
      email: email,
      role: role,
      permissions: permissions,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt,
      isActive: isActive,
    );
  }
}

/// System analytics model
class SystemAnalyticsModel extends SystemAnalyticsEntity {
  const SystemAnalyticsModel({
    required super.totalUsers,
    required super.totalLearners,
    required super.totalTeachers,
    required super.totalAdmins,
    required super.totalCourses,
    required super.totalLessons,
    required super.totalCertificates,
    required super.activeUsers,
    required super.newUsersToday,
    required super.newUsersThisWeek,
    required super.newUsersThisMonth,
    required super.averageCompletionRate,
    required super.averageUserRating,
    required super.usersByLanguage,
    required super.coursesByCategory,
    required super.lastUpdated,
  });

  factory AdminModel.fromEntity(SystemAnalyticsEntity entity) {
    return SystemAnalyticsModel(
      totalUsers: entity.totalUsers,
      totalLearners: entity.totalLearners,
      totalTeachers: entity.totalTeachers,
      totalAdmins: entity.totalAdmins,
      totalCourses: entity.totalCourses,
      totalLessons: entity.totalLessons,
      totalCertificates: entity.totalCertificates,
      activeUsers: entity.activeUsers,
      newUsersToday: entity.newUsersToday,
      newUsersThisWeek: entity.newUsersThisWeek,
      newUsersThisMonth: entity.newUsersThisMonth,
      averageCompletionRate: entity.averageCompletionRate,
      averageUserRating: entity.averageUserRating,
      usersByLanguage: entity.usersByLanguage,
      coursesByCategory: entity.coursesByCategory,
      lastUpdated: entity.lastUpdated,
    );
  }

  factory SystemAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return SystemAnalyticsModel(
      totalUsers: json['totalUsers'] as int,
      totalLearners: json['totalLearners'] as int,
      totalTeachers: json['totalTeachers'] as int,
      totalAdmins: json['totalAdmins'] as int,
      totalCourses: json['totalCourses'] as int,
      totalLessons: json['totalLessons'] as int,
      totalCertificates: json['totalCertificates'] as int,
      activeUsers: json['activeUsers'] as int,
      newUsersToday: json['newUsersToday'] as int,
      newUsersThisWeek: json['newUsersThisWeek'] as int,
      newUsersThisMonth: json['newUsersThisMonth'] as int,
      averageCompletionRate: (json['averageCompletionRate'] as num).toDouble(),
      averageUserRating: (json['averageUserRating'] as num).toDouble(),
      usersByLanguage: Map<String, int>.from(json['usersByLanguage'] ?? {}),
      coursesByCategory: Map<String, int>.from(json['coursesByCategory'] ?? {}),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalLearners': totalLearners,
      'totalTeachers': totalTeachers,
      'totalAdmins': totalAdmins,
      'totalCourses': totalCourses,
      'totalLessons': totalLessons,
      'totalCertificates': totalCertificates,
      'activeUsers': activeUsers,
      'newUsersToday': newUsersToday,
      'newUsersThisWeek': newUsersThisWeek,
      'newUsersThisMonth': newUsersThisMonth,
      'averageCompletionRate': averageCompletionRate,
      'averageUserRating': averageUserRating,
      'usersByLanguage': usersByLanguage,
      'coursesByCategory': coursesByCategory,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  SystemAnalyticsEntity toEntity() {
    return SystemAnalyticsEntity(
      totalUsers: totalUsers,
      totalLearners: totalLearners,
      totalTeachers: totalTeachers,
      totalAdmins: totalAdmins,
      totalCourses: totalCourses,
      totalLessons: totalLessons,
      totalCertificates: totalCertificates,
      activeUsers: activeUsers,
      newUsersToday: newUsersToday,
      newUsersThisWeek: newUsersThisWeek,
      newUsersThisMonth: newUsersThisMonth,
      averageCompletionRate: averageCompletionRate,
      averageUserRating: averageUserRating,
      usersByLanguage: usersByLanguage,
      coursesByCategory: coursesByCategory,
      lastUpdated: lastUpdated,
    );
  }
}

/// User management model
class UserManagementModel extends UserManagementEntity {
  const UserManagementModel({
    required super.id,
    required super.name,
    required super.email,
    required super.userType,
    required super.isActive,
    required super.isVerified,
    required super.createdAt,
    super.lastLoginAt,
    super.coursesEnrolled,
    super.coursesCompleted,
  });

  factory UserManagementModel.fromEntity(UserManagementEntity entity) {
    return UserManagementModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      userType: entity.userType,
      isActive: entity.isActive,
      isVerified: entity.isVerified,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      coursesEnrolled: entity.coursesEnrolled,
      coursesCompleted: entity.coursesCompleted,
    );
  }

  factory UserManagementModel.fromJson(Map<String, dynamic> json) {
    return UserManagementModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      userType: json['userType'] as String,
      isActive: json['isActive'] as bool,
      isVerified: json['isVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      coursesEnrolled: json['coursesEnrolled'] as int? ?? 0,
      coursesCompleted: json['coursesCompleted'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'userType': userType,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'coursesEnrolled': coursesEnrolled,
      'coursesCompleted': coursesCompleted,
    };
  }

  UserManagementEntity toEntity() {
    return UserManagementEntity(
      id: id,
      name: name,
      email: email,
      userType: userType,
      isActive: isActive,
      isVerified: isVerified,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      coursesEnrolled: coursesEnrolled,
      coursesCompleted: coursesCompleted,
    );
  }
}
