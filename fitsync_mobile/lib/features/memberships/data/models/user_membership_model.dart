import '../../domain/entities/user_membership.dart';

class UserMembershipModel extends UserMembership {
  const UserMembershipModel({
    required super.id,
    required super.membershipPackageId,
    super.membershipPackageName,
    super.trainingTypeId,
    required super.startDate,
    required super.endDate,
    required super.sessionsTotal,
    required super.sessionsUsed,
    required super.sessionsRemaining,
    required super.status,
    required super.pricePaid,
    required super.isUsable,
  });

  factory UserMembershipModel.fromJson(Map<String, dynamic> json) {
    final total = json['sessionsTotal'] ?? 0;
    final used = json['sessionsUsed'] ?? 0;
    return UserMembershipModel(
      id: json['id'],
      membershipPackageId: json['membershipPackageId'] ?? 0,
      membershipPackageName: json['membershipPackageName'],
      trainingTypeId: json['trainingTypeId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      sessionsTotal: total,
      sessionsUsed: used,
      sessionsRemaining: json['sessionsRemaining'] ?? (total - used),
      status: MembershipStatus.fromIndex(json['status'] ?? 0),
      pricePaid: (json['pricePaid'] as num?)?.toDouble() ?? 0,
      isUsable: json['isUsable'] ?? false,
    );
  }
}
