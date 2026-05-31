import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_status.dart';

abstract class ReservationsRepository {
  Future<Either<Failure, List<Reservation>>> getReservations();
  Future<Either<Failure, Reservation>> updateReservationStatus(int id, ReservationStatus status);
  Future<Either<Failure, Reservation>> approveReservation(int id);
  Future<Either<Failure, void>> deleteReservation(int id);
}
