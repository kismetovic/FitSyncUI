import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

class ConfirmPaymentParams extends Equatable {
  final double amount;
  final String transactionId;
  final PaymentProvider paymentProvider;
  final int reservationId;
  final String currency;

  const ConfirmPaymentParams({
    required this.amount,
    required this.transactionId,
    required this.paymentProvider,
    required this.reservationId,
    this.currency = 'USD',
  });

  @override
  List<Object?> get props => [amount, transactionId, paymentProvider, reservationId, currency];
}

class ConfirmPayment implements UseCase<Payment, ConfirmPaymentParams> {
  final PaymentsRepository repository;

  ConfirmPayment(this.repository);

  @override
  Future<Either<Failure, Payment>> call(ConfirmPaymentParams params) async {
    return await repository.confirmPayment(
      amount: params.amount,
      transactionId: params.transactionId,
      paymentProvider: params.paymentProvider,
      reservationId: params.reservationId,
      currency: params.currency,
    );
  }
}
