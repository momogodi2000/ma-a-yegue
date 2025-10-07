import 'package:uuid/uuid.dart'; // ignore: depend_on_referenced_packages
import '../../../../core/services/firebase_service.dart';
import '../../../../core/database/unified_database_service.dart';
import '../../../../core/constants/payment_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/payment_model.dart';
import '../models/subscription_model.dart';
import 'campay_datasource.dart';
import 'noupai_datasource.dart';
import 'stripe_datasource.dart';

/// Remote data source for payment operations
abstract class PaymentRemoteDataSource {
  Future<PaymentModel> initiatePayment({
    required String userId,
    required double amount,
    required String method,
    required String phoneNumber,
    required String description,
  });

  Future<PaymentModel> getPaymentById(String paymentId);

  Future<List<PaymentModel>> getUserPayments(String userId);

  Future<PaymentModel> updatePaymentStatus(String paymentId, String status);

  Future<SubscriptionModel> createSubscription({
    required String userId,
    required String planId,
    required String planName,
    required double price,
    required String interval,
  });

  Future<SubscriptionModel?> getUserSubscription(String userId);

  Future<SubscriptionModel> updateSubscriptionStatus(
    String subscriptionId,
    String status,
  );

  Future<List<Map<String, dynamic>>> getSubscriptionPlans();
}

/// Hybrid implementation of PaymentRemoteDataSource
/// Uses SQLite for data storage, Firebase for services
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final FirebaseService firebaseService;
  final UnifiedDatabaseService _db = UnifiedDatabaseService.instance;
  final CamPayDataSourceImpl camPayDataSource;
  final NouPaiDataSourceImpl nouPaiDataSource;
  final DioClient dioClient;

  PaymentRemoteDataSourceImpl({
    required this.firebaseService,
    required this.camPayDataSource,
    required this.nouPaiDataSource,
    required this.dioClient,
  });

  @override
  Future<PaymentModel> initiatePayment({
    required String userId,
    required double amount,
    required String method,
    required String phoneNumber,
    required String description,
  }) async {
    try {
      // Generate payment ID
      final paymentId = const Uuid().v4();

      // Route to appropriate payment provider based on method
      Map<String, dynamic> paymentResponse;
      switch (method) {
        case 'campay':
          paymentResponse = await camPayDataSource.initiatePayment(
            phoneNumber: phoneNumber,
            amount: amount,
            description: description,
            externalReference: paymentId,
          );
          break;
        case 'noupai':
          paymentResponse = await nouPaiDataSource.initiatePayment(
            phoneNumber: phoneNumber,
            amount: amount,
            description: description,
            externalReference: paymentId,
          );
          break;
        case 'stripe':
          // For Stripe, we don't need phone number, use USD currency
          paymentResponse = await StripeDataSourceImpl(dioClient)
              .initiatePayment(
                phoneNumber: '', // Not needed for Stripe
                amount: amount,
                description: description,
                externalReference: paymentId,
                currency: 'USD',
              );
          break;
        default:
          throw Exception('Unsupported payment method: $method');
      }

      // Create payment record
      final payment = PaymentModel(
        id: paymentId,
        userId: userId,
        amount: amount,
        currency: 'XAF',
        method: method,
        status: 'pending',
        transactionId: paymentResponse['transaction_id'],
        reference: paymentResponse['reference'],
        createdAt: DateTime.now(),
      );

      // Save to SQLite (HYBRID ARCHITECTURE)
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

      return payment;
    } catch (e) {
      throw Exception('Payment initiation failed: $e');
    }
  }

  @override
  Future<PaymentModel> getPaymentById(String paymentId) async {
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
        data['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: data['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updated_at'] as int)
          : null,
      completedAt: data['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['completed_at'] as int)
          : null,
    );
  }

  @override
  Future<List<PaymentModel>> getUserPayments(String userId) async {
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
          data['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        ),
        updatedAt: data['updated_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(data['updated_at'] as int)
            : null,
        completedAt: data['completed_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(data['completed_at'] as int)
            : null,
      );
    }).toList();
  }

  @override
  Future<PaymentModel> updatePaymentStatus(
    String paymentId,
    String status,
  ) async {
    await _db.updatePaymentStatus(paymentId: paymentId, status: status);

    return getPaymentById(paymentId);
  }

  @override
  Future<SubscriptionModel> createSubscription({
    required String userId,
    required String planId,
    required String planName,
    required double price,
    required String interval,
  }) async {
    final subscriptionId = const Uuid().v4();

    final endDate = interval == 'monthly'
        ? DateTime.now().add(const Duration(days: 30))
        : DateTime.now().add(const Duration(days: 365));

    final subscription = SubscriptionModel(
      id: subscriptionId,
      userId: userId,
      planId: planId,
      planName: planName,
      price: price,
      currency: 'XAF',
      interval: interval,
      status: 'active',
      startDate: DateTime.now(),
      endDate: endDate,
      autoRenew: true,
    );

    await _db.upsertSubscription({
      'subscription_id': subscription.id,
      'user_id': subscription.userId,
      'plan_type': subscription.planName,
      'status': subscription.status,
      'start_date': subscription.startDate.millisecondsSinceEpoch,
      'end_date': subscription.endDate.millisecondsSinceEpoch,
      'auto_renew': subscription.autoRenew ? 1 : 0,
    });

    return subscription;
  }

  @override
  Future<SubscriptionModel?> getUserSubscription(String userId) async {
    final data = await _db.getUserActiveSubscription(userId);

    if (data == null) {
      return null;
    }

    return SubscriptionModel(
      id: data['subscription_id'] as String,
      userId: data['user_id'] as String,
      planId: data['plan_type'] as String,
      planName: data['plan_type'] as String,
      price: 0.0, // Would need to store in DB if needed
      currency: 'XAF',
      interval: 'monthly', // Would need to store in DB if needed
      status: data['status'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(data['start_date'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(data['end_date'] as int),
      autoRenew: (data['auto_renew'] as int) == 1,
    );
  }

  @override
  Future<SubscriptionModel> updateSubscriptionStatus(
    String subscriptionId,
    String status,
  ) async {
    final db = await _db.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'subscriptions',
      {'status': status, 'updated_at': now},
      where: 'subscription_id = ?',
      whereArgs: [subscriptionId],
    );

    final data = await db.query(
      'subscriptions',
      where: 'subscription_id = ?',
      whereArgs: [subscriptionId],
      limit: 1,
    );

    if (data.isEmpty) {
      throw Exception('Subscription not found');
    }

    final sub = data.first;
    return SubscriptionModel(
      id: sub['subscription_id'] as String,
      userId: sub['user_id'] as String,
      planId: sub['plan_type'] as String,
      planName: sub['plan_type'] as String,
      price: 0.0,
      currency: 'XAF',
      interval: 'monthly',
      status: sub['status'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(sub['start_date'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(sub['end_date'] as int),
      autoRenew: (sub['auto_renew'] as int) == 1,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    // Return hardcoded plans (could be fetched from Firestore)
    return [
      PaymentConstants.freemiumPlan,
      PaymentConstants.premiumMonthlyPlan,
      PaymentConstants.premiumAnnualPlan,
      PaymentConstants.teacherPlan,
    ];
  }
}
