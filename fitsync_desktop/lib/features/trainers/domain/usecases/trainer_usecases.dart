import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/trainer.dart';
import '../repositories/trainers_repository.dart';

/// The trainer use cases are grouped in one file: each is a single delegation and
/// they are always registered together.
class GetTrainers {
  final TrainersRepository repository;
  GetTrainers(this.repository);
  Future<Either<Failure, List<Trainer>>> call() => repository.getTrainers();
}

class CreateTrainer {
  final TrainersRepository repository;
  CreateTrainer(this.repository);
  Future<Either<Failure, Trainer>> call(Trainer trainer) => repository.createTrainer(trainer);
}

class UpdateTrainer {
  final TrainersRepository repository;
  UpdateTrainer(this.repository);
  Future<Either<Failure, Trainer>> call(int id, Trainer trainer) =>
      repository.updateTrainer(id, trainer);
}

class DeleteTrainer {
  final TrainersRepository repository;
  DeleteTrainer(this.repository);
  Future<Either<Failure, void>> call(int id) => repository.deleteTrainer(id);
}

class AddTrainerAvailability {
  final TrainersRepository repository;
  AddTrainerAvailability(this.repository);
  Future<Either<Failure, void>> call({
    required int trainerId,
    required int dayOfWeek,
    required int startMinutes,
    required int endMinutes,
  }) =>
      repository.addAvailability(
        trainerId: trainerId,
        dayOfWeek: dayOfWeek,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
      );
}

class DeleteTrainerAvailability {
  final TrainersRepository repository;
  DeleteTrainerAvailability(this.repository);
  Future<Either<Failure, void>> call(int availabilityId) =>
      repository.deleteAvailability(availabilityId);
}
