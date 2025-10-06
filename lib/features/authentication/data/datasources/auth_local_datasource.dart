import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Local auth datasource for offline support
abstract class AuthLocalDataSource {
  Future<UserEntity?> getCurrentUser();
  Future<void> saveUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(String userId);
  Future<List<UserEntity>> getAllUsers();
  Future<void> saveAuthTokens(String token, String refreshToken);
  Future<Map<String, String>?> getAuthTokens();
  Future<void> clearAuthData();
  Future<bool> isUserLoggedIn();
  Future<void> updateUserProfile(UserEntity user);
  Future<UserEntity?> getUserById(String userId);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<UserEntity?> getCurrentUser() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'users',
      limit: 1,
      orderBy: 'created_at DESC',
    );

    if (maps.isNotEmpty) {
      return UserModel.fromFirestore(maps.first, maps.first['id'] as String);
    }
    return null;
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    final db = await DatabaseHelper.database;
    final userData = {
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'phoneNumber': user.phoneNumber,
      'photoUrl': user.photoUrl,
      'role': user.role,
      'createdAt': user.createdAt.toIso8601String(),
      'lastLoginAt': user.lastLoginAt?.toIso8601String(),
      'isEmailVerified': user.isEmailVerified ? 1 : 0,
      'preferences': user.preferences?.toString(),
      'last_sync': DateTime.now().toIso8601String(),
      'is_synced': 1,
    };

    await db.insert(
      'users',
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final db = await DatabaseHelper.database;
    final userData = {
      'email': user.email,
      'displayName': user.displayName,
      'phoneNumber': user.phoneNumber,
      'photoUrl': user.photoUrl,
      'role': user.role,
      'lastLoginAt': user.lastLoginAt?.toIso8601String(),
      'isEmailVerified': user.isEmailVerified ? 1 : 0,
      'preferences': user.preferences?.toString(),
      'last_sync': DateTime.now().toIso8601String(),
      'is_synced': 1,
    };

    await db.update(
      'users',
      userData,
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  @override
  Future<void> deleteUser(String userId) async {
    final db = await DatabaseHelper.database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('users');

    return maps.map((map) => UserModel.fromFirestore(map, map['id'] as String)).toList();
  }

  @override
  Future<void> saveAuthTokens(String token, String refreshToken) async {
    final db = await DatabaseHelper.database;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('auth_token', token);
    await prefs.setString('refresh_token', refreshToken);

    await db.insert(
      'auth_tokens',
      {
        'token': token,
        'refresh_token': refreshToken,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Map<String, String>?> getAuthTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final refreshToken = prefs.getString('refresh_token');

    if (token != null && refreshToken != null) {
      return {'token': token, 'refreshToken': refreshToken};
    }
    return null;
  }

  @override
  Future<void> clearAuthData() async {
    final db = await DatabaseHelper.database;
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('current_user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_role');

    await db.delete('auth_tokens');
  }

  @override
  Future<bool> isUserLoggedIn() async {
    final tokens = await getAuthTokens();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('current_user_id');

    return tokens != null && userId != null;
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    await updateUser(user);
  }

  @override
  Future<UserEntity?> getUserById(String userId) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromFirestore(maps.first, maps.first['id'] as String);
    }
    return null;
  }
}
