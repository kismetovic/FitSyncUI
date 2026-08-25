import 'package:equatable/equatable.dart';

enum ReportPaymentProvider {
  payPal,
  cash;

  static ReportPaymentProvider fromIndex(int index) =>
      index >= 0 && index < ReportPaymentProvider.values.length
          ? ReportPaymentProvider.values[index]
          : ReportPaymentProvider.payPal;

  String get label => this == ReportPaymentProvider.cash ? 'Gotovina' : 'PayPal';
}

/// Everything the "Revenue by training" PDF prints. Only captured payments are
/// counted, so a pending or failed attempt never appears as income.
class RevenueReport extends Equatable {
  final DateTime from;
  final DateTime to;
  final DateTime generatedAt;
  final double totalRevenue;
  final int totalPayments;
  final String currency;
  final List<RevenueReportRow> rows;
  final List<RevenueByProviderRow> providerBreakdown;

  const RevenueReport({
    required this.from,
    required this.to,
    required this.generatedAt,
    required this.totalRevenue,
    required this.totalPayments,
    required this.currency,
    required this.rows,
    required this.providerBreakdown,
  });

  @override
  List<Object?> get props => [from, to, generatedAt, totalRevenue, totalPayments, rows];
}

class RevenueReportRow extends Equatable {
  final int trainingId;
  final String trainingName;
  final String? trainerName;
  final String? trainingTypeName;
  final int paymentsCount;
  final double revenue;
  final double averagePayment;

  const RevenueReportRow({
    required this.trainingId,
    required this.trainingName,
    required this.paymentsCount,
    required this.revenue,
    required this.averagePayment,
    this.trainerName,
    this.trainingTypeName,
  });

  @override
  List<Object?> get props => [trainingId, trainingName, paymentsCount, revenue];
}

class RevenueByProviderRow extends Equatable {
  final ReportPaymentProvider provider;
  final int paymentsCount;
  final double revenue;

  const RevenueByProviderRow({
    required this.provider,
    required this.paymentsCount,
    required this.revenue,
  });

  @override
  List<Object?> get props => [provider, paymentsCount, revenue];
}
