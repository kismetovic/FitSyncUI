import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/review.dart';

abstract class ReviewsRepository {
  Future<Either<Failure, List<Review>>> getReviews();
  Future<Either<Failure, void>> deleteReview(int id);
}
