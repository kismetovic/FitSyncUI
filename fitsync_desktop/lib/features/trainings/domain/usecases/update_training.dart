import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/training.dart';
import '../entities/training_difficulty.dart';
import '../repositories/trainings_repository.dart';

class UpdateTrainingParams extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final int maxCapacity;
  final TrainingDifficulty difficulty;
  final int trainingTypeId;

  const UpdateTrainingParams({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.maxCapacity,
    required this.difficulty,
    required this.trainingTypeId,
  });

  @override
  List<Object?> get props => [id, name, description, price, durationMinutes, maxCapacity, difficulty, trainingTypeId];
}

class UpdateTraining implements UseCase<Training, UpdateTrainingParams> {
  final TrainingsRepository repository;

  UpdateTraining(this.repository);

  @override
  Future<Either<Failure, Training>> call(UpdateTrainingParams params) async {
    return await repository.updateTraining(
      params.id,
      name: params.name,
      description: params.description,
      price: params.price,
      durationMinutes: params.durationMinutes,
      maxCapacity: params.maxCapacity,
      difficulty: params.difficulty,
      trainingTypeId: params.trainingTypeId,
    );
  }
}
