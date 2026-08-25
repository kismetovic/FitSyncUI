import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/membership_package.dart';

abstract class MembershipsRepository {
  Future<Either<Failure, List<MembershipPackage>>> getPackages();
  Future<Either<Failure, MembershipPackage>> createPackage(MembershipPackage package);
  Future<Either<Failure, MembershipPackage>> updatePackage(int id, MembershipPackage package);
  Future<Either<Failure, void>> deletePackage(int id);
}
