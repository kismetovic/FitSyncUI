import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/review.dart';

abstract class ReviewsRepository {
  Future<Either<Failure, List<Review>>> getTrainingReviews(int trainingId);
  Future<Either<Failure, Review>> createReview({
    required int trainingId,
    required int rating,
    String? comment,
  });
}
