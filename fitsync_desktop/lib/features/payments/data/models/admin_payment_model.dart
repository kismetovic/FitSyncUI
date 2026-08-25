import '../../domain/entities/admin_payment.dart';

class AdminPaymentModel extends AdminPayment {
  const AdminPaymentModel({
    required super.id,
    required super.createdAt,
    required super.amount,
    required super.transactionId,
    required super.currency,
    required super.paymentProvider,
    super.reservationId,
    super.userMembershipId,
    super.userName,
    super.userEmail,
    super.trainingName,
    super.membershipPackageName,
  });

  factory AdminPaymentModel.fromJson(Map<String, dynamic> json) => AdminPaymentModel(
    id: json['id'] as int,
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    transactionId: json['transactionId'] as String? ?? '',
    currency: json['currency'] as String? ?? 'BAM',
    paymentProvider: json['paymentProvider'] as int? ?? 1,
    reservationId: json['reservationId'] as int?,
    userMembershipId: json['userMembershipId'] as int?,
    userName: json['userName'] as String?,
    userEmail: json['userEmail'] as String?,
    trainingName: json['trainingName'] as String?,
    membershipPackageName: json['membershipPackageName'] as String?,
  );
}
