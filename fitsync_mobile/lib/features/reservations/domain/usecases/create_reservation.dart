import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reservation.dart';
import '../entities/reservation_type.dart';
import '../repositories/reservations_repository.dart';

class CreateReservationParams extends Equatable {
  final int trainingId;
  final DateTime reservationDate;
  final ReservationType reservationType;
  final List<int> additionalServiceIds;

  /// Ask for a slot outside the trainer's working hours. The backend verifies this
  /// and, if it really is out of hours, applies a surcharge and requires approval.
  final bool requestOutsideAvailability;

  /// Monthly package to draw this session from, for Monthly reservations.
  final int? userMembershipId;

  const CreateReservationParams({
    required this.trainingId,
    required this.reservationDate,
    required this.reservationType,
    this.additionalServiceIds = const [],
    this.requestOutsideAvailability = false,
    this.userMembershipId,
  });

  @override
  List<Object?> get props => [
        trainingId,
        reservationDate,
        reservationType,
        additionalServiceIds,
        requestOutsideAvailability,
        userMembershipId,
      ];
}

class CreateReservation implements UseCase<Reservation, CreateReservationParams> {
  final ReservationsRepository repository;

  CreateReservation(this.repository);

  @override
  Future<Either<Failure, Reservation>> call(CreateReservationParams params) =>
      repository.createReservation(
        trainingId: params.trainingId,
        reservationDate: params.reservationDate,
        reservationType: params.reservationType,
        additionalServiceIds: params.additionalServiceIds,
        requestOutsideAvailability: params.requestOutsideAvailability,
        userMembershipId: params.userMembershipId,
      );
}
