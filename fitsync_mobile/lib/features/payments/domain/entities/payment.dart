import 'package:equatable/equatable.dart';

enum PaymentProvider { paypal, cash }

class Payment extends Equatable {
  final int id;
  final double amount;
  final String transactionId;
  final String currency;
  final PaymentProvider paymentProvider;
  final int reservationId;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.amount,
    required this.transactionId,
    required this.currency,
    required this.paymentProvider,
    required this.reservationId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, amount, transactionId, currency, paymentProvider, reservationId, createdAt];
}
