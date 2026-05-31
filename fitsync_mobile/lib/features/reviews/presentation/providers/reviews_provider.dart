import 'package:flutter/material.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/get_training_reviews.dart';
import '../../domain/usecases/create_review.dart';

class ReviewsProvider extends ChangeNotifier {
  final GetTrainingReviews getTrainingReviews;
  final CreateReview createReview;

  ReviewsProvider({required this.getTrainingReviews, required this.createReview});

  List<Review> _reviews = [];
  List<Review> get reviews => _reviews;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _submitting = false;
  bool get submitting => _submitting;

  Future<void> loadReviews(int trainingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getTrainingReviews(trainingId);
    result.fold(
      (f) { _error = f.message; _isLoading = false; notifyListeners(); },
      (list) { _reviews = list; _isLoading = false; notifyListeners(); },
    );
  }

  Future<bool> submitReview({required int trainingId, required int rating, String? comment}) async {
    _submitting = true;
    _error = null;
    notifyListeners();

    final result = await createReview(CreateReviewParams(
      trainingId: trainingId,
      rating: rating,
      comment: comment,
    ));

    return result.fold(
      (f) { _error = f.message; _submitting = false; notifyListeners(); return false; },
      (r) { _reviews.insert(0, r); _submitting = false; notifyListeners(); return true; },
    );
  }
}
