import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/usecases/get_dashboard_stats.dart';

class DashboardProvider extends ChangeNotifier {
  final GetDashboardStats getDashboardStats;

  DashboardProvider({required this.getDashboardStats});

  DashboardStats? _stats;
  DashboardStats? get stats => _stats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Stable API code behind [error] (TIME_CONFLICT, AVAILABILITY_OVERLAP, …),
  /// so the screen can print the rule in the user's language rather than the
  /// server's English sentence.
  String? _errorCode;
  String? get errorCode => _errorCode;

  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    final result = await getDashboardStats(NoParams());
    result.fold(
      (failure) {
        _error = failure.message;
        _errorCode = failure.code;
        _isLoading = false;
        notifyListeners();
      },
      (stats) {
        _stats = stats;
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
