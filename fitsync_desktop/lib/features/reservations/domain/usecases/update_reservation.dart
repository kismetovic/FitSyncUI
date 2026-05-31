import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reservation.dart';
import '../entities/reservation_status.dart';
import '../repositories/reservations_repository.dart';

class UpdateReservationParams extends Equatable {
  final int id;
  final ReservationStatus status;

  const UpdateReservationParams({required this.id, required this.status});

  @override
  List<Object?> get props => [id, status];
}

class UpdateReservation implements UseCase<Reservation, UpdateReservationParams> {
  final ReservationsRepository repository;

  UpdateReservation(this.repository);

  @override
  Future<Either<Failure, Reservation>> call(UpdateReservationParams params) async {
    return await repository.updateReservationStatus(params.id, params.status);
  }
}
