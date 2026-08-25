import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/review.dart';
import '../../../../core/pagination/paged_result.dart';

abstract class ReviewsRepository {
  Future<Either<Failure, PagedResult<Review>>> getReviews({int page, int pageSize, String? query});
  Future<Either<Failure, void>> deleteReview(int id);
}
