import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/reservation.dart';
import '../repositories/reservations_repository.dart';

/// Trainer/administrator approves a request that was waiting for approval.
class ApproveReservation {
  final ReservationsRepository repository;

  ApproveReservation(this.repository);

  Future<Either<Failure, Reservation>> call(int id) => repository.approveReservation(id);
}
