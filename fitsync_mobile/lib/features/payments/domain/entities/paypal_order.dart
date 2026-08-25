import 'package:equatable/equatable.dart';

/// A PayPal order opened by the backend. The amount is server-calculated and shown
/// to the user for confirmation only; the app never sends a price of its own.
class PayPalOrder extends Equatable {
  final String orderId;

  /// Official PayPal approval URL. The user completes payment on PayPal's own page,
  /// which is why the app has no business asking for a PayPal password.
  final String approvalUrl;

  final double amount;
  final String currency;

  /// What PayPal will actually take. The gym prices in BAM, which PayPal cannot
  /// charge, so the order is placed in the pegged euro equivalent - showing this
  /// avoids the user meeting a different number on the PayPal page.
  final double chargedAmount;
  final String chargedCurrency;

  final int reservationId;

  const PayPalOrder({
    required this.orderId,
    required this.approvalUrl,
    required this.amount,
    required this.currency,
    required this.chargedAmount,
    required this.chargedCurrency,
    required this.reservationId,
  });

  @override
  List<Object?> get props =>
      [orderId, approvalUrl, amount, currency, chargedAmount, chargedCurrency, reservationId];
}

/// Result of the backend capturing and verifying the order with PayPal.
class PayPalCapture extends Equatable {
  final String transactionId;
  final String status;
  final double amount;
  final String currency;
  final int reservationId;

  /// Reservation status after the capture, as decided by the server.
  final int reservationStatus;

  const PayPalCapture({
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.reservationId,
    required this.reservationStatus,
  });

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';

  @override
  List<Object?> get props => [transactionId, status, amount, currency, reservationId, reservationStatus];
}
