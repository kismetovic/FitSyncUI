import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_membership.dart';
import '../repositories/memberships_repository.dart';

/// Cancels a package the signed-in user owns. Whether it *may* be cancelled is
/// the server's decision: a package with sessions already spent is refused with
/// MEMBERSHIP_IN_USE.
class CancelMembership implements UseCase<UserMembership, int> {
  final MembershipsRepository repository;

  CancelMembership(this.repository);

  /// [params] is the user membership id.
  @override
  Future<Either<Failure, UserMembership>> call(int params) =>
      repository.cancel(params);
}
