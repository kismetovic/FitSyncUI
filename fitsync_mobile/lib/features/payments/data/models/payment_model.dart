import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.amount,
    required super.transactionId,
    required super.currency,
    required super.paymentProvider,
    required super.reservationId,
    required super.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      transactionId: json['transactionId'] ?? '',
      currency: json['currency'] ?? 'USD',
      paymentProvider: PaymentProvider.values[json['paymentProvider'] ?? 2],
      reservationId: json['reservationId'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
