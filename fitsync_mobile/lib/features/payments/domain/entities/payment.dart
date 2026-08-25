import 'package:equatable/equatable.dart';

enum PaymentProvider { paypal, cash }

/// Mirrors the backend PaymentStatus enum. A payment only counts once it is captured;
/// pending and failed attempts leave the reservation unpaid.
enum PaymentStatus {
  pending,
  captured,
  failed,
  refunded;

  static PaymentStatus fromIndex(int index) =>
      index >= 0 && index < PaymentStatus.values.length ? PaymentStatus.values[index] : PaymentStatus.pending;
}

class Payment extends Equatable {
  final int id;
  final double amount;
  final String transactionId;
  final String? providerOrderId;
  final String currency;
  final PaymentProvider paymentProvider;
  final PaymentStatus status;
  /// Null when the payment settles a bought package rather than a booking.
  final int? reservationId;

  final int? userMembershipId;

  /// What was paid for: the training for a booking, the package for a purchase.
  /// Exactly one of these is set.
  final String? trainingName;
  final String? membershipPackageName;

  /// One line naming what this payment was for, whichever kind it is.
  String get subject => trainingName ?? membershipPackageName ?? '';
  final DateTime createdAt;
  final DateTime? capturedAt;
  final String? failureReason;

  const Payment({
    required this.id,
    required this.amount,
    required this.transactionId,
    required this.currency,
    required this.paymentProvider,
    required this.status,
    this.reservationId,
    this.userMembershipId,
    this.trainingName,
    this.membershipPackageName,
    required this.createdAt,
    this.providerOrderId,
    this.capturedAt,
    this.failureReason,
  });

  bool get isCaptured => status == PaymentStatus.captured;

  /// True while a cash payment is waiting for staff to confirm it at the desk.
  bool get isAwaitingCashConfirmation =>
      paymentProvider == PaymentProvider.cash && status == PaymentStatus.pending;

  @override
  List<Object?> get props =>
      [id, amount, transactionId, currency, paymentProvider, status, reservationId,
       userMembershipId, trainingName, membershipPackageName, createdAt];
}
