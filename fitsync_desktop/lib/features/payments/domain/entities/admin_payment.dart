class AdminPayment {
  final int id;
  final DateTime createdAt;
  final double amount;
  final String transactionId;
  final String currency;
  final int paymentProvider;
  /// Null when the payment settles a bought package rather than a booking.
  final int? reservationId;

  final int? userMembershipId;
  final String? userName;
  final String? userEmail;
  final String? trainingName;

  /// Set instead of [trainingName] when a package was paid for.
  final String? membershipPackageName;

  const AdminPayment({
    required this.id,
    required this.createdAt,
    required this.amount,
    required this.transactionId,
    required this.currency,
    required this.paymentProvider,
    this.reservationId,
    this.userMembershipId,
    this.userName,
    this.userEmail,
    this.trainingName,
    this.membershipPackageName,
  });

  String get providerLabel => paymentProvider == 0 ? 'PayPal' : 'Gotovina';
}
