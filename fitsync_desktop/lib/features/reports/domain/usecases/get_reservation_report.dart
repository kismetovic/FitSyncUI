import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/reservation_report.dart';
import '../repositories/reports_repository.dart';

class ReportPeriodParams extends Equatable {
  final DateTime from;
  final DateTime to;
  final int? trainingId;

  const ReportPeriodParams({required this.from, required this.to, this.trainingId});

  @override
  List<Object?> get props => [from, to, trainingId];
}

class GetReservationReport {
  final ReportsRepository repository;

  GetReservationReport(this.repository);

  Future<Either<Failure, ReservationReport>> call(ReportPeriodParams params) =>
      repository.getReservationReport(from: params.from, to: params.to, trainingId: params.trainingId);
}
