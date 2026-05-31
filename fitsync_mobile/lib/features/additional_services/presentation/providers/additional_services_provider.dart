import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/additional_service.dart';
import '../../domain/usecases/get_additional_services.dart';

class AdditionalServicesProvider extends ChangeNotifier {
  final GetAdditionalServices getAdditionalServices;

  AdditionalServicesProvider({required this.getAdditionalServices});

  List<AdditionalService> _services = [];
  List<AdditionalService> get services => _services;

  final Set<int> _selectedIds = {};
  Set<int> get selectedIds => _selectedIds;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadServices() async {
    if (_services.isNotEmpty) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getAdditionalServices(NoParams());
    result.fold(
      (f) { _error = f.message; _isLoading = false; notifyListeners(); },
      (list) { _services = list; _isLoading = false; notifyListeners(); },
    );
  }

  void toggleService(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  double get selectedTotal => _services
      .where((s) => _selectedIds.contains(s.id))
      .fold(0.0, (sum, s) => sum + s.price);

  List<AdditionalService> get selectedServices =>
      _services.where((s) => _selectedIds.contains(s.id)).toList();
}
