import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/reservation.dart';
import '../entities/reservation_status.dart';
import '../entities/reservation_type.dart';

abstract class ReservationsRepository {
  Future<Either<Failure, List<Reservation>>> getMyReservations();
  Future<List<Reservation>> getReservationsByTraining(int trainingId);
  Future<Either<Failure, Reservation>> createReservation({
    required int trainingId,
    required DateTime reservationDate,
    required ReservationType reservationType,
    List<int> additionalServiceIds,
    bool requestOutsideAvailability,
  });
  Future<Either<Failure, Reservation>> updateReservation(int id, ReservationStatus status);
  Future<Either<Failure, void>> cancelReservation(int id);
}
