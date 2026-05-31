import 'package:flutter/material.dart';
import '../../domain/entities/training.dart';
import '../../domain/entities/training_difficulty.dart';
import '../../domain/usecases/get_trainings.dart';
import '../../domain/usecases/create_training.dart';
import '../../domain/usecases/update_training.dart';
import '../../domain/usecases/delete_training.dart';

class TrainingsProvider extends ChangeNotifier {
  final GetTrainings getTrainings;
  final CreateTraining createTraining;
  final UpdateTraining updateTraining;
  final DeleteTraining deleteTraining;

  TrainingsProvider({
    required this.getTrainings,
    required this.createTraining,
    required this.updateTraining,
    required this.deleteTraining,
  });

  List<Training> _trainings = [];
  List<Training> get trainings => _trainings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadTrainings([String? query]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getTrainings(query);
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (list) {
        _trainings = list;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> addTraining({
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    required int maxCapacity,
    required TrainingDifficulty difficulty,
    required int trainingTypeId,
  }) async {
    final result = await createTraining(CreateTrainingParams(
      name: name,
      description: description,
      price: price,
      durationMinutes: durationMinutes,
      maxCapacity: maxCapacity,
      difficulty: difficulty,
      trainingTypeId: trainingTypeId,
    ));
    return result.fold(
      (f) { _error = f.message; notifyListeners(); return false; },
      (t) { _trainings.add(t); notifyListeners(); return true; },
    );
  }

  Future<bool> editTraining(int id, {
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    required int maxCapacity,
    required TrainingDifficulty difficulty,
    required int trainingTypeId,
  }) async {
    final result = await updateTraining(UpdateTrainingParams(
      id: id,
      name: name,
      description: description,
      price: price,
      durationMinutes: durationMinutes,
      maxCapacity: maxCapacity,
      difficulty: difficulty,
      trainingTypeId: trainingTypeId,
    ));
    return result.fold(
      (f) { _error = f.message; notifyListeners(); return false; },
      (t) {
        final idx = _trainings.indexWhere((e) => e.id == id);
        if (idx != -1) _trainings[idx] = t;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> removeTraining(int id) async {
    final result = await deleteTraining(id);
    return result.fold(
      (f) { _error = f.message; notifyListeners(); return false; },
      (_) { _trainings.removeWhere((e) => e.id == id); notifyListeners(); return true; },
    );
  }
}
