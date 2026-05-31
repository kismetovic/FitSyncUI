import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/reservations_repository.dart';

class CancelReservation implements UseCase<void, int> {
  final ReservationsRepository repository;

  CancelReservation(this.repository);

  @override
  Future<Either<Failure, void>> call(int id) async {
    return await repository.cancelReservation(id);
  }
}
