import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

class ConfirmCashPaymentParams extends Equatable {
  final double amount;
  final int reservationId;

  const ConfirmCashPaymentParams({required this.amount, required this.reservationId});

  @override
  List<Object?> get props => [amount, reservationId];
}

class ConfirmCashPayment implements UseCase<Payment, ConfirmCashPaymentParams> {
  final PaymentsRepository repository;

  ConfirmCashPayment(this.repository);

  @override
  Future<Either<Failure, Payment>> call(ConfirmCashPaymentParams params) async {
    return await repository.confirmCashPayment(
      amount: params.amount,
      reservationId: params.reservationId,
    );
  }
}
