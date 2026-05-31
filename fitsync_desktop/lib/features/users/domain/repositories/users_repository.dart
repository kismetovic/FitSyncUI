import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class UsersRepository {
  Future<Either<Failure, List<User>>> getUsers([String? searchQuery]);
  Future<Either<Failure, User>> getUserById(int id);

  Future<Either<Failure, User>> updateUser(int id, {
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    String? address,
    required String role,
  });
  Future<Either<Failure, void>> deleteUser(int id);
  Future<Either<Failure, void>> sendPaymentReminder(int userId);
}
