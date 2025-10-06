import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
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
      String subscriptionId, String status);

  Future<List<Map<String, dynamic>>> getSubscriptionPlans();
}

/// Firebase implementation of PaymentRemoteDataSource
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final FirebaseService firebaseService;
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
      final paymentId =
          FirebaseFirestore.instance.collection('payments').doc().id;

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
          paymentResponse = await StripeDataSourceImpl(dioClient).initiatePayment(
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

      // Save to Firestore
      await firebaseService.firestore
          .collection('payments')
          .doc(paymentId)
          .set(payment.toFirestore());

      return payment;
    } catch (e) {
      throw Exception('Payment initiation failed: $e');
    }
  }

  @override
  Future<PaymentModel> getPaymentById(String paymentId) async {
    final doc = await firebaseService.firestore
        .collection('payments')
        .doc(paymentId)
        .get();

    if (!doc.exists) {
      throw Exception('Payment not found');
    }

    return PaymentModel.fromFirestore(doc);
  }

  @override
  Future<List<PaymentModel>> getUserPayments(String userId) async {
    final querySnapshot = await firebaseService.firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => PaymentModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<PaymentModel> updatePaymentStatus(
      String paymentId, String status) async {
    await firebaseService.firestore
        .collection('payments')
        .doc(paymentId)
        .update({
      'status': status,
      'completedAt': status == 'completed' ? Timestamp.now() : null,
    });

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
    final subscriptionId =
        FirebaseFirestore.instance.collection('subscriptions').doc().id;

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

    await firebaseService.firestore
        .collection('subscriptions')
        .doc(subscriptionId)
        .set(subscription.toFirestore());

    return subscription;
  }

  @override
  Future<SubscriptionModel?> getUserSubscription(String userId) async {
    final querySnapshot = await firebaseService.firestore
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .orderBy('endDate', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    return SubscriptionModel.fromFirestore(querySnapshot.docs.first);
  }

  @override
  Future<SubscriptionModel> updateSubscriptionStatus(
      String subscriptionId, String status) async {
    final updateData = {
      'status': status,
      if (status == 'cancelled') 'cancelledAt': Timestamp.now(),
    };

    await firebaseService.firestore
        .collection('subscriptions')
        .doc(subscriptionId)
        .update(updateData);

    final doc = await firebaseService.firestore
        .collection('subscriptions')
        .doc(subscriptionId)
        .get();

    return SubscriptionModel.fromFirestore(doc);
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
