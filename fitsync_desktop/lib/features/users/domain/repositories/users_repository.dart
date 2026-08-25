import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../../../../core/pagination/paged_result.dart';

abstract class UsersRepository {
  Future<Either<Failure, PagedResult<User>>> getUsers({String? searchQuery, String? role, int page, int pageSize});
  Future<Either<Failure, User>> getUserById(int id);

  Future<Either<Failure, User>> updateUser(int id, {
    required String userName,
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    String? address,
    required String role,
    required bool enabled,
  });

  Future<Either<Failure, User>> createUser({
    required String userName,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required String role,
    required bool enabled,
  });

  Future<Either<Failure, void>> deleteUser(int id);
  Future<Either<Failure, void>> sendPaymentReminder(int userId);
}
