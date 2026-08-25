import 'package:equatable/equatable.dart';

/// One weekly working window for a trainer, e.g. Monday 09:00-17:00.
///
/// These windows are what decides whether a booking counts as "outside trainer
/// availability" and therefore attracts the surcharge (review item 19).
class TrainerAvailability extends Equatable {
  final int id;
  final int trainerId;

  /// 0 = Sunday .. 6 = Saturday, matching System.DayOfWeek, which the API
  /// serialises as a plain integer.
  final int dayOfWeek;

  /// Stored as minutes past midnight so the UI can compare and format freely.
  final int startMinutes;
  final int endMinutes;

  const TrainerAvailability({
    required this.id,
    required this.trainerId,
    required this.dayOfWeek,
    required this.startMinutes,
    required this.endMinutes,
  });

  static const dayNames = [
    'Nedjelja', 'Ponedjeljak', 'Utorak', 'Srijeda', 'Četvrtak', 'Petak', 'Subota',
  ];

  String get dayName =>
      dayOfWeek >= 0 && dayOfWeek < dayNames.length ? dayNames[dayOfWeek] : '?';

  static String formatMinutes(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get startLabel => formatMinutes(startMinutes);
  String get endLabel => formatMinutes(endMinutes);

  @override
  List<Object?> get props => [id, trainerId, dayOfWeek, startMinutes, endMinutes];
}
