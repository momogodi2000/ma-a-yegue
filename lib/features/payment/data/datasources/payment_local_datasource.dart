import 'package:flutter/foundation.dart';
import '../../../../core/database/unified_database_service.dart';
import '../models/payment_model.dart';
import '../models/subscription_model.dart';

/// Payment Local DataSource - Hybrid Architecture
///
/// ✅ Stores ALL payment data in SQLite
/// ✅ Firebase only used for payment processing webhooks/callbacks
abstract class PaymentLocalDataSource {
  Future<PaymentModel> createPayment(PaymentModel payment);
  Future<PaymentModel> getPaymentById(String paymentId);
  Future<List<PaymentModel>> getUserPayments(String userId);
  Future<PaymentModel> updatePaymentStatus(String paymentId, String status);
  Future<void> deletePayment(String paymentId);
  Future<SubscriptionModel> createSubscription(SubscriptionModel subscription);
  Future<SubscriptionModel?> getUserActiveSubscription(String userId);
  Future<List<SubscriptionModel>> getUserSubscriptions(String userId);
}

class PaymentLocalDataSourceImpl implements PaymentLocalDataSource {
  final UnifiedDatabaseService _db = UnifiedDatabaseService.instance;

  @override
  Future<PaymentModel> createPayment(PaymentModel payment) async {
    try {
      await _db.upsertPayment({
        'payment_id': payment.id,
        'user_id': payment.userId,
        'amount': payment.amount,
        'currency': payment.currency,
        'status': payment.status,
        'payment_method': payment.paymentMethod,
        'transaction_id': payment.transactionId,
        'reference': payment.reference,
        'subscription_id': payment.subscriptionId,
        'created_at': payment.createdAt.millisecondsSinceEpoch,
      });

      debugPrint('✅ Payment created in SQLite: ${payment.id}');
      return payment;
    } catch (e) {
      debugPrint('❌ Error creating payment: $e');
      throw Exception('Failed to create payment: $e');
    }
  }

  @override
  Future<PaymentModel> getPaymentById(String paymentId) async {
    try {
      final data = await _db.getPaymentById(paymentId);

      if (data == null) {
        throw Exception('Payment not found');
      }

      return PaymentModel(
        id: data['payment_id'] as String,
        userId: data['user_id'] as String,
        amount: data['amount'] as double,
        currency: data['currency'] as String? ?? 'XAF',
        method: data['payment_method'] as String? ?? 'unknown',
        status: data['status'] as String,
        transactionId: data['transaction_id'] as String?,
        reference: data['reference'] as String?,
        subscriptionId: data['subscription_id'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          data['created_at'] as int,
        ),
        updatedAt: data['updated_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(data['updated_at'] as int)
            : null,
        completedAt: data['completed_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(data['completed_at'] as int)
            : null,
      );
    } catch (e) {
      debugPrint('❌ Error getting payment: $e');
      throw Exception('Failed to get payment: $e');
    }
  }

  @override
  Future<List<PaymentModel>> getUserPayments(String userId) async {
    try {
      final payments = await _db.getUserPayments(userId);

      return payments.map((data) {
        return PaymentModel(
          id: data['payment_id'] as String,
          userId: data['user_id'] as String,
          amount: data['amount'] as double,
          currency: data['currency'] as String? ?? 'XAF',
          method: data['payment_method'] as String? ?? 'unknown',
          status: data['status'] as String,
          transactionId: data['transaction_id'] as String?,
          reference: data['reference'] as String?,
          subscriptionId: data['subscription_id'] as String?,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            data['created_at'] as int,
          ),
          updatedAt: data['updated_at'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['updated_at'] as int)
              : null,
          completedAt: data['completed_at'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['completed_at'] as int)
              : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting user payments: $e');
      return [];
    }
  }

  @override
  Future<PaymentModel> updatePaymentStatus(
    String paymentId,
    String status,
  ) async {
    try {
      await _db.updatePaymentStatus(paymentId: paymentId, status: status);

      return await getPaymentById(paymentId);
    } catch (e) {
      debugPrint('❌ Error updating payment status: $e');
      throw Exception('Failed to update payment status: $e');
    }
  }

  @override
  Future<void> deletePayment(String paymentId) async {
    try {
      final db = await _db.database;
      await db.delete(
        'payments',
        where: 'payment_id = ?',
        whereArgs: [paymentId],
      );

      debugPrint('✅ Payment deleted: $paymentId');
    } catch (e) {
      debugPrint('❌ Error deleting payment: $e');
      throw Exception('Failed to delete payment: $e');
    }
  }

  @override
  Future<SubscriptionModel> createSubscription(
    SubscriptionModel subscription,
  ) async {
    try {
      await _db.upsertSubscription({
        'subscription_id': subscription.id,
        'user_id': subscription.userId,
        'plan_type': subscription.planType,
        'status': subscription.status,
        'start_date': subscription.startDate.millisecondsSinceEpoch,
        'end_date': subscription.endDate.millisecondsSinceEpoch,
        'payment_id': subscription.paymentId,
        'auto_renew': subscription.autoRenew ? 1 : 0,
        'created_at': subscription.createdAt.millisecondsSinceEpoch,
      });

      // Also update user subscription status
      await _db.upsertUser({
        'user_id': subscription.userId,
        'subscription_status': subscription.status,
        'subscription_expires_at': subscription.endDate.millisecondsSinceEpoch,
      });

      debugPrint('✅ Subscription created in SQLite: ${subscription.id}');
      return subscription;
    } catch (e) {
      debugPrint('❌ Error creating subscription: $e');
      throw Exception('Failed to create subscription: $e');
    }
  }

  @override
  Future<SubscriptionModel?> getUserActiveSubscription(String userId) async {
    try {
      final data = await _db.getUserActiveSubscription(userId);

      if (data == null) return null;

      final planType = data['plan_type'] as String;
      return SubscriptionModel(
        id: data['subscription_id'] as String,
        userId: data['user_id'] as String,
        planId: planType,
        planName: planType,
        planType: planType,
        price: 0.0, // Default, should be updated with actual price
        currency: 'XAF',
        interval: 'monthly',
        status: data['status'] as String,
        startDate: DateTime.fromMillisecondsSinceEpoch(
          data['start_date'] as int,
        ),
        endDate: DateTime.fromMillisecondsSinceEpoch(data['end_date'] as int),
        paymentId: data['payment_id'] as String?,
        autoRenew: (data['auto_renew'] as int) == 1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          data['created_at'] as int,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error getting active subscription: $e');
      return null;
    }
  }

  @override
  Future<List<SubscriptionModel>> getUserSubscriptions(String userId) async {
    try {
      final db = await _db.database;
      final subscriptions = await db.query(
        'subscriptions',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return subscriptions.map((data) {
        final planType = data['plan_type'] as String;
        return SubscriptionModel(
          id: data['subscription_id'] as String,
          userId: data['user_id'] as String,
          planId: planType,
          planName: planType,
          planType: planType,
          price: 0.0, // Default, should be updated with actual price
          currency: 'XAF',
          interval: 'monthly',
          status: data['status'] as String,
          startDate: DateTime.fromMillisecondsSinceEpoch(
            data['start_date'] as int,
          ),
          endDate: DateTime.fromMillisecondsSinceEpoch(data['end_date'] as int),
          paymentId: data['payment_id'] as String?,
          autoRenew: (data['auto_renew'] as int) == 1,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            data['created_at'] as int,
          ),
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting user subscriptions: $e');
      return [];
    }
  }
}
