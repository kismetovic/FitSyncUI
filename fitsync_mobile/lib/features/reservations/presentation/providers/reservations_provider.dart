import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_type.dart';
import '../../domain/entities/slot_availability.dart';
import '../../domain/repositories/reservations_repository.dart';
import '../../domain/usecases/cancel_reservation.dart';
import '../../domain/usecases/create_reservation.dart';
import '../../domain/usecases/get_my_reservations.dart';

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

  /// Machine-readable code of the last failure, so the UI can react specifically to
  /// TIME_CONFLICT, CAPACITY_FULL or OUTSIDE_AVAILABILITY.
  String? _errorCode;
  String? get errorCode => _errorCode;

  Reservation? _pendingReservation;
  Reservation? get pendingReservation => _pendingReservation;

  Future<void> loadReservations() async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    final result = await getMyReservations(NoParams());
    result.fold(
      (f) {
        _error = f.message;
        _errorCode = f.code;
      },
      (list) => _reservations = list,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<Reservation?> book({
    required int trainingId,
    required DateTime reservationDate,
    required ReservationType reservationType,
    List<int> additionalServiceIds = const [],
    bool requestOutsideAvailability = false,
    int? userMembershipId,
  }) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    final result = await createReservation(CreateReservationParams(
      trainingId: trainingId,
      reservationDate: reservationDate,
      reservationType: reservationType,
      additionalServiceIds: additionalServiceIds,
      requestOutsideAvailability: requestOutsideAvailability,
      userMembershipId: userMembershipId,
    ));

    return result.fold(
      (f) {
        _error = f.message;
        _errorCode = f.code;
        _isLoading = false;
        notifyListeners();
        return null;
      },
      (r) {
        _pendingReservation = r;
        _reservations = [..._reservations, r];
        _isLoading = false;
        notifyListeners();
        return r;
      },
    );
  }

  /// Cancels with a reason. The reservation is not removed from the list: it stays
  /// visible with its cancelled status, which is what the business flow requires.
  Future<bool> cancel(int id, String reason) async {
    _error = null;
    _errorCode = null;

    final result = await cancelReservation(CancelReservationParams(id: id, reason: reason));

    return result.fold(
      (f) {
        _error = f.message;
        _errorCode = f.code;
        notifyListeners();
        return false;
      },
      (updated) {
        final index = _reservations.indexWhere((r) => r.id == id);
        if (index != -1) {
          _reservations = List.of(_reservations)..[index] = updated;
        }
        notifyListeners();
        return true;
      },
    );
  }

  /// Free places per day, straight from the backend. Capacity is enforced server-side;
  /// this only lets the calendar grey out full days in advance.
  Future<Map<DateTime, SlotAvailability>> getTrainingAvailability(int trainingId, {int days = 14}) async {
    final slots = await repository.getTrainingAvailability(trainingId, days: days);
    return {
      for (final slot in slots) DateTime(slot.date.year, slot.date.month, slot.date.day): slot,
    };
  }

  void clearError() {
    _error = null;
    _errorCode = null;
    notifyListeners();
  }
}
