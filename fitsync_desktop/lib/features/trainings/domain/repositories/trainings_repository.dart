import 'package:dartz/dartz.dart';
import '../../../../core/pagination/paged_result.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/training.dart';
import '../../domain/entities/training_difficulty.dart';

abstract class TrainingsRepository {
  Future<Either<Failure, PagedResult<Training>>> getTrainings({String? searchQuery, int page, int pageSize});
  Future<Either<Failure, Training>> createTraining({
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    required int maxCapacity,
    required TrainingDifficulty difficulty,
    required int trainingTypeId,
  });
  Future<Either<Failure, Training>> updateTraining(int id, {
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    required int maxCapacity,
    required TrainingDifficulty difficulty,
    required int trainingTypeId,
  });
  Future<Either<Failure, void>> deleteTraining(int id);
}
