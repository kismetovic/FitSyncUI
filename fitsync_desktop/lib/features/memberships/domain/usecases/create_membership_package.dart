import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/membership_package.dart';
import '../repositories/memberships_repository.dart';

class CreateMembershipPackage {
  final MembershipsRepository repository;
  CreateMembershipPackage(this.repository);
  Future<Either<Failure, MembershipPackage>> call(MembershipPackage package) =>
      repository.createPackage(package);
}
