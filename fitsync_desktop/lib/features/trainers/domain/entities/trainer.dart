import 'package:equatable/equatable.dart';
import 'trainer_availability.dart';

class Trainer extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String? biography;
  final String? specialty;
  final String? email;
  final String? phoneNumber;

  /// Added to a booking that falls outside every availability window.
  final double outsideAvailabilitySurcharge;

  final int? userId;
  final List<TrainerAvailability> availabilities;

  const Trainer({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.biography,
    this.specialty,
    this.email,
    this.phoneNumber,
    this.outsideAvailabilitySurcharge = 0,
    this.userId,
    this.availabilities = const [],
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        id, firstName, lastName, biography, specialty, email, phoneNumber,
        outsideAvailabilitySurcharge, userId, availabilities,
      ];
}
