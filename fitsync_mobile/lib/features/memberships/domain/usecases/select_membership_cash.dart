import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/memberships_repository.dart';

/// Records that the client intends to pay for a package at the desk. The package
/// stays unusable until staff confirm the cash was taken.
class SelectMembershipCash implements UseCase<void, int> {
  final MembershipsRepository repository;

  SelectMembershipCash(this.repository);

  /// [params] is the user membership id.
  @override
  Future<Either<Failure, void>> call(int params) => repository.selectCash(params);
}
