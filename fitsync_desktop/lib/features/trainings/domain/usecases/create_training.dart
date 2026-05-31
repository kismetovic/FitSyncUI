import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/training.dart';
import '../entities/training_difficulty.dart';
import '../repositories/trainings_repository.dart';

class CreateTrainingParams extends Equatable {
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final int maxCapacity;
  final TrainingDifficulty difficulty;
  final int trainingTypeId;

  const CreateTrainingParams({
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.maxCapacity,
    required this.difficulty,
    required this.trainingTypeId,
  });

  @override
  List<Object?> get props => [name, description, price, durationMinutes, maxCapacity, difficulty, trainingTypeId];
}

class CreateTraining implements UseCase<Training, CreateTrainingParams> {
  final TrainingsRepository repository;

  CreateTraining(this.repository);

  @override
  Future<Either<Failure, Training>> call(CreateTrainingParams params) async {
    return await repository.createTraining(
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
