import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/trainer.dart';

abstract class TrainersRepository {
  Future<Either<Failure, List<Trainer>>> getTrainers();
  Future<Either<Failure, Trainer>> createTrainer(Trainer trainer);
  Future<Either<Failure, Trainer>> updateTrainer(int id, Trainer trainer);
  Future<Either<Failure, void>> deleteTrainer(int id);

  Future<Either<Failure, void>> addAvailability({
    required int trainerId,
    required int dayOfWeek,
    required int startMinutes,
    required int endMinutes,
  });
  Future<Either<Failure, void>> deleteAvailability(int availabilityId);
}
