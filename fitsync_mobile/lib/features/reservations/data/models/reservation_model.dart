import '../../domain/entities/reservation.dart';
import '../../domain/entities/reservation_status.dart';
import '../../domain/entities/reservation_type.dart';

class ReservationModel extends Reservation {
  const ReservationModel({
    required super.id,
    required super.createdAt,
    required super.reservationDate,
    required super.status,
    required super.reservationType,
    required super.userId,
    required super.trainingId,
    super.userName,
    super.trainingName,
    super.trainingPrice,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      reservationDate: DateTime.tryParse(json['reservationDate'] ?? '') ?? DateTime.now(),
      status: ReservationStatus.fromIndex(json['status'] ?? 0),
      reservationType: ReservationType.fromIndex(json['reservationType'] ?? 0),
      userId: json['userId'],
      trainingId: json['trainingId'],
      userName: json['user'] != null
          ? '${json['user']['name'] ?? ''} ${json['user']['surname'] ?? ''}'.trim()
          : null,
      trainingName: json['training']?['name'],
      trainingPrice: (json['training']?['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'trainingId': trainingId,
    'reservationDate': reservationDate.toIso8601String(),
    'reservationType': reservationType.index,
    'status': status.index,
    'userId': userId,
  };
}
