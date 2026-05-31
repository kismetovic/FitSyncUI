import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/users_repository.dart';

class DeleteUser implements UseCase<void, int> {
  final UsersRepository repository;

  DeleteUser(this.repository);

  @override
  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteUser(id);
  }
}
