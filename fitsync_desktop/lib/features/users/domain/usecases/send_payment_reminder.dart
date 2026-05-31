import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/users_repository.dart';

class SendPaymentReminder implements UseCase<void, int> {
  final UsersRepository repository;

  SendPaymentReminder(this.repository);

  @override
  Future<Either<Failure, void>> call(int userId) async {
    return await repository.sendPaymentReminder(userId);
  }
}
