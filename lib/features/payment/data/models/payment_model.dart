import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_entity.dart';

/// Payment model for data layer
class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.currency,
    required super.method,
    required super.status,
    super.transactionId,
    super.reference,
    super.subscriptionId,
    required super.createdAt,
    super.updatedAt,
    super.completedAt,
    super.failureReason,
  });

  /// Create from Firestore document
  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'XAF',
      method: data['method'] ?? '',
      status: data['status'] ?? 'pending',
      transactionId: data['transactionId'],
      reference: data['reference'],
      subscriptionId: data['subscriptionId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      failureReason: data['failureReason'],
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'method': method,
      'status': status,
      'transactionId': transactionId,
      'reference': reference,
      'subscriptionId': subscriptionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'failureReason': failureReason,
    };
  }

  /// Create from entity
  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      userId: entity.userId,
      amount: entity.amount,
      currency: entity.currency,
      method: entity.method,
      status: entity.status,
      transactionId: entity.transactionId,
      reference: entity.reference,
      subscriptionId: entity.subscriptionId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      completedAt: entity.completedAt,
      failureReason: entity.failureReason,
    );
  }

  /// Getter for backward compatibility with local datasource
  String? get paymentMethod => method;
}
