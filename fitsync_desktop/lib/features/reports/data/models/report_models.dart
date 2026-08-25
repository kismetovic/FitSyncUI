import '../../domain/entities/reservation_report.dart';
import '../../domain/entities/revenue_report.dart';

DateTime _date(dynamic value) => DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
double _money(dynamic value) => (value as num?)?.toDouble() ?? 0.0;

class ReservationReportModel extends ReservationReport {
  const ReservationReportModel({
    required super.from,
    required super.to,
    required super.generatedAt,
    required super.totalReservations,
    required super.cancelledReservations,
    required super.completedReservations,
    required super.paidReservations,
    required super.totalValue,
    required super.rows,
    required super.statusBreakdown,
  });

  factory ReservationReportModel.fromJson(Map<String, dynamic> json) => ReservationReportModel(
        from: _date(json['from']),
        to: _date(json['to']),
        generatedAt: _date(json['generatedAt']),
        totalReservations: json['totalReservations'] as int? ?? 0,
        cancelledReservations: json['cancelledReservations'] as int? ?? 0,
        completedReservations: json['completedReservations'] as int? ?? 0,
        paidReservations: json['paidReservations'] as int? ?? 0,
        totalValue: _money(json['totalValue']),
        rows: (json['rows'] as List? ?? [])
            .map((e) => ReservationReportRow(
                  reservationId: e['reservationId'] as int? ?? 0,
                  reservationDate: _date(e['reservationDate']),
                  trainingName: e['trainingName']?.toString() ?? '-',
                  trainerName: e['trainerName']?.toString(),
                  clientName: e['clientName']?.toString() ?? '-',
                  status: ReportReservationStatus.fromIndex(e['status'] as int? ?? 0),
                  reservationType: ReportReservationType.fromIndex(e['reservationType'] as int? ?? 0),
                  totalPrice: _money(e['totalPrice']),
                  isPaid: e['isPaid'] as bool? ?? false,
                ))
            .toList(),
        statusBreakdown: (json['statusBreakdown'] as List? ?? [])
            .map((e) => ReservationStatusCount(
                  status: ReportReservationStatus.fromIndex(e['status'] as int? ?? 0),
                  count: e['count'] as int? ?? 0,
                ))
            .toList(),
      );
}

class RevenueReportModel extends RevenueReport {
  const RevenueReportModel({
    required super.from,
    required super.to,
    required super.generatedAt,
    required super.totalRevenue,
    required super.totalPayments,
    required super.currency,
    required super.rows,
    required super.providerBreakdown,
  });

  factory RevenueReportModel.fromJson(Map<String, dynamic> json) => RevenueReportModel(
        from: _date(json['from']),
        to: _date(json['to']),
        generatedAt: _date(json['generatedAt']),
        totalRevenue: _money(json['totalRevenue']),
        totalPayments: json['totalPayments'] as int? ?? 0,
        currency: json['currency']?.toString() ?? 'BAM',
        rows: (json['rows'] as List? ?? [])
            .map((e) => RevenueReportRow(
                  trainingId: e['trainingId'] as int? ?? 0,
                  trainingName: e['trainingName']?.toString() ?? '-',
                  trainerName: e['trainerName']?.toString(),
                  trainingTypeName: e['trainingTypeName']?.toString(),
                  paymentsCount: e['paymentsCount'] as int? ?? 0,
                  revenue: _money(e['revenue']),
                  averagePayment: _money(e['averagePayment']),
                ))
            .toList(),
        providerBreakdown: (json['providerBreakdown'] as List? ?? [])
            .map((e) => RevenueByProviderRow(
                  provider: ReportPaymentProvider.fromIndex(e['provider'] as int? ?? 0),
                  paymentsCount: e['paymentsCount'] as int? ?? 0,
                  revenue: _money(e['revenue']),
                ))
            .toList(),
      );
}
