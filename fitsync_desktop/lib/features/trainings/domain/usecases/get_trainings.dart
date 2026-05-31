import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/training.dart';
import '../../domain/repositories/trainings_repository.dart';

class GetTrainings implements UseCase<List<Training>, String?> {
  final TrainingsRepository repository;

  GetTrainings(this.repository);

  @override
  Future<Either<Failure, List<Training>>> call(String? searchQuery) async {
    return await repository.getTrainings(searchQuery);
  }
}
