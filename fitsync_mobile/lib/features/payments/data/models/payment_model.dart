import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.amount,
    required super.transactionId,
    required super.currency,
    required super.paymentProvider,
    required super.status,
    super.reservationId,
    super.userMembershipId,
    super.trainingName,
    super.membershipPackageName,
    required super.createdAt,
    super.providerOrderId,
    super.capturedAt,
    super.failureReason,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final providerIndex = json['paymentProvider'] as int? ?? 0;
    return PaymentModel(
      id: json['id'] ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      transactionId: json['transactionId'] ?? '',
      providerOrderId: json['providerOrderId'],
      currency: json['currency'] ?? 'BAM',
      paymentProvider: providerIndex >= 0 && providerIndex < PaymentProvider.values.length
          ? PaymentProvider.values[providerIndex]
          : PaymentProvider.paypal,
      status: PaymentStatus.fromIndex(json['status'] as int? ?? 0),
      reservationId: json['reservationId'] as int?,
      userMembershipId: json['userMembershipId'] as int?,
      trainingName: json['trainingName']?.toString(),
      membershipPackageName: json['membershipPackageName']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      capturedAt: DateTime.tryParse(json['capturedAt']?.toString() ?? ''),
      failureReason: json['failureReason'],
    );
  }
}
