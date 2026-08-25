import 'package:equatable/equatable.dart';

/// Free places for a training on a given day. The backend returns only aggregate
/// counts, so the calendar can show capacity without exposing who booked what.
class SlotAvailability extends Equatable {
  final DateTime date;
  final int bookedCount;
  final int maxCapacity;
  final int freeSlots;

  const SlotAvailability({
    required this.date,
    required this.bookedCount,
    required this.maxCapacity,
    required this.freeSlots,
  });

  bool get isFull => maxCapacity > 0 && freeSlots <= 0;

  @override
  List<Object?> get props => [date, bookedCount, maxCapacity, freeSlots];
}
