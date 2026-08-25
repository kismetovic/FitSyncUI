import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reservation.dart';
import '../repositories/reservations_repository.dart';

class CancelReservationParams extends Equatable {
  final int id;
  final String reason;

  const CancelReservationParams({required this.id, required this.reason});

  @override
  List<Object?> get props => [id, reason];
}

/// Cancels through the dedicated endpoint with a reason. The reservation remains in
/// the user's history marked as cancelled instead of disappearing.
class CancelReservation implements UseCase<Reservation, CancelReservationParams> {
  final ReservationsRepository repository;

  CancelReservation(this.repository);

  @override
  Future<Either<Failure, Reservation>> call(CancelReservationParams params) =>
      repository.cancelReservation(params.id, params.reason);
}
