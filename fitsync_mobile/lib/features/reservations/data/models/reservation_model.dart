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
    super.totalPrice,
    super.isOutsideTrainerAvailability,
    super.outsideAvailabilitySurcharge,
    super.userMembershipId,
    super.isPaid,
    super.allowedNextStatuses,
    super.cancelledAt,
    super.cancelledByUserId,
    super.cancellationReason,
    super.completedAt,
    super.userName,
    super.trainingName,
    super.trainingPrice,
    super.trainingDurationMinutes,
    super.trainerName,
    super.additionalServiceIds,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final training = json['training'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;

    return ReservationModel(
      id: json['id'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      reservationDate: DateTime.tryParse(json['reservationDate']?.toString() ?? '') ?? DateTime.now(),
      status: ReservationStatus.fromIndex(json['status'] ?? 0),
      reservationType: ReservationType.fromIndex(json['reservationType'] ?? 0),
      userId: json['userId'] ?? 0,
      trainingId: json['trainingId'] ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      isOutsideTrainerAvailability: json['isOutsideTrainerAvailability'] as bool? ?? false,
      outsideAvailabilitySurcharge: (json['outsideAvailabilitySurcharge'] as num?)?.toDouble() ?? 0.0,
      userMembershipId: json['userMembershipId'] as int?,
      isPaid: json['isPaid'] as bool? ?? false,
      allowedNextStatuses: (json['allowedNextStatuses'] as List?)
              ?.map((e) => ReservationStatus.fromIndex(e as int))
              .toList() ??
          const [],
      cancelledAt: DateTime.tryParse(json['cancelledAt']?.toString() ?? ''),
      cancelledByUserId: json['cancelledByUserId'] as int?,
      cancellationReason: json['cancellationReason'] as String?,
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
      userName: user != null ? '${user['name'] ?? ''} ${user['surname'] ?? ''}'.trim() : null,
      trainingName: training?['name'] as String?,
      trainingPrice: (training?['price'] as num?)?.toDouble(),
      trainingDurationMinutes: training?['durationMinutes'] as int?,
      trainerName: training?['trainerName'] as String?,
      additionalServiceIds:
          (json['additionalServiceIds'] as List?)?.map((e) => e as int).toList() ?? const [],
    );
  }
}
