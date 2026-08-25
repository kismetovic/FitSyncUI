import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../../../core/pagination/paged_result.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_remote_data_source.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;

  UsersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PagedResult<User>>> getUsers({
    String? searchQuery,
    String? role,
    int page = 1,
    int pageSize = kDefaultPageSize,
  }) async {
    try {
      final result = await remoteDataSource.getUsers(
          searchQuery: searchQuery, role: role, page: page, pageSize: pageSize);
      return Right(PagedResult<User>(
        items: result.items,
        page: result.page,
        pageSize: result.pageSize,
        totalCount: result.totalCount,
      ));
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message, e.code));
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(int id) async {
    try {
      final remoteUser = await remoteDataSource.getUserById(id);
      return Right(remoteUser);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message, e.code));
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(int id, {
    required String userName,
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    String? address,
    required String role,
    required bool enabled,
  }) async {
    try {
      final updatedUser = await remoteDataSource.updateUser(
        id,
        userName: userName,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        role: role,
        enabled: enabled,
      );
      return Right(updatedUser);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message, e.code));
    }
  }

  @override
  Future<Either<Failure, User>> createUser({
    required String userName,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required String role,
    required bool enabled,
  }) async {
    try {
      final created = await remoteDataSource.createUser(
        userName: userName,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        role: role,
        enabled: enabled,
      );
      return Right(created);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message, e.code));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(int id) async {
    try {
      await remoteDataSource.deleteUser(id);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message, e.code));
    }
  }

  @override
  Future<Either<Failure, void>> sendPaymentReminder(int userId) async {
    try {
      await remoteDataSource.sendPaymentReminder(userId);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message, e.code));
    }
  }
}
