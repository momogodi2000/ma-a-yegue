import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:maa_yegue/core/database/unified_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Initialize FFI for SQLite
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Guest Limit Service Tests', () {
    late UnifiedDatabaseService db;

    setUp(() async {
      db = UnifiedDatabaseService.instance;
      await db.deleteDatabase(); // Clean start for each test
    });

    tearDown(() async {
      await db.close();
    });

    test('Guest daily limits track correctly', () async {
      const deviceId = 'test-device-123';

      // Initially, no limits should exist
      final initialLimits = await db.getTodayLimits(deviceId: deviceId);
      expect(initialLimits, isNull);

      // Increment lesson count
      await db.incrementDailyLimit(limitType: 'lessons', deviceId: deviceId);

      // Check limits
      final afterOneLesson = await db.getTodayLimits(deviceId: deviceId);
      expect(afterOneLesson, isNotNull);
      expect(afterOneLesson?['lessons_count'], equals(1));
      expect(afterOneLesson?['readings_count'], equals(0));
      expect(afterOneLesson?['quizzes_count'], equals(0));
    });

    test('Guest can access content within limits', () async {
      const deviceId = 'test-device-456';

      // Check initially (should be able to access)
      final canAccess = await db.hasReachedDailyLimit(
        limitType: 'lessons',
        maxLimit: 5,
        deviceId: deviceId,
      );
      expect(canAccess, isFalse); // Has NOT reached limit

      // Increment 5 times
      for (int i = 0; i < 5; i++) {
        await db.incrementDailyLimit(limitType: 'lessons', deviceId: deviceId);
      }

      // Now should have reached limit
      final hasReachedLimit = await db.hasReachedDailyLimit(
        limitType: 'lessons',
        maxLimit: 5,
        deviceId: deviceId,
      );
      expect(hasReachedLimit, isTrue);
    });

    test('Guest limits are separate for different content types', () async {
      final deviceId = 'test-device-789';

      // Increment different types
      await db.incrementDailyLimit(limitType: 'lessons', deviceId: deviceId);
      await db.incrementDailyLimit(limitType: 'lessons', deviceId: deviceId);
      await db.incrementDailyLimit(limitType: 'readings', deviceId: deviceId);
      await db.incrementDailyLimit(limitType: 'quizzes', deviceId: deviceId);

      // Check limits
      final limits = await db.getTodayLimits(deviceId: deviceId);
      expect(limits?['lessons_count'], equals(2));
      expect(limits?['readings_count'], equals(1));
      expect(limits?['quizzes_count'], equals(1));
    });

    test('Guest limits are per-device', () async {
      final device1 = 'device-1';
      final device2 = 'device-2';

      // Increment for device 1
      await db.incrementDailyLimit(limitType: 'lessons', deviceId: device1);
      await db.incrementDailyLimit(limitType: 'lessons', deviceId: device1);

      // Increment for device 2
      await db.incrementDailyLimit(limitType: 'lessons', deviceId: device2);

      // Check limits are separate
      final limits1 = await db.getTodayLimits(deviceId: device1);
      final limits2 = await db.getTodayLimits(deviceId: device2);

      expect(limits1?['lessons_count'], equals(2));
      expect(limits2?['lessons_count'], equals(1));
    });

    test('Limits reset daily (date-based)', () async {
      final deviceId = 'test-device-daily';

      // Increment today
      await db.incrementDailyLimit(limitType: 'lessons', deviceId: deviceId);

      final today = DateTime.now().toIso8601String().split('T')[0];
      final todayLimits = await db.getTodayLimits(deviceId: deviceId);
      expect(todayLimits?['limit_date'], equals(today));
      expect(todayLimits?['lessons_count'], equals(1));

      // Note: Testing date reset would require mocking DateTime or database manipulation
      // In real scenario, next day would have no limits for the same device
    });
  });
}
