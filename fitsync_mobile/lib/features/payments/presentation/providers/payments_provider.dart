import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/paypal_order.dart';
import '../../domain/usecases/capture_paypal_order.dart';
import '../../domain/usecases/create_paypal_order.dart';
import '../../domain/usecases/get_my_payments.dart';
import '../../domain/usecases/select_cash_payment.dart';

/// Stages of the PayPal checkout, so the UI can guide the user through the real
/// approval flow instead of pretending to be a PayPal login form.
enum PayPalStage {
  idle,

  /// Waiting for the backend to open the order with PayPal.
  creatingOrder,

  /// Order created; the user has been sent to PayPal and has not returned yet.
  awaitingApproval,

  /// Backend is capturing and verifying the payment.
  capturing,

  /// Capture verified and the reservation is marked paid.
  completed,
}

class PaymentsProvider extends ChangeNotifier {
  final CreatePayPalOrder createPayPalOrder;
  final CapturePayPalOrder capturePayPalOrder;
  final SelectCashPayment selectCashPayment;
  final GetMyPayments getMyPayments;

  PaymentsProvider({
    required this.createPayPalOrder,
    required this.capturePayPalOrder,
    required this.selectCashPayment,
    required this.getMyPayments,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  PayPalStage _stage = PayPalStage.idle;
  PayPalStage get stage => _stage;

  PayPalOrder? _order;
  PayPalOrder? get order => _order;

  /// Set when the last check came back ORDER_NOT_APPROVED, i.e. the user has not
  /// finished at PayPal. Distinguishes "wait and ask again" from a real failure.
  bool _notApprovedYet = false;
  bool get notApprovedYet => _notApprovedYet;

  String? _errorCode;
  String? get errorCode => _errorCode;

  Payment? _lastPayment;
  Payment? get lastPayment => _lastPayment;

  PayPalCapture? _lastCapture;
  PayPalCapture? get lastCapture => _lastCapture;

  List<Payment> _myPayments = [];
  List<Payment> get myPayments => _myPayments;

  Future<void> loadMyPayments() async {
    _setLoading(true);
    try {
      _myPayments = await getMyPayments();
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  /// Step 1: the backend opens a PayPal order and returns the official approval URL.
  /// Step 2: that URL is opened in the system browser so the user authenticates with
  /// PayPal directly. The app never sees their PayPal credentials.
  Future<bool> startPayPalCheckout(int reservationId) async {
    _error = null;
    _stage = PayPalStage.creatingOrder;
    _setLoading(true);

    final result = await createPayPalOrder(reservationId);

    return result.fold(
      (failure) {
        _error = failure.message;
        _stage = PayPalStage.idle;
        _setLoading(false);
        return false;
      },
      (order) async {
        _order = order;

        if (order.approvalUrl.isEmpty) {
          _error = 'PayPal nije vratio adresu za potvrdu plaćanja. Pokušajte ponovo.';
          _stage = PayPalStage.idle;
          _setLoading(false);
          return false;
        }

        final opened = await _openApprovalUrl(order.approvalUrl);
        if (!opened) {
          _error = 'Nije moguće otvoriti PayPal stranicu na ovom uređaju.';
          _stage = PayPalStage.idle;
          _setLoading(false);
          return false;
        }

        _stage = PayPalStage.awaitingApproval;
        _setLoading(false);
        return true;
      },
    );
  }

  /// Step 3: after the user returns from PayPal, the backend captures the order and
  /// verifies the amount, currency and reference before recording the payment.
  Future<bool> completePayPalCheckout({bool silent = false}) async {
    final order = _order;
    if (order == null) {
      _error = 'Nema aktivne PayPal narudžbe.';
      notifyListeners();
      return false;
    }

    _error = null;
    _stage = PayPalStage.capturing;
    _setLoading(true);

    final result = await capturePayPalOrder(CapturePayPalOrderParams(
      orderId: order.orderId,
      reservationId: order.reservationId,
    ));

    return result.fold(
      (failure) {
        // "Not approved yet" is an expected state while the user is still on the
        // PayPal page, not something to shout about. It is reported only once the
        // app has stopped waiting for them.
        _notApprovedYet = failure.code == 'ORDER_NOT_APPROVED';
        _error = (silent && _notApprovedYet) ? null : failure.message;
        _errorCode = failure.code;
        _stage = PayPalStage.awaitingApproval;
        _setLoading(false);
        return false;
      },
      (capture) {
        _lastCapture = capture;
        _error = null;
        _errorCode = null;
        _notApprovedYet = false;
        _stage = PayPalStage.completed;
        _setLoading(false);
        return true;
      },
    );
  }

  /// Asks the server to check with PayPal, repeatedly, until it either confirms the
  /// payment or the user has clearly not approved it.
  ///
  /// The app used to show a "I have completed the payment" button, which put the
  /// client in the position of declaring a payment successful — the one thing the
  /// review says it must never do. Nothing here decides anything: every attempt is
  /// the server capturing and verifying with PayPal. The app only decides *when to
  /// ask*, and it asks on its own once the user comes back from the browser.
  Future<bool> verifyPayPalPayment({int attempts = 5}) async {
    if (_order == null || _stage == PayPalStage.completed) return false;

    for (var attempt = 1; attempt <= attempts; attempt++) {
      // Silent while there are attempts left: a "not approved" answer this early
      // usually just means PayPal has not finished processing the approval.
      final last = attempt == attempts;
      final ok = await completePayPalCheckout(silent: !last);
      if (ok) return true;

      // A genuine failure (declined card, mismatched amount) will not fix itself.
      if (!_notApprovedYet) return false;

      if (!last) await Future<void>.delayed(const Duration(seconds: 3));
    }
    return false;
  }

  /// Records the choice to pay at the gym. The reservation stays unpaid until an
  /// administrator confirms the cash was collected.
  Future<Payment?> chooseCashOnArrival(int reservationId) async {
    _error = null;
    _setLoading(true);

    final result = await selectCashPayment(reservationId);

    return result.fold(
      (failure) {
        _error = failure.message;
        _setLoading(false);
        return null;
      },
      (payment) {
        _lastPayment = payment;
        _setLoading(false);
        return payment;
      },
    );
  }

  Future<bool> _openApprovalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void reset() {
    _stage = PayPalStage.idle;
    _order = null;
    _lastCapture = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
