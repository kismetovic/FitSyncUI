import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/training.dart';
import '../../domain/entities/recommended_training.dart';
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
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecommendedTraining>>> getRecommendations() async {
    try {
      final result = await remoteDataSource.getRecommendations();
      return Right(result);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
