import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/membership_package.dart';
import '../../domain/entities/user_membership.dart';
import '../../domain/repositories/memberships_repository.dart';
import '../datasources/memberships_remote_data_source.dart';

class MembershipsRepositoryImpl implements MembershipsRepository {
  final MembershipsRemoteDataSource remoteDataSource;

  MembershipsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MembershipPackage>>> getPackages() async {
    try {
      return Right(await remoteDataSource.getPackages());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserMembership>>> getMyMemberships() async {
    try {
      return Right(await remoteDataSource.getMyMemberships());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserMembership>> purchase(int packageId) async {
    try {
      return Right(await remoteDataSource.purchase(packageId));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserMembership>> cancel(int membershipId) =>
      _guard(() => remoteDataSource.cancel(membershipId));

  @override
  Future<Either<Failure, Map<String, dynamic>>> createPayPalOrder(int membershipId) =>
      _guard(() => remoteDataSource.createPayPalOrder(membershipId));

  @override
  Future<Either<Failure, Map<String, dynamic>>> capturePayPal(String orderId, int membershipId) =>
      _guard(() => remoteDataSource.capturePayPal(orderId, membershipId));

  @override
  Future<Either<Failure, void>> selectCash(int membershipId) =>
      _guard(() => remoteDataSource.selectCash(membershipId));

  /// The same try/catch every call above needs: a Failure passes through with its
  /// code intact, anything else becomes a generic ServerFailure.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
