import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reservation.dart';
import '../repositories/reservations_repository.dart';

class GetMyReservations implements UseCase<List<Reservation>, NoParams> {
  final ReservationsRepository repository;

  GetMyReservations(this.repository);

  @override
  Future<Either<Failure, List<Reservation>>> call(NoParams params) async {
    return await repository.getMyReservations();
  }
}
