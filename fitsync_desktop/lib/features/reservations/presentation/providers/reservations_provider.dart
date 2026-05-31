import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_status.dart';
import '../../domain/usecases/approve_reservation.dart';
import '../../domain/usecases/get_reservations.dart';
import '../../domain/usecases/update_reservation.dart';
import '../../domain/usecases/delete_reservation.dart';

class ReservationsProvider extends ChangeNotifier {
  final GetReservations getReservations;
  final UpdateReservation updateReservation;
  final ApproveReservation approveReservation;
  final DeleteReservation deleteReservation;

  ReservationsProvider({
    required this.getReservations,
    required this.updateReservation,
    required this.approveReservation,
    required this.deleteReservation,
  });

  List<Reservation> _reservations = [];
  List<Reservation> get reservations => _reservations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getReservations(NoParams());
    result.fold(
      (failure) { _error = failure.message; _isLoading = false; notifyListeners(); },
      (list) { _reservations = list; _isLoading = false; notifyListeners(); },
    );
  }

  Future<bool> approve(int id) async {
    final result = await approveReservation(id);
    return result.fold(
      (f) { _error = f.message; notifyListeners(); return false; },
      (updated) {
        final idx = _reservations.indexWhere((e) => e.id == id);
        if (idx != -1) _reservations[idx] = updated;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> updateStatus(int id, ReservationStatus status) async {
    final result = await updateReservation(UpdateReservationParams(id: id, status: status));
    return result.fold(
      (f) { _error = f.message; notifyListeners(); return false; },
      (updated) {
        final idx = _reservations.indexWhere((e) => e.id == id);
        if (idx != -1) _reservations[idx] = updated;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> remove(int id) async {
    final result = await deleteReservation(id);
    return result.fold(
      (f) { _error = f.message; notifyListeners(); return false; },
      (_) { _reservations.removeWhere((e) => e.id == id); notifyListeners(); return true; },
    );
  }
}
