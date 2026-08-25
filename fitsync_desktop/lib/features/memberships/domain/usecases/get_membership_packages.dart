import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/membership_package.dart';
import '../repositories/memberships_repository.dart';

class GetMembershipPackages {
  final MembershipsRepository repository;
  GetMembershipPackages(this.repository);
  Future<Either<Failure, List<MembershipPackage>>> call() => repository.getPackages();
}
