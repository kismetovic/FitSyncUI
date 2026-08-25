import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/reservations_repository.dart';

class ConfirmCashPaymentParams extends Equatable {
  final int reservationId;
  final String? note;

  const ConfirmCashPaymentParams({required this.reservationId, this.note});

  @override
  List<Object?> get props => [reservationId, note];
}

/// Records that a client paid cash at the desk. Only staff can do this, and it is
/// what actually moves the reservation to Paid.
class ConfirmCashPayment {
  final ReservationsRepository repository;

  ConfirmCashPayment(this.repository);

  Future<Either<Failure, void>> call(ConfirmCashPaymentParams params) =>
      repository.confirmCashPayment(params.reservationId, note: params.note);
}
