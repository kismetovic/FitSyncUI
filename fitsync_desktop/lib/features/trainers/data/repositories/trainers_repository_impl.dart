import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/trainer.dart';
import '../../domain/repositories/trainers_repository.dart';
import '../datasources/trainers_remote_data_source.dart';
import '../models/trainer_model.dart';

class TrainersRepositoryImpl implements TrainersRepository {
  final TrainersRemoteDataSource remoteDataSource;

  TrainersRepositoryImpl({required this.remoteDataSource});

  TrainerModel _toModel(Trainer t) => TrainerModel(
        id: t.id,
        firstName: t.firstName,
        lastName: t.lastName,
        biography: t.biography,
        specialty: t.specialty,
        email: t.email,
        phoneNumber: t.phoneNumber,
        outsideAvailabilitySurcharge: t.outsideAvailabilitySurcharge,
        userId: t.userId,
      );

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Trainer>>> getTrainers() =>
      _guard(() => remoteDataSource.getTrainers());

  @override
  Future<Either<Failure, Trainer>> createTrainer(Trainer trainer) =>
      _guard(() => remoteDataSource.createTrainer(_toModel(trainer)));

  @override
  Future<Either<Failure, Trainer>> updateTrainer(int id, Trainer trainer) =>
      _guard(() => remoteDataSource.updateTrainer(id, _toModel(trainer)));

  @override
  Future<Either<Failure, void>> deleteTrainer(int id) =>
      _guard(() => remoteDataSource.deleteTrainer(id));

  @override
  Future<Either<Failure, void>> addAvailability({
    required int trainerId,
    required int dayOfWeek,
    required int startMinutes,
    required int endMinutes,
  }) =>
      _guard(() => remoteDataSource.addAvailability(
            trainerId: trainerId,
            dayOfWeek: dayOfWeek,
            startMinutes: startMinutes,
            endMinutes: endMinutes,
          ));

  @override
  Future<Either<Failure, void>> deleteAvailability(int availabilityId) =>
      _guard(() => remoteDataSource.deleteAvailability(availabilityId));
}
