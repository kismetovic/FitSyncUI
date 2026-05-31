import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/training_type.dart';
import '../repositories/training_types_repository.dart';

class UpdateTrainingType {
  final TrainingTypesRepository repository;
  UpdateTrainingType(this.repository);
  Future<Either<Failure, TrainingType>> call(int id, String name) =>
      repository.updateTrainingType(id, name);
}
