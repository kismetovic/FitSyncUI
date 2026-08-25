import '../../domain/entities/trainer.dart';
import '../../domain/entities/trainer_availability.dart';

class TrainerAvailabilityModel extends TrainerAvailability {
  const TrainerAvailabilityModel({
    required super.id,
    required super.trainerId,
    required super.dayOfWeek,
    required super.startMinutes,
    required super.endMinutes,
  });

  /// The API has no custom JSON converters, so `DayOfWeek` arrives as an integer
  /// and `TimeSpan` as an `"HH:mm:ss"` string.
  static int parseTime(dynamic value) {
    if (value == null) return 0;
    final parts = value.toString().split(':');
    if (parts.length < 2) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  /// Back to the `"HH:mm:ss"` shape `TimeSpan` binds from.
  static String formatTime(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  factory TrainerAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return TrainerAvailabilityModel(
      id: json['id'] ?? 0,
      trainerId: json['trainerId'] ?? 0,
      dayOfWeek: json['dayOfWeek'] ?? 0,
      startMinutes: parseTime(json['startTime']),
      endMinutes: parseTime(json['endTime']),
    );
  }
}

class TrainerModel extends Trainer {
  const TrainerModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.biography,
    super.specialty,
    super.email,
    super.phoneNumber,
    super.outsideAvailabilitySurcharge,
    super.userId,
    super.availabilities,
  });

  factory TrainerModel.fromJson(Map<String, dynamic> json) {
    return TrainerModel(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      biography: json['biography'],
      specialty: json['specialty'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      outsideAvailabilitySurcharge:
          (json['outsideAvailabilitySurcharge'] as num?)?.toDouble() ?? 0,
      userId: json['userId'],
      availabilities: (json['availabilities'] as List?)
              ?.map((e) => TrainerAvailabilityModel.fromJson(e))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toRequestBody() => {
        'firstName': firstName,
        'lastName': lastName,
        'biography': biography,
        'specialty': specialty,
        'email': email,
        'phoneNumber': phoneNumber,
        'outsideAvailabilitySurcharge': outsideAvailabilitySurcharge,
        'userId': userId,
      };
}
