/// Subscription entity representing user subscriptions
class SubscriptionEntity {
  final String id;
  final String userId;
  final String planId;
  final String planName;
  final String planType; // Alias for planId for database compatibility
  final double price;
  final String currency;
  final String interval; // 'monthly', 'yearly'
  final String status; // 'active', 'cancelled', 'expired', 'pending'
  final DateTime startDate;
  final DateTime endDate;
  final String? paymentId;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final bool autoRenew;

  const SubscriptionEntity({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    String? planType,
    required this.price,
    required this.currency,
    required this.interval,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.paymentId,
    DateTime? createdAt,
    this.cancelledAt,
    this.autoRenew = true,
  }) : planType = planType ?? planId,
       createdAt = createdAt ?? startDate;

  SubscriptionEntity copyWith({
    String? id,
    String? userId,
    String? planId,
    String? planName,
    String? planType,
    double? price,
    String? currency,
    String? interval,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? paymentId,
    DateTime? createdAt,
    DateTime? cancelledAt,
    bool? autoRenew,
  }) {
    return SubscriptionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      planType: planType ?? this.planType,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      interval: interval ?? this.interval,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentId: paymentId ?? this.paymentId,
      createdAt: createdAt ?? this.createdAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      autoRenew: autoRenew ?? this.autoRenew,
    );
  }

  bool get isActive => status == 'active' && endDate.isAfter(DateTime.now());
  bool get isExpired => endDate.isBefore(DateTime.now());

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'planId': planId,
      'planName': planName,
      'planType': planType,
      'price': price,
      'currency': currency,
      'interval': interval,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'paymentId': paymentId,
      'createdAt': createdAt.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'autoRenew': autoRenew,
    };
  }
}
