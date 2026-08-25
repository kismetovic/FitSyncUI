import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_membership.dart';
import '../repositories/memberships_repository.dart';

class GetMyMemberships implements UseCase<List<UserMembership>, NoParams> {
  final MembershipsRepository repository;

  GetMyMemberships(this.repository);

  @override
  Future<Either<Failure, List<UserMembership>>> call(NoParams params) async {
    return await repository.getMyMemberships();
  }
}
