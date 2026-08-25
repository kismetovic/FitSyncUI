import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/review.dart';

abstract class ReviewsRepository {
  Future<Either<Failure, List<Review>>> getTrainingReviews(int trainingId);
  Future<List<Review>> getMyReviews();
  Future<Either<Failure, Review>> createReview({
    required int reservationId,
    required int rating,
    String? comment,
  });
}
