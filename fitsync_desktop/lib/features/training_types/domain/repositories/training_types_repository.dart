import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/training_type.dart';

abstract class TrainingTypesRepository {
  Future<Either<Failure, List<TrainingType>>> getTrainingTypes();
  Future<Either<Failure, TrainingType>> createTrainingType(String name);
  Future<Either<Failure, TrainingType>> updateTrainingType(int id, String name);
  Future<Either<Failure, void>> deleteTrainingType(int id);
}
