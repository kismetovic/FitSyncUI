import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/reservation.dart';
import '../../../../core/pagination/paged_result.dart';

abstract class ReservationsRepository {
  Future<Either<Failure, PagedResult<Reservation>>> getReservations({int page, int pageSize, String? query});
  Future<Either<Failure, Reservation>> approveReservation(int id);
  Future<Either<Failure, Reservation>> completeReservation(int id, {String? note});
  Future<Either<Failure, Reservation>> cancelReservation(int id, String reason);
  Future<Either<Failure, void>> confirmCashPayment(int reservationId, {String? note});
}
