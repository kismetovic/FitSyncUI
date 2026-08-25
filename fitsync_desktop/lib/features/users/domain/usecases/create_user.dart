import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/users_repository.dart';

class CreateUserParams extends Equatable {
  final String userName;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String role;
  final bool enabled;

  const CreateUserParams({
    required this.userName,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.role,
    this.enabled = true,
  });

  @override
  List<Object?> get props =>
      [userName, email, password, firstName, lastName, phoneNumber, role, enabled];
}

class CreateUser {
  final UsersRepository repository;
  CreateUser(this.repository);

  Future<Either<Failure, User>> call(CreateUserParams params) => repository.createUser(
        userName: params.userName,
        email: params.email,
        password: params.password,
        firstName: params.firstName,
        lastName: params.lastName,
        phoneNumber: params.phoneNumber,
        role: params.role,
        enabled: params.enabled,
      );
}
