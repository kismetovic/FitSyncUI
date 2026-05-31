class AdminPayment {
  final int id;
  final DateTime createdAt;
  final double amount;
  final String transactionId;
  final String currency;
  final int paymentProvider;
  final int reservationId;
  final String? userName;
  final String? userEmail;
  final String? trainingName;

  const AdminPayment({
    required this.id,
    required this.createdAt,
    required this.amount,
    required this.transactionId,
    required this.currency,
    required this.paymentProvider,
    required this.reservationId,
    this.userName,
    this.userEmail,
    this.trainingName,
  });

  String get providerLabel => paymentProvider == 0 ? 'PayPal' : 'Gotovina';
}
