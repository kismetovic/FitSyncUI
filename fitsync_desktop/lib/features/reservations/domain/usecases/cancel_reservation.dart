import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/reservation.dart';
import '../repositories/reservations_repository.dart';

class CancelReservationParams extends Equatable {
  final int id;
  final String reason;

  const CancelReservationParams({required this.id, required this.reason});

  @override
  List<Object?> get props => [id, reason];
}

/// Cancels with a reason. Replaces the previous delete action: the reservation stays
/// in the system as cancelled, with who cancelled it and why.
class CancelReservation {
  final ReservationsRepository repository;

  CancelReservation(this.repository);

  Future<Either<Failure, Reservation>> call(CancelReservationParams params) =>
      repository.cancelReservation(params.id, params.reason);
}
