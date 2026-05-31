import 'package:equatable/equatable.dart';
import 'reservation_status.dart';
import 'reservation_type.dart';

class Reservation extends Equatable {
  final int id;
  final DateTime createdAt;
  final DateTime reservationDate;
  final ReservationStatus status;
  final ReservationType reservationType;
  final int userId;
  final int trainingId;
  final String? userName;
  final String? trainingName;

  const Reservation({
    required this.id,
    required this.createdAt,
    required this.reservationDate,
    required this.status,
    required this.reservationType,
    required this.userId,
    required this.trainingId,
    this.userName,
    this.trainingName,
  });

  @override
  List<Object?> get props => [id, createdAt, reservationDate, status, reservationType, userId, trainingId, userName, trainingName];
}
