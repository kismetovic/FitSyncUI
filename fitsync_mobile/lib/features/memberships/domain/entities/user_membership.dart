import 'package:equatable/equatable.dart';

enum MembershipStatus {
  active,
  expired,
  cancelled,

  /// Bought but not paid for yet, so not usable. Buying used to hand out an
  /// active package on the spot with no payment at all.
  pendingPayment;

  static MembershipStatus fromIndex(int index) =>
      index >= 0 && index < MembershipStatus.values.length
          ? MembershipStatus.values[index]
          : MembershipStatus.expired;
}

/// A package the signed-in user has bought, with the sessions they have left.
class UserMembership extends Equatable {
  final int id;
  final int membershipPackageId;
  final String? membershipPackageName;
  final int? trainingTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final int sessionsTotal;
  final int sessionsUsed;
  final int sessionsRemaining;
  final MembershipStatus status;
  final double pricePaid;

  /// The backend's own verdict on whether this package can pay for a booking
  /// right now (active, in date, sessions left). The app never recomputes it.
  final bool isUsable;

  const UserMembership({
    required this.id,
    required this.membershipPackageId,
    this.membershipPackageName,
    this.trainingTypeId,
    required this.startDate,
    required this.endDate,
    required this.sessionsTotal,
    required this.sessionsUsed,
    required this.sessionsRemaining,
    required this.status,
    required this.pricePaid,
    required this.isUsable,
  });

  bool get coversAllTypes => trainingTypeId == null;

  /// Waiting to be paid for. The package exists but cannot cover a booking.
  bool get awaitingPayment => status == MembershipStatus.pendingPayment;

  /// Only an untouched package can be cancelled: reservations point at a package
  /// once it has covered them.
  bool get canBeCancelled =>
      status != MembershipStatus.cancelled && sessionsUsed == 0;

  /// Covers [typeId] if the package is unrestricted or restricted to that type.
  bool coversTrainingType(int typeId) => trainingTypeId == null || trainingTypeId == typeId;

  @override
  List<Object?> get props => [
        id,
        membershipPackageId,
        membershipPackageName,
        trainingTypeId,
        startDate,
        endDate,
        sessionsTotal,
        sessionsUsed,
        sessionsRemaining,
        status,
        pricePaid,
        isUsable,
      ];
}
