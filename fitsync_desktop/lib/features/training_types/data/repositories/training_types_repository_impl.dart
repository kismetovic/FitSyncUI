import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/training_type.dart';
import '../../domain/repositories/training_types_repository.dart';
import '../datasources/training_types_remote_data_source.dart';

class TrainingTypesRepositoryImpl implements TrainingTypesRepository {
  final TrainingTypesRemoteDataSource remoteDataSource;

  TrainingTypesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TrainingType>>> getTrainingTypes() async {
    try {
      final result = await remoteDataSource.getTrainingTypes();
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, TrainingType>> createTrainingType(String name) async {
    try {
      final result = await remoteDataSource.createTrainingType(name);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, TrainingType>> updateTrainingType(int id, String name) async {
    try {
      final result = await remoteDataSource.updateTrainingType(id, name);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteTrainingType(int id) async {
    try {
      await remoteDataSource.deleteTrainingType(id);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    }
  }
}
