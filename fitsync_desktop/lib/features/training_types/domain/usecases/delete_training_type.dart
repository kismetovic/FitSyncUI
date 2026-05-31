import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/training_types_repository.dart';

class DeleteTrainingType {
  final TrainingTypesRepository repository;
  DeleteTrainingType(this.repository);
  Future<Either<Failure, void>> call(int id) =>
      repository.deleteTrainingType(id);
}
