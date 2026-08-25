import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/reservation.dart';
import '../repositories/reservations_repository.dart';

class CompleteReservationParams extends Equatable {
  final int id;
  final String? note;

  const CompleteReservationParams({required this.id, this.note});

  @override
  List<Object?> get props => [id, note];
}

/// Marks an attended training as completed, which is also what unlocks reviewing it.
class CompleteReservation {
  final ReservationsRepository repository;

  CompleteReservation(this.repository);

  Future<Either<Failure, Reservation>> call(CompleteReservationParams params) =>
      repository.completeReservation(params.id, note: params.note);
}
