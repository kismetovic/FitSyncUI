import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/memberships_repository.dart';

class DeleteMembershipPackage {
  final MembershipsRepository repository;
  DeleteMembershipPackage(this.repository);
  Future<Either<Failure, void>> call(int id) => repository.deletePackage(id);
}
