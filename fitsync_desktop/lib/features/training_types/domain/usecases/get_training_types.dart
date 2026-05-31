import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/training_type.dart';
import '../repositories/training_types_repository.dart';

class GetTrainingTypes implements UseCase<List<TrainingType>, NoParams> {
  final TrainingTypesRepository repository;

  GetTrainingTypes(this.repository);

  @override
  Future<Either<Failure, List<TrainingType>>> call(NoParams params) async {
    return await repository.getTrainingTypes();
  }
}
