import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_status.dart';
import '../../domain/entities/reservation_type.dart';
import '../../domain/repositories/reservations_repository.dart';
import '../../domain/usecases/get_my_reservations.dart';
import '../../domain/usecases/create_reservation.dart';
import '../../domain/usecases/cancel_reservation.dart';

class ReservationsProvider extends ChangeNotifier {
  final GetMyReservations getMyReservations;
  final CreateReservation createReservation;
  final CancelReservation cancelReservation;
  final ReservationsRepository repository;

  ReservationsProvider({
    required this.getMyReservations,
    required this.createReservation,
    required this.cancelReservation,
    required this.repository,
  });

  List<Reservation> _reservations = [];
  List<Reservation> get reservations => _reservations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Reservation? _pendingReservation;
  Reservation? get pendingReservation => _pendingReservation;

  Future<void> loadReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getMyReservations(NoParams());
    result.fold(
      (f) { _error = f.message; _isLoading = false; notifyListeners(); },
      (list) { _reservations = list; _isLoading = false; notifyListeners(); },
    );
  }

  Future<Reservation?> book({
    required int trainingId,
    required DateTime reservationDate,
    required ReservationType reservationType,
    List<int> additionalServiceIds = const [],
    bool requestOutsideAvailability = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await createReservation(CreateReservationParams(
      trainingId: trainingId,
      reservationDate: reservationDate,
      reservationType: reservationType,
      additionalServiceIds: additionalServiceIds,
      requestOutsideAvailability: requestOutsideAvailability,
    ));

    return result.fold(
      (f) { _error = f.message; _isLoading = false; notifyListeners(); return null; },
      (r) { _pendingReservation = r; _reservations.add(r); _isLoading = false; notifyListeners(); return r; },
    );
  }

  Future<bool> cancel(int id) async {
    final result = await cancelReservation(id);
    return result.fold(
      (f) { _error = f.message; notifyListeners(); return false; },
      (_) { _reservations.removeWhere((r) => r.id == id); notifyListeners(); return true; },
    );
  }

  Future<Map<DateTime, int>> getTrainingBookingCounts(int trainingId, {int days = 14}) async {
    final allReservations = await repository.getReservationsByTraining(trainingId);
    final now = DateTime.now();
    final map = <DateTime, int>{};
    for (var i = 0; i < days; i++) {
      final d = DateTime(now.year, now.month, now.day + i);
      map[d] = 0;
    }
    for (final r in allReservations) {
      if (r.status == ReservationStatus.cancelled) continue;
      final key = DateTime(r.reservationDate.year, r.reservationDate.month, r.reservationDate.day);
      if (map.containsKey(key)) map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
