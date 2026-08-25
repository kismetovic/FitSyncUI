import '../../domain/entities/membership_package.dart';

class MembershipPackageModel extends MembershipPackage {
  const MembershipPackageModel({
    required super.id,
    required super.name,
    super.description,
    required super.durationDays,
    required super.sessionCount,
    required super.price,
    super.trainingTypeId,
    super.trainingTypeName,
    required super.isActive,
    required super.pricePerSession,
  });

  factory MembershipPackageModel.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num?)?.toDouble() ?? 0;
    final sessions = json['sessionCount'] ?? 0;
    return MembershipPackageModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      durationDays: json['durationDays'] ?? 30,
      sessionCount: sessions,
      price: price,
      trainingTypeId: json['trainingTypeId'],
      trainingTypeName: json['trainingTypeName'],
      isActive: json['isActive'] ?? true,
      pricePerSession: (json['pricePerSession'] as num?)?.toDouble() ??
          (sessions > 0 ? price / sessions : 0),
    );
  }
}
