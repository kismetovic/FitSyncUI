import 'package:equatable/equatable.dart';

/// A monthly package the gym sells: a number of sessions valid for a number of
/// days, optionally restricted to a single training type.
class MembershipPackage extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int durationDays;
  final int sessionCount;
  final double price;
  final int? trainingTypeId;
  final String? trainingTypeName;
  final bool isActive;
  final double pricePerSession;

  const MembershipPackage({
    required this.id,
    required this.name,
    this.description,
    required this.durationDays,
    required this.sessionCount,
    required this.price,
    this.trainingTypeId,
    this.trainingTypeName,
    required this.isActive,
    required this.pricePerSession,
  });

  bool get coversAllTypes => trainingTypeId == null;

  @override
  List<Object?> get props => [
        id, name, description, durationDays, sessionCount, price,
        trainingTypeId, trainingTypeName, isActive, pricePerSession,
      ];
}
