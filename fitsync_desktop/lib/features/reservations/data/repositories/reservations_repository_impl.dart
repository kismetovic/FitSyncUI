import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_status.dart';
import '../../domain/repositories/reservations_repository.dart';
import '../datasources/reservations_remote_data_source.dart';

class ReservationsRepositoryImpl implements ReservationsRepository {
  final ReservationsRemoteDataSource remoteDataSource;

  ReservationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Reservation>>> getReservations() async {
    try {
      final result = await remoteDataSource.getReservations();
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Reservation>> updateReservationStatus(int id, ReservationStatus status) async {
    try {
      final result = await remoteDataSource.updateReservation(id, status);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Reservation>> approveReservation(int id) async {
    try {
      final result = await remoteDataSource.approveReservation(id);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteReservation(int id) async {
    try {
      await remoteDataSource.deleteReservation(id);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    }
  }
}
