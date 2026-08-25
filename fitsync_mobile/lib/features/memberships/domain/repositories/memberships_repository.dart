import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/membership_package.dart';
import '../entities/user_membership.dart';

abstract class MembershipsRepository {
  Future<Either<Failure, List<MembershipPackage>>> getPackages();
  Future<Either<Failure, List<UserMembership>>> getMyMemberships();
  Future<Either<Failure, UserMembership>> purchase(int packageId);

  Future<Either<Failure, UserMembership>> cancel(int membershipId);

  /// Starts a PayPal order for a bought package; returns the approval url and
  /// the order id the capture step needs.
  Future<Either<Failure, Map<String, dynamic>>> createPayPalOrder(int membershipId);

  Future<Either<Failure, Map<String, dynamic>>> capturePayPal(String orderId, int membershipId);

  Future<Either<Failure, void>> selectCash(int membershipId);
}
