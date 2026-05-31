import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.totalUsers,
    required super.totalTrainings,
    required super.totalReservations,
    super.totalRevenue,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalUsers: json['totalUsers'] ?? 0,
      totalTrainings: json['totalTrainings'] ?? 0,
      totalReservations: json['totalReservations'] ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
