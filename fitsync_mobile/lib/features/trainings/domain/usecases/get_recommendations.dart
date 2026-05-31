import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/training.dart';
import '../repositories/trainings_repository.dart';

class GetRecommendations implements UseCase<List<Training>, NoParams> {
  final TrainingsRepository repository;

  GetRecommendations(this.repository);

  @override
  Future<Either<Failure, List<Training>>> call(NoParams params) async {
    return await repository.getRecommendations();
  }
}
