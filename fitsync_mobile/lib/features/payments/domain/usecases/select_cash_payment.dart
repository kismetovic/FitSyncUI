import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

/// Records that the user wants to pay on arrival. This does not confirm the payment:
/// only gym staff can mark cash as received.
class SelectCashPayment {
  final PaymentsRepository repository;

  SelectCashPayment(this.repository);

  Future<Either<Failure, Payment>> call(int reservationId) =>
      repository.selectCashPayment(reservationId: reservationId);
}
