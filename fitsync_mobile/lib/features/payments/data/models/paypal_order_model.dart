import '../../domain/entities/paypal_order.dart';

class PayPalOrderModel extends PayPalOrder {
  const PayPalOrderModel({
    required super.orderId,
    required super.approvalUrl,
    required super.amount,
    required super.currency,
    required super.chargedAmount,
    required super.chargedCurrency,
    required super.reservationId,
  });

  factory PayPalOrderModel.fromJson(Map<String, dynamic> json) => PayPalOrderModel(
        orderId: json['orderId']?.toString() ?? '',
        approvalUrl: json['approvalUrl']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency']?.toString() ?? 'BAM',
        chargedAmount: (json['chargedAmount'] as num?)?.toDouble() ?? 0.0,
        chargedCurrency: json['chargedCurrency']?.toString() ?? 'EUR',
        reservationId: json['reservationId'] as int? ?? 0,
      );
}

class PayPalCaptureModel extends PayPalCapture {
  const PayPalCaptureModel({
    required super.transactionId,
    required super.status,
    required super.amount,
    required super.currency,
    required super.reservationId,
    required super.reservationStatus,
  });

  factory PayPalCaptureModel.fromJson(Map<String, dynamic> json) => PayPalCaptureModel(
        transactionId: json['transactionId']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency']?.toString() ?? 'EUR',
        reservationId: json['reservationId'] as int? ?? 0,
        reservationStatus: json['reservationStatus'] as int? ?? 0,
      );
}
