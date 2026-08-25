import 'package:flutter/material.dart';
import '../../domain/entities/additional_service.dart';
import '../../domain/repositories/additional_services_repository.dart';

class AdditionalServicesProvider extends ChangeNotifier {
  final AdditionalServicesRepository repository;
  AdditionalServicesProvider({required this.repository});

  List<AdditionalService> _services = [];
  List<AdditionalService> get services => _services;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Stable API code behind [error] (TIME_CONFLICT, AVAILABILITY_OVERLAP, …),
  /// so the screen can print the rule in the user's language rather than the
  /// server's English sentence.
  String? _errorCode;
  String? get errorCode => _errorCode;

  Future<void> load() async {
    _isLoading = true; _error = null;
    _errorCode = null; notifyListeners();
    final result = await repository.getAll();
    result.fold(
      (f) { _error = f.message; _errorCode = f.code; _isLoading = false; notifyListeners(); },
      (list) { _services = list; _isLoading = false; notifyListeners(); },
    );
  }

  Future<bool> add(String name, double price) async {
    final result = await repository.create(name, price);
    return result.fold(
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (s) { _services.add(s); notifyListeners(); return true; },
    );
  }

  Future<bool> edit(int id, String name, double price) async {
    final result = await repository.update(id, name, price);
    return result.fold(
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (s) {
        final idx = _services.indexWhere((e) => e.id == id);
        if (idx != -1) _services[idx] = s;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> remove(int id) async {
    final result = await repository.delete(id);
    return result.fold(
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (_) { _services.removeWhere((e) => e.id == id); notifyListeners(); return true; },
    );
  }
}
