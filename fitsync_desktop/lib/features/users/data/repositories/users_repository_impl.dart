import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_remote_data_source.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;

  UsersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<User>>> getUsers([String? searchQuery]) async {
    try {
      final remoteUsers = await remoteDataSource.getUsers(searchQuery);
      return Right(remoteUsers);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(int id) async {
    try {
      final remoteUser = await remoteDataSource.getUserById(id);
      return Right(remoteUser);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(int id, {
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    String? address,
    required String role,
  }) async {
    try {
      final updatedUser = await remoteDataSource.updateUser(
        id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        role: role,
      );
      return Right(updatedUser);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(int id) async {
    try {
      await remoteDataSource.deleteUser(id);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendPaymentReminder(int userId) async {
    try {
      await remoteDataSource.sendPaymentReminder(userId);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
