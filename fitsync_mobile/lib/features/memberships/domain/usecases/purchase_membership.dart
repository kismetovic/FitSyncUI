import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_membership.dart';
import '../repositories/memberships_repository.dart';

class PurchaseMembership implements UseCase<UserMembership, int> {
  final MembershipsRepository repository;

  PurchaseMembership(this.repository);

  /// [params] is the membership package id. The price is the server's decision.
  @override
  Future<Either<Failure, UserMembership>> call(int params) async {
    return await repository.purchase(params);
  }
}
