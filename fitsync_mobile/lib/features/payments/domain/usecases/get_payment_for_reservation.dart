import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

/// The payment already recorded against a reservation, if there is one.
///
/// Used when the payment screen opens to spot a PayPal order that was started
/// but never finished, so the server can be asked to settle it instead of the
/// booking sitting unpaid forever.
class GetPaymentForReservation implements UseCase<Payment?, int> {
  final PaymentsRepository repository;

  GetPaymentForReservation(this.repository);

  /// [params] is the reservation id.
  @override
  Future<Either<Failure, Payment?>> call(int params) async {
    try {
      return Right(await repository.getPaymentForReservation(params));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
