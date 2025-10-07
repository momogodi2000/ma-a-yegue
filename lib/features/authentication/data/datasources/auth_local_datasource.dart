import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Local auth datasource for session management only
/// User data is stored ONLY in Firebase Firestore
abstract class AuthLocalDataSource {
  Future<UserEntity?> getCachedUser();
  Future<void> cacheUser(UserEntity user);
  Future<void> clearCachedUser();
  Future<void> clearAuthData();
  Future<bool> isUserLoggedIn();
  Future<String?> getCachedUserId();
  Future<void> cacheUserId(String userId);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _keyUserId = 'current_user_id';
  static const String _keyCachedUser = 'cached_user_data';
  static const String _keyLastCacheTime = 'last_cache_time';

  // Cache duration: 5 minutes (to ensure fresh data from Firebase)
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Get cached user if still valid, otherwise return null
  @override
  Future<UserEntity?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if cache is still valid
    final lastCacheTimeStr = prefs.getString(_keyLastCacheTime);
    if (lastCacheTimeStr != null) {
      final lastCacheTime = DateTime.parse(lastCacheTimeStr);
      final now = DateTime.now();

      if (now.difference(lastCacheTime) > _cacheDuration) {
        // Cache expired, clear it
        await prefs.remove(_keyCachedUser);
        await prefs.remove(_keyLastCacheTime);
        return null;
      }
    }

    // Get cached user data
    final userJson = prefs.getString(_keyCachedUser);
    if (userJson != null) {
      try {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return UserModel.fromFirestore(userMap, userMap['id'] as String);
      } catch (e) {
        // If parsing fails, clear cache
        await prefs.remove(_keyCachedUser);
        await prefs.remove(_keyLastCacheTime);
        return null;
      }
    }

    return null;
  }

  /// Cache user data temporarily for quick access
  @override
  Future<void> cacheUser(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert user to JSON
    final userMap = {
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'phoneNumber': user.phoneNumber,
      'photoUrl': user.photoUrl,
      'role': user.role,
      'createdAt': user.createdAt.toIso8601String(),
      'lastLoginAt': user.lastLoginAt?.toIso8601String(),
      'isEmailVerified': user.isEmailVerified,
      'preferences': user.preferences,
    };

    final userJson = json.encode(userMap);

    await prefs.setString(_keyCachedUser, userJson);
    await prefs.setString(_keyLastCacheTime, DateTime.now().toIso8601String());
    await prefs.setString(_keyUserId, user.id);
  }

  /// Clear cached user data
  @override
  Future<void> clearCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCachedUser);
    await prefs.remove(_keyLastCacheTime);
  }

  /// Clear all authentication data
  @override
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyUserId);
    await prefs.remove(_keyCachedUser);
    await prefs.remove(_keyLastCacheTime);
    await prefs.remove('user_email');
    await prefs.remove('user_role');
  }

  /// Check if user is logged in (has cached user ID)
  @override
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId);
    return userId != null;
  }

  /// Get cached user ID
  @override
  Future<String?> getCachedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  /// Cache user ID
  @override
  Future<void> cacheUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
  }
}
