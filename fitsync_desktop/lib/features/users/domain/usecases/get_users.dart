import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/users_repository.dart';

class GetUsers implements UseCase<List<User>, String?> {
  final UsersRepository repository;

  GetUsers(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(String? searchQuery) async {
    return await repository.getUsers(searchQuery);
  }
}
