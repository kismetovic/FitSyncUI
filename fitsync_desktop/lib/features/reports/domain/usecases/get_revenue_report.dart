import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/revenue_report.dart';
import '../repositories/reports_repository.dart';
import 'get_reservation_report.dart';

class GetRevenueReport {
  final ReportsRepository repository;

  GetRevenueReport(this.repository);

  Future<Either<Failure, RevenueReport>> call(ReportPeriodParams params) =>
      repository.getRevenueReport(from: params.from, to: params.to);
}
