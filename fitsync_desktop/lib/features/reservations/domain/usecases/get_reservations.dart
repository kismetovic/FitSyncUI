import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservations_repository.dart';

class GetReservations implements UseCase<List<Reservation>, NoParams> {
  final ReservationsRepository repository;

  GetReservations(this.repository);

  @override
  Future<Either<Failure, List<Reservation>>> call(NoParams params) async {
    return await repository.getReservations();
  }
}
