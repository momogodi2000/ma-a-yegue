import '../../domain/entities/auth_response_entity.dart';
import 'user_model.dart';

/// Auth response model for data layer
class AuthResponseModel extends AuthResponseEntity {
  const AuthResponseModel({
    required super.user,
    super.token,
    super.refreshToken,
    super.expiresAt,
    super.success,
    super.message,
  });

  /// Create from JSON
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromEntity(AuthResponseEntity.fromJson(json).user),
      token: json['token'],
      refreshToken: json['refreshToken'],
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      success: json['success'] ?? true,
      message: json['message'],
    );
  }

  /// Convert to JSON
  @override
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

  /// Convert to entity
  AuthResponseEntity toEntity() {
    return AuthResponseEntity(
      user: user,
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      success: success,
      message: message,
    );
  }

  /// Create successful response
  static AuthResponseModel createSuccess({
    required UserModel user,
    String? token,
    String? refreshToken,
    DateTime? expiresAt,
    String? message,
  }) {
    return AuthResponseModel(
      user: user,
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      success: true,
      message: message ?? 'Success',
    );
  }

  /// Create failure response
  static AuthResponseModel createFailure({
    required String message,
    UserModel? user,
  }) {
    return AuthResponseModel(
      user: user ?? UserModel(
        id: '',
        email: '',
        createdAt: DateTime.now(),
      ),
      success: false,
      message: message,
    );
  }

  /// Create copy with new values
  AuthResponseModel copyWith({
    UserModel? user,
    String? token,
    String? refreshToken,
    DateTime? expiresAt,
    bool? success,
    String? message,
  }) {
    return AuthResponseModel(
      user: user ?? this.user,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      success: success ?? this.success,
      message: message ?? this.message,
    );
  }
}
