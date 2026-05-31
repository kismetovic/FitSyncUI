import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/reviews_repository.dart';

class DeleteReview implements UseCase<void, int> {
  final ReviewsRepository repository;

  DeleteReview(this.repository);

  @override
  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteReview(id);
  }
}
