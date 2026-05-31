import 'package:flutter/material.dart';
import '../../domain/entities/admin_payment.dart';
import '../../data/datasources/payments_remote_data_source.dart';

class AdminPaymentsProvider extends ChangeNotifier {
  final PaymentsRemoteDataSource dataSource;
  AdminPaymentsProvider({required this.dataSource});

  List<AdminPayment> _payments = [];
  List<AdminPayment> get payments => _payments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  double get totalRevenue => _payments.fold(0.0, (sum, p) => sum + p.amount);
  int get paypalCount => _payments.where((p) => p.paymentProvider == 0).length;
  int get cashCount => _payments.where((p) => p.paymentProvider == 1).length;

  Future<void> load() async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      _payments = await dataSource.getAllPayments();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
