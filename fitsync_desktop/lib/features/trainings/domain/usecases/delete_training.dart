import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/trainings_repository.dart';

class DeleteTraining implements UseCase<void, int> {
  final TrainingsRepository repository;

  DeleteTraining(this.repository);

  @override
  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteTraining(id);
  }
}
