import '../../domain/entities/slot_availability.dart';

class SlotAvailabilityModel extends SlotAvailability {
  const SlotAvailabilityModel({
    required super.date,
    required super.bookedCount,
    required super.maxCapacity,
    required super.freeSlots,
  });

  factory SlotAvailabilityModel.fromJson(Map<String, dynamic> json) => SlotAvailabilityModel(
        date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        bookedCount: json['bookedCount'] as int? ?? 0,
        maxCapacity: json['maxCapacity'] as int? ?? 0,
        freeSlots: json['freeSlots'] as int? ?? 0,
      );
}
