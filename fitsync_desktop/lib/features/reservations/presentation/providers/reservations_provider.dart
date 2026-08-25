import 'package:flutter/material.dart';
import '../../../../core/pagination/paged_result.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/usecases/approve_reservation.dart';
import '../../domain/usecases/cancel_reservation.dart';
import '../../domain/usecases/complete_reservation.dart';
import '../../domain/usecases/confirm_cash_payment.dart';
import '../../domain/usecases/get_reservations.dart';

/// Administrative reservation actions.
///
/// Each action maps to a dedicated backend endpoint that enforces the state machine,
/// so the UI cannot put a reservation into an inconsistent state. There is no
/// "delete" here: a reservation is cancelled with a reason and stays on record.
class ReservationsProvider extends ChangeNotifier {
  final GetReservations getReservations;
  final ApproveReservation approveReservation;
  final CompleteReservation completeReservation;
  final CancelReservation cancelReservation;
  final ConfirmCashPayment confirmCashPayment;

  ReservationsProvider({
    required this.getReservations,
    required this.approveReservation,
    required this.completeReservation,
    required this.cancelReservation,
    required this.confirmCashPayment,
  });

  List<Reservation> _reservations = [];
  List<Reservation> get reservations => _reservations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Stable API code behind [error] (TIME_CONFLICT, AVAILABILITY_OVERLAP, …),
  /// so the screen can print the rule in the user's language rather than the
  /// server's English sentence.
  String? _errorCode;
  String? get errorCode => _errorCode;

  /// Current page metadata, straight from the API's PagedResult (review item 22).
  int _page = 1;
  int get page => _page;

  int _pageSize = kDefaultPageSize;
  int get pageSize => _pageSize;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  /// Current search term. Held here so paging through results keeps the filter.
  String _query = '';
  String get query => _query;

  /// Searching restarts at page one: the result set is a different one.
  Future<void> search(String term) async {
    _query = term;
    await loadReservations(page: 1);
  }

  Future<void> loadReservations({int? page}) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    final requested = page ?? _page;
    final result = await getReservations(
      page: requested,
      pageSize: _pageSize,
      query: _query.isEmpty ? null : _query,
    );
    result.fold(
      (failure) { _error = failure.message; _errorCode = failure.code; },
      (paged) {
        _reservations = paged.items;
        _page = paged.page;
        _pageSize = paged.pageSize;
        _totalCount = paged.totalCount;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> approve(int id) async {
    final result = await approveReservation(id);
    return _applyResult(id, result);
  }

  Future<bool> complete(int id, {String? note}) async {
    final result = await completeReservation(CompleteReservationParams(id: id, note: note));
    return _applyResult(id, result);
  }

  Future<bool> cancel(int id, String reason) async {
    final result = await cancelReservation(CancelReservationParams(id: id, reason: reason));
    return _applyResult(id, result);
  }

  /// Confirms cash at the desk. The reservation then moves to Paid on the server, so
  /// the list is reloaded to pick up the new status and allowed transitions.
  Future<bool> confirmCash(int reservationId, {String? note}) async {
    _error = null;
    _errorCode = null;
    final result = await confirmCashPayment(
      ConfirmCashPaymentParams(reservationId: reservationId, note: note),
    );

    return result.fold(
      (failure) {
        _error = failure.message;
        _errorCode = failure.code;
        notifyListeners();
        return false;
      },
      (_) async {
        await loadReservations();
        return true;
      },
    );
  }

  bool _applyResult(int id, dynamic result) {
    return result.fold(
      (failure) {
        _error = failure.message;
        _errorCode = failure.code;
        notifyListeners();
        return false;
      },
      (Reservation updated) {
        final index = _reservations.indexWhere((e) => e.id == id);
        if (index != -1) {
          _reservations = List.of(_reservations)..[index] = updated;
        }
        _error = null;
    _errorCode = null;
        notifyListeners();
        return true;
      },
    );
  }

  void clearError() {
    _error = null;
    _errorCode = null;
    notifyListeners();
  }
}
