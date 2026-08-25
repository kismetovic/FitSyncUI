import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/reservation_report.dart';
import '../entities/revenue_report.dart';

abstract class ReportsRepository {
  Future<Either<Failure, ReservationReport>> getReservationReport({
    required DateTime from,
    required DateTime to,
    int? trainingId,
  });

  Future<Either<Failure, RevenueReport>> getRevenueReport({
    required DateTime from,
    required DateTime to,
  });
}
