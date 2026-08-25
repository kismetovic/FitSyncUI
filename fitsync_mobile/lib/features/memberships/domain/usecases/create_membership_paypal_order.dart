import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/memberships_repository.dart';

/// Opens a PayPal order for a bought package. The amount is never sent: the
/// server reads it from the package, exactly as it does for a booking.
class CreateMembershipPayPalOrder implements UseCase<Map<String, dynamic>, int> {
  final MembershipsRepository repository;

  CreateMembershipPayPalOrder(this.repository);

  /// [params] is the user membership id.
  @override
  Future<Either<Failure, Map<String, dynamic>>> call(int params) =>
      repository.createPayPalOrder(params);
}
