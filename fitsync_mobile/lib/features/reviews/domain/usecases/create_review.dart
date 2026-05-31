import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review.dart';
import '../repositories/reviews_repository.dart';

class CreateReviewParams extends Equatable {
  final int trainingId;
  final int rating;
  final String? comment;

  const CreateReviewParams({required this.trainingId, required this.rating, this.comment});

  @override
  List<Object?> get props => [trainingId, rating, comment];
}

class CreateReview implements UseCase<Review, CreateReviewParams> {
  final ReviewsRepository repository;

  CreateReview(this.repository);

  @override
  Future<Either<Failure, Review>> call(CreateReviewParams params) async {
    return await repository.createReview(
      trainingId: params.trainingId,
      rating: params.rating,
      comment: params.comment,
    );
  }
}
