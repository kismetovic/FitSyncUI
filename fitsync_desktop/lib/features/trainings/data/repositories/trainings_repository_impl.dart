import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/training.dart';
import '../../domain/entities/training_difficulty.dart';
import '../../domain/repositories/trainings_repository.dart';
import '../datasources/trainings_remote_data_source.dart';

class TrainingsRepositoryImpl implements TrainingsRepository {
  final TrainingsRemoteDataSource remoteDataSource;

  TrainingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Training>>> getTrainings([String? searchQuery]) async {
    try {
      final result = await remoteDataSource.getTrainings(searchQuery);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Training>> createTraining({
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    required int maxCapacity,
    required TrainingDifficulty difficulty,
    required int trainingTypeId,
  }) async {
    try {
      final result = await remoteDataSource.createTraining(
        name: name,
        description: description,
        price: price,
        durationMinutes: durationMinutes,
        maxCapacity: maxCapacity,
        difficulty: difficulty,
        trainingTypeId: trainingTypeId,
      );
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Training>> updateTraining(int id, {
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    required int maxCapacity,
    required TrainingDifficulty difficulty,
    required int trainingTypeId,
  }) async {
    try {
      final result = await remoteDataSource.updateTraining(
        id,
        name: name,
        description: description,
        price: price,
        durationMinutes: durationMinutes,
        maxCapacity: maxCapacity,
        difficulty: difficulty,
        trainingTypeId: trainingTypeId,
      );
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteTraining(int id) async {
    try {
      await remoteDataSource.deleteTraining(id);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    }
  }
}
