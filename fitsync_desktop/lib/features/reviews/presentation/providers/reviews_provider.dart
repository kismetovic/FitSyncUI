import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/get_reviews.dart';
import '../../domain/usecases/delete_review.dart';

class ReviewsProvider extends ChangeNotifier {
  final GetReviews getReviews;
  final DeleteReview deleteReview;

  ReviewsProvider({required this.getReviews, required this.deleteReview});

  List<Review> _reviews = [];
  List<Review> get reviews => _reviews;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadReviews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getReviews(NoParams());
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (list) {
        _reviews = list;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> remove(int id) async {
    final result = await deleteReview(id);
    return result.fold(
      (f) { _error = f.message; notifyListeners(); return false; },
      (_) { _reviews.removeWhere((r) => r.id == id); notifyListeners(); return true; },
    );
  }
}
