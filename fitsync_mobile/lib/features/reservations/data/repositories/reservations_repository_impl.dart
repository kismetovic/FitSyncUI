import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_type.dart';
import '../../domain/entities/slot_availability.dart';
import '../../domain/repositories/reservations_repository.dart';
import '../datasources/reservations_remote_data_source.dart';

class ReservationsRepositoryImpl implements ReservationsRepository {
  final ReservationsRemoteDataSource remoteDataSource;

  ReservationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Reservation>>> getMyReservations() async {
    try {
      return Right(await remoteDataSource.getMyReservations());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<List<SlotAvailability>> getTrainingAvailability(int trainingId, {int days = 14}) async {
    try {
      return await remoteDataSource.getTrainingAvailability(trainingId, days: days);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Either<Failure, Reservation>> createReservation({
    required int trainingId,
    required DateTime reservationDate,
    required ReservationType reservationType,
    List<int> additionalServiceIds = const [],
    bool requestOutsideAvailability = false,
    int? userMembershipId,
  }) async {
    try {
      return Right(await remoteDataSource.createReservation(
        trainingId: trainingId,
        reservationDate: reservationDate,
        reservationType: reservationType,
        additionalServiceIds: additionalServiceIds,
        requestOutsideAvailability: requestOutsideAvailability,
        userMembershipId: userMembershipId,
      ));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reservation>> cancelReservation(int id, String reason) async {
    try {
      return Right(await remoteDataSource.cancelReservation(id, reason));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
