import 'package:equatable/equatable.dart';

/// Reservation statuses, mirroring the backend enum.
enum ReportReservationStatus {
  initial,
  approved,
  paid,
  cancelled,
  completed,
  pendingApproval;

  static ReportReservationStatus fromIndex(int index) =>
      index >= 0 && index < ReportReservationStatus.values.length
          ? ReportReservationStatus.values[index]
          : ReportReservationStatus.initial;

  String get label => switch (this) {
        ReportReservationStatus.initial => 'Kreirana',
        ReportReservationStatus.approved => 'Odobrena',
        ReportReservationStatus.paid => 'Plaćena',
        ReportReservationStatus.cancelled => 'Otkazana',
        ReportReservationStatus.completed => 'Završena',
        ReportReservationStatus.pendingApproval => 'Čeka odobrenje',
      };
}

enum ReportReservationType {
  oneTime,
  monthly;

  static ReportReservationType fromIndex(int index) =>
      index >= 0 && index < ReportReservationType.values.length
          ? ReportReservationType.values[index]
          : ReportReservationType.oneTime;

  String get label => this == ReportReservationType.monthly ? 'Mjesečni' : 'Jednokratni';
}

/// Everything the "Reservations by period" PDF prints. All figures are computed by
/// the API; the desktop app only lays them out.
class ReservationReport extends Equatable {
  final DateTime from;
  final DateTime to;
  final DateTime generatedAt;
  final int totalReservations;
  final int cancelledReservations;
  final int completedReservations;
  final int paidReservations;
  final double totalValue;
  final List<ReservationReportRow> rows;
  final List<ReservationStatusCount> statusBreakdown;

  const ReservationReport({
    required this.from,
    required this.to,
    required this.generatedAt,
    required this.totalReservations,
    required this.cancelledReservations,
    required this.completedReservations,
    required this.paidReservations,
    required this.totalValue,
    required this.rows,
    required this.statusBreakdown,
  });

  @override
  List<Object?> get props => [from, to, generatedAt, totalReservations, totalValue, rows];
}

class ReservationReportRow extends Equatable {
  final int reservationId;
  final DateTime reservationDate;
  final String trainingName;
  final String? trainerName;
  final String clientName;
  final ReportReservationStatus status;
  final ReportReservationType reservationType;
  final double totalPrice;
  final bool isPaid;

  const ReservationReportRow({
    required this.reservationId,
    required this.reservationDate,
    required this.trainingName,
    required this.clientName,
    required this.status,
    required this.reservationType,
    required this.totalPrice,
    required this.isPaid,
    this.trainerName,
  });

  @override
  List<Object?> get props => [reservationId, reservationDate, trainingName, clientName, status];
}

class ReservationStatusCount extends Equatable {
  final ReportReservationStatus status;
  final int count;

  const ReservationStatusCount({required this.status, required this.count});

  @override
  List<Object?> get props => [status, count];
}
