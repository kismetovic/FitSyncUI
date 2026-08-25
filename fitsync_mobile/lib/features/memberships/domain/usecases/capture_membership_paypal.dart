import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/memberships_repository.dart';

/// Asks the server to capture and verify a PayPal order for a package. The app
/// never decides that a payment succeeded; it only asks the server to look.
class CaptureMembershipPayPal {
  final MembershipsRepository repository;

  CaptureMembershipPayPal(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String orderId,
    required int membershipId,
  }) =>
      repository.capturePayPal(orderId, membershipId);
}
