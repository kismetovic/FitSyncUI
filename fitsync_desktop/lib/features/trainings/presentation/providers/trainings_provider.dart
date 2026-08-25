import '../../../../core/pagination/paged_result.dart';
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

  /// Stable API code behind [error] (TIME_CONFLICT, AVAILABILITY_OVERLAP, …),
  /// so the screen can print the rule in the user's language rather than the
  /// server's English sentence.
  String? _errorCode;
  String? get errorCode => _errorCode;

  /// Page metadata from the API's PagedResult (review item 22).
  int _page = 1;
  int get page => _page;

  int _pageSize = kDefaultPageSize;
  int get pageSize => _pageSize;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  /// Held so paging keeps the active filter.
  String? _query;

  /// A new search is a new result set, so it restarts at page one.
  Future<void> search(String? query) => loadTrainings(query ?? '', 1);

  Future<void> loadTrainings([String? query, int? page]) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    // A null query on a plain reload keeps the current filter; search() passes
    // the new term explicitly.
    if (query != null) _query = query.isEmpty ? null : query;
    notifyListeners();

    final result = await getTrainings(
      searchQuery: _query,
      page: page ?? _page,
      pageSize: _pageSize,
    );
    result.fold(
      (failure) { _error = failure.message; _errorCode = failure.code; },
      (paged) {
        _trainings = paged.items;
        _page = paged.page;
        _pageSize = paged.pageSize;
        _totalCount = paged.totalCount;
      },
    );

    _isLoading = false;
    notifyListeners();
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
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
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
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
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
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (_) { _trainings.removeWhere((e) => e.id == id); notifyListeners(); return true; },
    );
  }
}
