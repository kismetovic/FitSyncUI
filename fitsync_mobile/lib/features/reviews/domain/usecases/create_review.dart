import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review.dart';
import '../repositories/reviews_repository.dart';

class CreateReviewParams extends Equatable {
  /// The attended reservation being reviewed. The backend derives the training and
  /// the author from it, so neither can be spoofed.
  final int reservationId;
  final int rating;
  final String? comment;

  const CreateReviewParams({required this.reservationId, required this.rating, this.comment});

  @override
  List<Object?> get props => [reservationId, rating, comment];
}

class CreateReview implements UseCase<Review, CreateReviewParams> {
  final ReviewsRepository repository;

  CreateReview(this.repository);

  @override
  Future<Either<Failure, Review>> call(CreateReviewParams params) => repository.createReview(
        reservationId: params.reservationId,
        rating: params.rating,
        comment: params.comment,
      );
}
