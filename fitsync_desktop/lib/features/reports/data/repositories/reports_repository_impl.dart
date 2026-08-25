import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/reservation_report.dart';
import '../../domain/entities/revenue_report.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_data_source.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ReservationReport>> getReservationReport({
    required DateTime from,
    required DateTime to,
    int? trainingId,
  }) async {
    try {
      return Right(await remoteDataSource.getReservationReport(
        from: from,
        to: to,
        trainingId: trainingId,
      ));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RevenueReport>> getRevenueReport({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      return Right(await remoteDataSource.getRevenueReport(from: from, to: to));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
