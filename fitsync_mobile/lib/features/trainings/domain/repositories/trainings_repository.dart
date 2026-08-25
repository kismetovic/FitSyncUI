import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/training.dart';
import '../entities/recommended_training.dart';

abstract class TrainingsRepository {
  Future<Either<Failure, List<Training>>> getTrainings([String? searchQuery]);
  Future<Either<Failure, List<RecommendedTraining>>> getRecommendations();
}
