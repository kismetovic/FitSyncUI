import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/reviews_repository.dart';
import '../datasources/reviews_remote_data_source.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDataSource remoteDataSource;

  ReviewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Review>>> getTrainingReviews(int trainingId) async {
    try {
      return Right(await remoteDataSource.getTrainingReviews(trainingId));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<List<Review>> getMyReviews() async {
    try {
      return await remoteDataSource.getMyReviews();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Either<Failure, Review>> createReview({
    required int reservationId,
    required int rating,
    String? comment,
  }) async {
    try {
      return Right(await remoteDataSource.createReview(
        reservationId: reservationId,
        rating: rating,
        comment: comment,
      ));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
