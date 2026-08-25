import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/membership_package.dart';
import '../repositories/memberships_repository.dart';

class GetMembershipPackages implements UseCase<List<MembershipPackage>, NoParams> {
  final MembershipsRepository repository;

  GetMembershipPackages(this.repository);

  @override
  Future<Either<Failure, List<MembershipPackage>>> call(NoParams params) async {
    return await repository.getPackages();
  }
}
