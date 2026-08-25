import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/reservation.dart';
import '../entities/reservation_type.dart';
import '../entities/slot_availability.dart';

abstract class ReservationsRepository {
  Future<Either<Failure, List<Reservation>>> getMyReservations();

  Future<List<SlotAvailability>> getTrainingAvailability(int trainingId, {int days});

  Future<Either<Failure, Reservation>> createReservation({
    required int trainingId,
    required DateTime reservationDate,
    required ReservationType reservationType,
    List<int> additionalServiceIds,
    bool requestOutsideAvailability,
    int? userMembershipId,
  });

  Future<Either<Failure, Reservation>> cancelReservation(int id, String reason);
}
