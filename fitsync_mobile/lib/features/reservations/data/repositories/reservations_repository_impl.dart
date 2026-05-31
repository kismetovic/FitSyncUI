import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_status.dart';
import '../../domain/entities/reservation_type.dart';
import '../../domain/repositories/reservations_repository.dart';
import '../datasources/reservations_remote_data_source.dart';

class ReservationsRepositoryImpl implements ReservationsRepository {
  final ReservationsRemoteDataSource remoteDataSource;

  ReservationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Reservation>>> getMyReservations() async {
    try {
      final result = await remoteDataSource.getMyReservations();
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<List<Reservation>> getReservationsByTraining(int trainingId) async {
    try {
      final result = await remoteDataSource.getReservationsByTraining(trainingId);
      return result;
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
  }) async {
    try {
      final result = await remoteDataSource.createReservation(
        trainingId: trainingId,
        reservationDate: reservationDate,
        reservationType: reservationType,
        additionalServiceIds: additionalServiceIds,
        requestOutsideAvailability: requestOutsideAvailability,
      );
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reservation>> updateReservation(int id, ReservationStatus status) async {
    try {
      final result = await remoteDataSource.updateReservation(id, status);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelReservation(int id) async {
    try {
      await remoteDataSource.cancelReservation(id);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
