import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/membership_package.dart';
import '../../domain/repositories/memberships_repository.dart';
import '../datasources/memberships_remote_data_source.dart';
import '../models/membership_package_model.dart';

class MembershipsRepositoryImpl implements MembershipsRepository {
  final MembershipsRemoteDataSource remoteDataSource;

  MembershipsRepositoryImpl({required this.remoteDataSource});

  /// The data source speaks in models; the domain speaks in entities.
  MembershipPackageModel _toModel(MembershipPackage p) => MembershipPackageModel(
        id: p.id,
        name: p.name,
        description: p.description,
        durationDays: p.durationDays,
        sessionCount: p.sessionCount,
        price: p.price,
        trainingTypeId: p.trainingTypeId,
        trainingTypeName: p.trainingTypeName,
        isActive: p.isActive,
        pricePerSession: p.pricePerSession,
      );

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
  Future<Either<Failure, MembershipPackage>> createPackage(MembershipPackage package) async {
    try {
      return Right(await remoteDataSource.createPackage(_toModel(package)));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MembershipPackage>> updatePackage(int id, MembershipPackage package) async {
    try {
      return Right(await remoteDataSource.updatePackage(id, _toModel(package)));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePackage(int id) async {
    try {
      await remoteDataSource.deletePackage(id);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
