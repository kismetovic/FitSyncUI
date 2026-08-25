import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/recommended_training.dart';
import '../repositories/trainings_repository.dart';

class GetRecommendations implements UseCase<List<RecommendedTraining>, NoParams> {
  final TrainingsRepository repository;

  GetRecommendations(this.repository);

  @override
  Future<Either<Failure, List<RecommendedTraining>>> call(NoParams params) async {
    return await repository.getRecommendations();
  }
}
