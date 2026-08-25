import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/reservation.dart';
import '../../../../core/pagination/paged_result.dart';
import '../../domain/repositories/reservations_repository.dart';
import '../datasources/reservations_remote_data_source.dart';

class ReservationsRepositoryImpl implements ReservationsRepository {
  final ReservationsRemoteDataSource remoteDataSource;

  ReservationsRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PagedResult<Reservation>>> getReservations({
    int page = 1,
    int pageSize = kDefaultPageSize,
    String? query,
  }) =>
      _guard(() async {
        final result = await remoteDataSource.getReservations(
            page: page, pageSize: pageSize, query: query);
        return PagedResult<Reservation>(
          items: result.items,
          page: result.page,
          pageSize: result.pageSize,
          totalCount: result.totalCount,
        );
      });

  @override
  Future<Either<Failure, Reservation>> approveReservation(int id) =>
      _guard(() async => await remoteDataSource.approveReservation(id));

  @override
  Future<Either<Failure, Reservation>> completeReservation(int id, {String? note}) =>
      _guard(() async => await remoteDataSource.completeReservation(id, note: note));

  @override
  Future<Either<Failure, Reservation>> cancelReservation(int id, String reason) =>
      _guard(() async => await remoteDataSource.cancelReservation(id, reason));

  @override
  Future<Either<Failure, void>> confirmCashPayment(int reservationId, {String? note}) =>
      _guard(() async => await remoteDataSource.confirmCashPayment(reservationId, note: note));
}
