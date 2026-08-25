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
    super.isPaid,
    super.isOutsideTrainerAvailability,
    super.outsideAvailabilitySurcharge,
    super.allowedNextStatuses,
    super.cancelledAt,
    super.cancelledByUserId,
    super.cancellationReason,
    super.completedAt,
    super.userName,
    super.userEmail,
    super.trainingName,
    super.trainerName,
    super.additionalServiceIds,
    super.userMembershipId,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final training = json['training'] as Map<String, dynamic>?;

    final fullName = user == null ? null : '${user['name'] ?? ''} ${user['surname'] ?? ''}'.trim();

    return ReservationModel(
      id: json['id'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      reservationDate: DateTime.tryParse(json['reservationDate']?.toString() ?? '') ?? DateTime.now(),
      status: ReservationStatus.fromIndex(json['status'] ?? 0),
      reservationType: ReservationType.fromIndex(json['reservationType'] ?? 0),
      userId: json['userId'] ?? 0,
      trainingId: json['trainingId'] ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      isPaid: json['isPaid'] as bool? ?? false,
      isOutsideTrainerAvailability: json['isOutsideTrainerAvailability'] as bool? ?? false,
      outsideAvailabilitySurcharge: (json['outsideAvailabilitySurcharge'] as num?)?.toDouble() ?? 0.0,
      allowedNextStatuses: (json['allowedNextStatuses'] as List?)
              ?.map((e) => ReservationStatus.fromIndex(e as int))
              .toList() ??
          const [],
      cancelledAt: DateTime.tryParse(json['cancelledAt']?.toString() ?? ''),
      cancelledByUserId: json['cancelledByUserId'] as int?,
      cancellationReason: json['cancellationReason'] as String?,
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
      userName: (fullName != null && fullName.isNotEmpty) ? fullName : user?['userName'] as String?,
      userEmail: user?['email'] as String?,
      trainingName: training?['name'] as String?,
      trainerName: training?['trainerName'] as String?,
      additionalServiceIds:
          (json['additionalServiceIds'] as List?)?.map((e) => e as int).toList() ?? const [],
      userMembershipId: json['userMembershipId'] as int?,
    );
  }
}
