import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/training_type.dart';
import '../repositories/training_types_repository.dart';

class CreateTrainingType {
  final TrainingTypesRepository repository;
  CreateTrainingType(this.repository);
  Future<Either<Failure, TrainingType>> call(String name) =>
      repository.createTrainingType(name);
}
