import 'package:flutter/material.dart';
import '../../domain/entities/payment.dart';
import '../../domain/usecases/capture_paypal_order.dart';
import '../../domain/usecases/create_paypal_order.dart';
import '../../domain/usecases/confirm_payment.dart';
import '../../domain/usecases/confirm_cash_payment.dart';
import '../../domain/usecases/get_my_payments.dart';

class PaymentsProvider extends ChangeNotifier {
  final CreatePayPalOrder createPayPalOrder;
  final CapturePayPalOrder capturePayPalOrder;
  final ConfirmPayment confirmPayment;
  final ConfirmCashPayment confirmCashPayment;
  final GetMyPayments getMyPayments;

  PaymentsProvider({
    required this.createPayPalOrder,
    required this.capturePayPalOrder,
    required this.confirmPayment,
    required this.confirmCashPayment,
    required this.getMyPayments,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Payment? _lastPayment;
  Payment? get lastPayment => _lastPayment;

  Map<String, String>? _paypalOrder;
  Map<String, String>? get paypalOrder => _paypalOrder;

  List<Payment> _myPayments = [];
  List<Payment> get myPayments => _myPayments;

  Future<void> loadMyPayments() async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      _myPayments = await getMyPayments();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false; notifyListeners();
  }

  Future<Map<String, String>?> initiatePayPal({
    required double amount,
    required int reservationId,
  }) async {
    _isLoading = true; _error = null; notifyListeners();
    final result = await createPayPalOrder(CreatePayPalOrderParams(
      amount: amount, reservationId: reservationId,
    ));
    return result.fold(
      (f) { _error = f.message; _isLoading = false; notifyListeners(); return null; },
      (order) { _paypalOrder = order; _isLoading = false; notifyListeners(); return order; },
    );
  }

  Future<String?> captureOrder(String orderId) async {
    _isLoading = true; _error = null; notifyListeners();
    final result = await capturePayPalOrder(orderId);
    return result.fold(
      (f) { _error = f.message; _isLoading = false; notifyListeners(); return null; },
      (txId) { _isLoading = false; notifyListeners(); return txId; },
    );
  }

  Future<Payment?> finishPayPal({
    required double amount,
    required String transactionId,
    required int reservationId,
  }) async {
    _isLoading = true; _error = null; notifyListeners();
    final result = await confirmPayment(ConfirmPaymentParams(
      amount: amount,
      transactionId: transactionId,
      paymentProvider: PaymentProvider.paypal,
      reservationId: reservationId,
    ));
    return result.fold(
      (f) { _error = f.message; _isLoading = false; notifyListeners(); return null; },
      (p) { _lastPayment = p; _isLoading = false; notifyListeners(); return p; },
    );
  }

  Future<Payment?> payCash({
    required double amount,
    required int reservationId,
  }) async {
    _isLoading = true; _error = null; notifyListeners();
    final result = await confirmCashPayment(ConfirmCashPaymentParams(
      amount: amount, reservationId: reservationId,
    ));
    return result.fold(
      (f) { _error = f.message; _isLoading = false; notifyListeners(); return null; },
      (p) { _lastPayment = p; _isLoading = false; notifyListeners(); return p; },
    );
  }

  void clearError() { _error = null; notifyListeners(); }
}
