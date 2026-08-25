import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/users_repository.dart';

class UpdateUserParams extends Equatable {
  final int id;
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String role;

  /// Carried explicitly rather than defaulted, so an edit can never flip an
  /// account back to enabled as a side effect.
  final bool enabled;

  const UpdateUserParams({
    required this.id,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.enabled,
  });

  @override
  List<Object?> get props =>
      [id, userName, firstName, lastName, email, phoneNumber, role, enabled];
}

class UpdateUser {
  final UsersRepository repository;
  UpdateUser(this.repository);

  Future<Either<Failure, User>> call(UpdateUserParams params) =>
      repository.updateUser(
        params.id,
        userName: params.userName,
        firstName: params.firstName,
        lastName: params.lastName,
        email: params.email,
        phoneNumber: params.phoneNumber,
        role: params.role,
        enabled: params.enabled,
      );
}
