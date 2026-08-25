import '../../../../core/pagination/paged_result.dart';
import 'package:flutter/material.dart';
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
  String _query = '';

  /// A new search is a new result set, so it restarts at page one.
  Future<void> search(String term) {
    _query = term;
    return loadReviews(page: 1);
  }

  Future<void> loadReviews({int? page}) async {
    _isLoading = true;
    _error = null;
    _errorCode = null;
    notifyListeners();

    final result = await getReviews(
      page: page ?? _page,
      pageSize: _pageSize,
      query: _query.isEmpty ? null : _query,
    );
    result.fold(
      (failure) { _error = failure.message; _errorCode = failure.code; },
      (paged) {
        _reviews = paged.items;
        _page = paged.page;
        _pageSize = paged.pageSize;
        _totalCount = paged.totalCount;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> remove(int id) async {
    final result = await deleteReview(id);
    return result.fold(
      (f) { _error = f.message; _errorCode = f.code; notifyListeners(); return false; },
      (_) { _reviews.removeWhere((r) => r.id == id); notifyListeners(); return true; },
    );
  }
}
