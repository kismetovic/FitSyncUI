import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/recommended_training.dart';
import '../../domain/usecases/get_recommendations.dart';

class RecommendationsProvider extends ChangeNotifier {
  final GetRecommendations getRecommendations;

  RecommendationsProvider({required this.getRecommendations});

  List<RecommendedTraining> _recommendations = [];
  List<RecommendedTraining> get recommendations => _recommendations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadRecommendations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getRecommendations(NoParams());
    result.fold(
      (f) { _error = f.message; _isLoading = false; notifyListeners(); },
      (list) { _recommendations = list; _isLoading = false; notifyListeners(); },
    );
  }
}
