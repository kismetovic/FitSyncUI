import 'package:flutter/material.dart';
import '../../domain/entities/trainer.dart';
import '../../domain/usecases/trainer_usecases.dart';

class TrainersProvider extends ChangeNotifier {
  final GetTrainers getTrainers;
  final CreateTrainer createTrainer;
  final UpdateTrainer updateTrainer;
  final DeleteTrainer deleteTrainer;
  final AddTrainerAvailability addTrainerAvailability;
  final DeleteTrainerAvailability deleteTrainerAvailability;

  TrainersProvider({
    required this.getTrainers,
    required this.createTrainer,
    required this.updateTrainer,
    required this.deleteTrainer,
    required this.addTrainerAvailability,
    required this.deleteTrainerAvailability,
  });

  List<Trainer> _trainers = [];
  List<Trainer> get trainers => _trainers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Stable API code behind [error] (TIME_CONFLICT, AVAILABILITY_OVERLAP, …),
  /// so the screen can print the rule in the user's language rather than the
  /// server's English sentence.
  String? _errorCode;
  String? get errorCode => _errorCode;

  void clearError() {
    _error = null;
    _errorCode = null;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    final result = await getTrainers();
    result.fold(
      (f) { _error = f.message; _errorCode = f.code; },
      (list) => _trainers = list,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> add(Trainer trainer) async {
    final result = await createTrainer(trainer);
    return result.fold(
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (t) { _trainers = [..._trainers, t]; _error = null;
    _errorCode = null; notifyListeners(); return true; },
    );
  }

  Future<bool> edit(int id, Trainer trainer) async {
    final result = await updateTrainer(id, trainer);
    return result.fold(
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (t) {
        final idx = _trainers.indexWhere((e) => e.id == id);
        // The update response does not carry the availability list, so keep the
        // one already loaded rather than blanking the expanded panel.
        if (idx != -1) {
          _trainers[idx] = Trainer(
            id: t.id,
            firstName: t.firstName,
            lastName: t.lastName,
            biography: t.biography,
            specialty: t.specialty,
            email: t.email,
            phoneNumber: t.phoneNumber,
            outsideAvailabilitySurcharge: t.outsideAvailabilitySurcharge,
            userId: t.userId,
            availabilities: t.availabilities.isEmpty
                ? _trainers[idx].availabilities
                : t.availabilities,
          );
        }
        _error = null;
    _errorCode = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> remove(int id) async {
    final result = await deleteTrainer(id);
    return result.fold(
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (_) { _trainers.removeWhere((e) => e.id == id); _error = null;
    _errorCode = null; notifyListeners(); return true; },
    );
  }

  /// Availability changes come back as a bare OK, so the list is reloaded to pick
  /// up the server-assigned id of the new window.
  Future<bool> addAvailability({
    required int trainerId,
    required int dayOfWeek,
    required int startMinutes,
    required int endMinutes,
  }) async {
    final result = await addTrainerAvailability(
      trainerId: trainerId,
      dayOfWeek: dayOfWeek,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
    );
    final ok = result.fold(
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (_) => true,
    );
    if (ok) {
      _error = null;
    _errorCode = null;
      await load();
    }
    return ok;
  }

  Future<bool> removeAvailability(int availabilityId) async {
    final result = await deleteTrainerAvailability(availabilityId);
    final ok = result.fold(
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (_) => true,
    );
    if (ok) {
      _error = null;
    _errorCode = null;
      await load();
    }
    return ok;
  }
}
