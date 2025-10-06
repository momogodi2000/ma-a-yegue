import 'user_entity.dart';

/// Authentication response entity
class AuthResponseEntity {
  final UserEntity user;
  final String? token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final bool success;
  final String? message;

  const AuthResponseEntity({
    required this.user,
    this.token,
    this.refreshToken,
    this.expiresAt,
    this.success = true,
    this.message,
  });

  /// Create from JSON
  factory AuthResponseEntity.fromJson(Map<String, dynamic> json) {
    return AuthResponseEntity(
      user: UserEntity.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt?.toIso8601String(),
      'success': success,
      'message': message,
    };
  }
}
