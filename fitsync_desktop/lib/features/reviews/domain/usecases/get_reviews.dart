import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paged_result.dart';
import '../entities/review.dart';
import '../repositories/reviews_repository.dart';

/// One page of reviews, optionally filtered. Both the page and the text match
/// are applied by the API (review item 22).
class GetReviews {
  final ReviewsRepository repository;

  GetReviews(this.repository);

  Future<Either<Failure, PagedResult<Review>>> call({
    int page = 1,
    int pageSize = kDefaultPageSize,
    String? query,
  }) =>
      repository.getReviews(page: page, pageSize: pageSize, query: query);
}
