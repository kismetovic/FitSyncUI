import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/users_repository.dart';

class UpdateUserParams extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String role;

  const UpdateUserParams({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    required this.role,
  });

  @override
  List<Object?> get props => [id, firstName, lastName, email, phoneNumber, role];
}

class UpdateUser {
  final UsersRepository repository;
  UpdateUser(this.repository);

  Future<Either<Failure, User>> call(UpdateUserParams params) =>
      repository.updateUser(
        params.id,
        firstName: params.firstName,
        lastName: params.lastName,
        email: params.email,
        phoneNumber: params.phoneNumber,
        role: params.role,
      );
}
