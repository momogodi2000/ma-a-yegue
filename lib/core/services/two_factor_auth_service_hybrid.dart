import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'firebase_service.dart';
import '../database/unified_database_service.dart';

/// Two-Factor Authentication Service - Hybrid Architecture
///
/// ✅ Uses SQLite for all OTP and 2FA data storage
/// ✅ Uses Firebase Auth for user authentication only
///
/// This replaces the old Firestore-based 2FA service
class TwoFactorAuthServiceHybrid {
  final FirebaseService _firebaseService;
  final UnifiedDatabaseService _database = UnifiedDatabaseService.instance;

  TwoFactorAuthServiceHybrid(this._firebaseService);

  /// Generate a 6-digit OTP code
  String _generateOTP() {
    final random = Random.secure();
    final code = random.nextInt(900000) + 100000;
    return code.toString();
  }

  /// Hash the OTP for secure storage
  String _hashOTP(String otp) {
    final bytes = utf8.encode(otp);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Send OTP via email
  Future<bool> sendOTPViaEmail(String userId, String email) async {
    try {
      final otp = _generateOTP();
      final hashedOTP = _hashOTP(otp);
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));

      // Store OTP in SQLite
      final db = await _database.database;
      await db.insert('otp_codes', {
        'user_id': userId,
        'hashed_code': hashedOTP,
        'expires_at': expiresAt.toIso8601String(),
        'attempts': 0,
        'created_at': DateTime.now().toIso8601String(),
        'method': 'email',
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // TODO: Integrate with email service to send OTP
      if (kDebugMode) {
        debugPrint('🔐 OTP for $email: $otp (expires at $expiresAt)');
      }

      // Log analytics
      await _firebaseService.logEvent(
        name: '2fa_otp_sent',
        parameters: {'method': 'email'},
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error sending OTP: $e');
      }
      await _firebaseService.recordError(
        e,
        StackTrace.current,
        reason: 'Failed to send OTP',
      );
      return false;
    }
  }

  /// Verify OTP code
  Future<bool> verifyOTP(String userId, String otp) async {
    try {
      final hashedInput = _hashOTP(otp);
      final db = await _database.database;

      // Get OTP record from SQLite
      final results = await db.query(
        'otp_codes',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (results.isEmpty) {
        if (kDebugMode) {
          debugPrint('❌ No OTP found for user: $userId');
        }
        return false;
      }

      final data = results.first;
      final hashedCode = data['hashed_code'] as String;
      final expiresAt = DateTime.parse(data['expires_at'] as String);
      final attempts = data['attempts'] as int;

      // Check if OTP has expired
      if (DateTime.now().isAfter(expiresAt)) {
        if (kDebugMode) {
          debugPrint('❌ OTP expired');
        }
        // Delete expired OTP
        await db.delete('otp_codes', where: 'user_id = ?', whereArgs: [userId]);
        return false;
      }

      // Check attempts
      if (attempts >= 3) {
        if (kDebugMode) {
          debugPrint('❌ Maximum OTP attempts exceeded');
        }
        return false;
      }

      // Verify OTP
      if (hashedCode == hashedInput) {
        // OTP is valid - update user's 2FA verification timestamp in SQLite
        final user = await _database.getUserByFirebaseUid(
          _firebaseService.currentUser!.uid,
        );
        if (user != null) {
          await _database.upsertUser({
            'user_id': user['user_id'],
            'firebase_uid': user['firebase_uid'],
            'last_two_factor_verification': DateTime.now().toIso8601String(),
          });
        }

        // Delete used OTP
        await db.delete('otp_codes', where: 'user_id = ?', whereArgs: [userId]);

        // Log analytics
        await _firebaseService.logEvent(
          name: '2fa_verified',
          parameters: {'method': 'email'},
        );

        return true;
      } else {
        // Increment attempts
        await db.update(
          'otp_codes',
          {'attempts': attempts + 1},
          where: 'user_id = ?',
          whereArgs: [userId],
        );

        if (kDebugMode) {
          debugPrint('❌ Invalid OTP code');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error verifying OTP: $e');
      }
      await _firebaseService.recordError(
        e,
        StackTrace.current,
        reason: 'Failed to verify OTP',
      );
      return false;
    }
  }

  /// Delete OTP for user
  Future<void> deleteOTP(String userId) async {
    try {
      final db = await _database.database;
      await db.delete('otp_codes', where: 'user_id = ?', whereArgs: [userId]);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting OTP: $e');
      }
    }
  }

  /// Enable 2FA for a user
  Future<void> enable2FA(String userId) async {
    try {
      final user = await _database.getUserByFirebaseUid(
        _firebaseService.currentUser!.uid,
      );
      if (user != null) {
        await _database.upsertUser({
          'user_id': user['user_id'],
          'firebase_uid': user['firebase_uid'],
          'two_factor_enabled': 1,
          'two_factor_enabled_at': DateTime.now().toIso8601String(),
        });

        await _firebaseService.logEvent(name: '2fa_enabled');

        if (kDebugMode) {
          debugPrint('✅ 2FA enabled for user: $userId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error enabling 2FA: $e');
      }
      throw Exception('Failed to enable 2FA: $e');
    }
  }

  /// Disable 2FA for a user
  Future<void> disable2FA(String userId) async {
    try {
      final user = await _database.getUserByFirebaseUid(
        _firebaseService.currentUser!.uid,
      );
      if (user != null) {
        await _database.upsertUser({
          'user_id': user['user_id'],
          'firebase_uid': user['firebase_uid'],
          'two_factor_enabled': 0,
          'two_factor_disabled_at': DateTime.now().toIso8601String(),
        });

        await _firebaseService.logEvent(name: '2fa_disabled');

        if (kDebugMode) {
          debugPrint('✅ 2FA disabled for user: $userId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error disabling 2FA: $e');
      }
      throw Exception('Failed to disable 2FA: $e');
    }
  }

  /// Check if 2FA is enabled for user
  Future<bool> is2FAEnabled(String userId) async {
    try {
      final user = await _database.getUserByFirebaseUid(
        _firebaseService.currentUser!.uid,
      );
      if (user != null) {
        final twoFactorEnabled = user['two_factor_enabled'] as int?;
        return twoFactorEnabled == 1;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking 2FA status: $e');
      }
      return false;
    }
  }

  /// Check if user needs 2FA verification
  Future<bool> needs2FAVerification(String userId) async {
    try {
      final user = await _database.getUserByFirebaseUid(
        _firebaseService.currentUser!.uid,
      );
      if (user == null) return false;

      final twoFactorEnabled = user['two_factor_enabled'] as int?;
      if (twoFactorEnabled != 1) return false;

      final lastVerificationStr =
          user['last_two_factor_verification'] as String?;
      if (lastVerificationStr == null) return true;

      final lastVerification = DateTime.parse(lastVerificationStr);
      final hoursSinceVerification = DateTime.now()
          .difference(lastVerification)
          .inHours;

      // Require verification every 24 hours
      return hoursSinceVerification >= 24;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking 2FA verification need: $e');
      }
      return false;
    }
  }

  /// Generate backup codes for 2FA
  Future<List<String>> generateBackupCodes(String userId) async {
    try {
      final codes = <String>[];
      for (int i = 0; i < 10; i++) {
        codes.add(_generateOTP());
      }

      // Store hashed backup codes in SQLite
      final user = await _database.getUserByFirebaseUid(
        _firebaseService.currentUser!.uid,
      );
      if (user != null) {
        final hashedCodes = codes.map((c) => _hashOTP(c)).toList();
        await _database.upsertUser({
          'user_id': user['user_id'],
          'firebase_uid': user['firebase_uid'],
          'backup_codes': jsonEncode(hashedCodes),
          'backup_codes_generated_at': DateTime.now().toIso8601String(),
        });

        await _firebaseService.logEvent(name: '2fa_backup_codes_generated');

        if (kDebugMode) {
          debugPrint('✅ Backup codes generated for user: $userId');
        }
      }

      return codes;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error generating backup codes: $e');
      }
      throw Exception('Failed to generate backup codes: $e');
    }
  }

  /// Verify backup code
  Future<bool> verifyBackupCode(String userId, String code) async {
    try {
      final hashedInput = _hashOTP(code);
      final user = await _database.getUserByFirebaseUid(
        _firebaseService.currentUser!.uid,
      );
      if (user == null) return false;

      final backupCodesJson = user['backup_codes'] as String?;
      if (backupCodesJson == null) return false;

      final backupCodes = (jsonDecode(backupCodesJson) as List).cast<String>();

      if (backupCodes.contains(hashedInput)) {
        // Remove used backup code
        backupCodes.remove(hashedInput);
        await _database.upsertUser({
          'user_id': user['user_id'],
          'firebase_uid': user['firebase_uid'],
          'backup_codes': jsonEncode(backupCodes),
        });

        await _firebaseService.logEvent(name: '2fa_backup_code_used');

        if (kDebugMode) {
          debugPrint('✅ Backup code verified for user: $userId');
        }

        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error verifying backup code: $e');
      }
      return false;
    }
  }

  /// Clean up expired OTPs (should be called periodically)
  Future<void> cleanupExpiredOTPs() async {
    try {
      final db = await _database.database;
      final now = DateTime.now().toIso8601String();
      final deleted = await db.delete(
        'otp_codes',
        where: 'expires_at < ?',
        whereArgs: [now],
      );

      if (kDebugMode && deleted > 0) {
        debugPrint('🧹 Cleaned up $deleted expired OTPs');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error cleaning up expired OTPs: $e');
      }
    }
  }
}

// Backward compatibility alias
typedef TwoFactorAuthService = TwoFactorAuthServiceHybrid;
