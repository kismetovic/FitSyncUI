import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/training.dart';
import '../repositories/trainings_repository.dart';

class GetTrainings implements UseCase<List<Training>, String?> {
  final TrainingsRepository repository;

  GetTrainings(this.repository);

  @override
  Future<Either<Failure, List<Training>>> call(String? searchQuery) async {
    return await repository.getTrainings(searchQuery);
  }
}
