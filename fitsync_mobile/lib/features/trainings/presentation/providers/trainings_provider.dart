import 'package:flutter/material.dart';
import '../../domain/entities/training.dart';
import '../../domain/entities/training_difficulty.dart';
import '../../domain/usecases/get_trainings.dart';

class TrainingsProvider extends ChangeNotifier {
  final GetTrainings getTrainings;

  TrainingsProvider({required this.getTrainings});

  List<Training> _allTrainings = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  Set<TrainingDifficulty> _selectedDifficulties = {};
  Set<TrainingDifficulty> get selectedDifficulties => _selectedDifficulties;

  String? _selectedType;
  String? get selectedType => _selectedType;

  String _sortBy = 'default';
  String get sortBy => _sortBy;

  Set<String> get availableTypes => _allTrainings
      .where((t) => t.trainingTypeName != null)
      .map((t) => t.trainingTypeName!)
      .toSet();

  bool get hasActiveFilters =>
      _selectedDifficulties.isNotEmpty || _selectedType != null || _sortBy != 'default';

  int get activeFilterCount {
    int count = 0;
    if (_selectedDifficulties.isNotEmpty) count++;
    if (_selectedType != null) count++;
    if (_sortBy != 'default') count++;
    return count;
  }

  List<Training>? _cachedTrainings;

  List<Training> get trainings => _cachedTrainings ??= _computeTrainings();

  List<Training> _computeTrainings() {
    var list = List<Training>.from(_allTrainings);
    if (_selectedDifficulties.isNotEmpty) {
      list = list.where((t) => _selectedDifficulties.contains(t.difficulty)).toList();
    }
    if (_selectedType != null) {
      list = list.where((t) => t.trainingTypeName == _selectedType).toList();
    }
    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
      case 'rating':
        list.sort((a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0));
      case 'duration':
        list.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
    }
    return list;
  }

  void _invalidateCache() {
    _cachedTrainings = null;
  }

  void toggleDifficulty(TrainingDifficulty d) {
    final updated = Set<TrainingDifficulty>.from(_selectedDifficulties);
    if (updated.contains(d)) {
      updated.remove(d);
    } else {
      updated.add(d);
    }
    _selectedDifficulties = updated;
    _invalidateCache();
    notifyListeners();
  }

  void setType(String? type) {
    _selectedType = type;
    _invalidateCache();
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    _invalidateCache();
    notifyListeners();
  }

  void clearFilters() {
    _selectedDifficulties = {};
    _selectedType = null;
    _sortBy = 'default';
    _invalidateCache();
    notifyListeners();
  }

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
        _allTrainings = list;
        _isLoading = false;
        _invalidateCache();
        notifyListeners();
      },
    );
  }
}
