import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review.dart';
import '../repositories/reviews_repository.dart';

class GetReviews implements UseCase<List<Review>, NoParams> {
  final ReviewsRepository repository;

  GetReviews(this.repository);

  @override
  Future<Either<Failure, List<Review>>> call(NoParams params) async {
    return await repository.getReviews();
  }
}
