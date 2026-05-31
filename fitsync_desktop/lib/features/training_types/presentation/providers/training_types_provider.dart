import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/training_type.dart';
import '../../domain/usecases/get_training_types.dart';
import '../../domain/usecases/create_training_type.dart';
import '../../domain/usecases/update_training_type.dart';
import '../../domain/usecases/delete_training_type.dart';

class TrainingTypesProvider extends ChangeNotifier {
  final GetTrainingTypes getTrainingTypes;
  final CreateTrainingType createTrainingType;
  final UpdateTrainingType updateTrainingType;
  final DeleteTrainingType deleteTrainingType;

  TrainingTypesProvider({
    required this.getTrainingTypes,
    required this.createTrainingType,
    required this.updateTrainingType,
    required this.deleteTrainingType,
  });

  List<TrainingType> _types = [];
  List<TrainingType> get types => _types;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true; _error = null; notifyListeners();
    final result = await getTrainingTypes(NoParams());
    result.fold(
      (f) { _error = f.message; _isLoading = false; notifyListeners(); },
      (list) { _types = list; _isLoading = false; notifyListeners(); },
    );
  }

  Future<bool> add(String name) async {
    final result = await createTrainingType(name);
    return result.fold(
      (f) { _error = f.message; notifyListeners(); return false; },
      (t) { _types.add(t); notifyListeners(); return true; },
    );
  }

  Future<bool> edit(int id, String name) async {
    final result = await updateTrainingType(id, name);
    return result.fold(
      (f) { _error = f.message; notifyListeners(); return false; },
      (t) {
        final idx = _types.indexWhere((e) => e.id == id);
        if (idx != -1) _types[idx] = t;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> remove(int id) async {
    final result = await deleteTrainingType(id);
    return result.fold(
      (f) { _error = f.message; notifyListeners(); return false; },
      (_) { _types.removeWhere((e) => e.id == id); notifyListeners(); return true; },
    );
  }
}
