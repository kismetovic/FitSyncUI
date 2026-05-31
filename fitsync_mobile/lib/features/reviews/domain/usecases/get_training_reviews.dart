import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review.dart';
import '../repositories/reviews_repository.dart';

class GetTrainingReviews implements UseCase<List<Review>, int> {
  final ReviewsRepository repository;

  GetTrainingReviews(this.repository);

  @override
  Future<Either<Failure, List<Review>>> call(int trainingId) async {
    return await repository.getTrainingReviews(trainingId);
  }
}
