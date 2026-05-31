import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalUsers;
  final int totalTrainings;
  final int totalReservations;
  final double totalRevenue;

  const DashboardStats({
    required this.totalUsers,
    required this.totalTrainings,
    required this.totalReservations,
    this.totalRevenue = 0.0,
  });

  @override
  List<Object?> get props => [totalUsers, totalTrainings, totalReservations, totalRevenue];
}
