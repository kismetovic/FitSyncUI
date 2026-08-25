import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/membership_package.dart';
import '../repositories/memberships_repository.dart';

class UpdateMembershipPackage {
  final MembershipsRepository repository;
  UpdateMembershipPackage(this.repository);
  Future<Either<Failure, MembershipPackage>> call(int id, MembershipPackage package) =>
      repository.updatePackage(id, package);
}
