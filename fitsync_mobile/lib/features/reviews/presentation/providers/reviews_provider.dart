import 'package:flutter/material.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/create_review.dart';
import '../../domain/usecases/get_training_reviews.dart';

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

  /// Error code from the API, e.g. TRAINING_NOT_ATTENDED or ALREADY_REVIEWED, so the
  /// screen can explain precisely why a review was refused.
  String? _errorCode;
  String? get errorCode => _errorCode;

  bool _submitting = false;
  bool get submitting => _submitting;

  Future<void> loadReviews(int trainingId) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    final result = await getTrainingReviews(trainingId);
    result.fold(
      (f) {
        _error = f.message;
        _errorCode = f.code;
      },
      (list) => _reviews = list,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// A review is submitted against the attended reservation. The backend derives the
  /// training and the author from it, and refuses if the session was not attended or
  /// has already been reviewed.
  Future<bool> submitReview({
    required int reservationId,
    required int rating,
    String? comment,
  }) async {
    _submitting = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    final result = await createReview(CreateReviewParams(
      reservationId: reservationId,
      rating: rating,
      comment: comment,
    ));

    return result.fold(
      (f) {
        _error = f.message;
        _errorCode = f.code;
        _submitting = false;
        notifyListeners();
        return false;
      },
      (r) {
        _reviews = [r, ..._reviews];
        _submitting = false;
        notifyListeners();
        return true;
      },
    );
  }

  void clearError() {
    _error = null;
    _errorCode = null;
    notifyListeners();
  }
}
