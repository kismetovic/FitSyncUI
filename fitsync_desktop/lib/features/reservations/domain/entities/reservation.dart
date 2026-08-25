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

  /// Server-calculated total, including additional services and any out-of-hours
  /// surcharge. The desktop app displays it and never recomputes it.
  final double totalPrice;

  final bool isPaid;
  final bool isOutsideTrainerAvailability;
  final double outsideAvailabilitySurcharge;

  /// Statuses the backend will accept next. The action buttons are driven by this,
  /// so the UI cannot offer a transition the state machine would reject.
  final List<ReservationStatus> allowedNextStatuses;

  final DateTime? cancelledAt;
  final int? cancelledByUserId;
  final String? cancellationReason;
  final DateTime? completedAt;

  final String? userName;
  final String? userEmail;
  final String? trainingName;
  final String? trainerName;

  /// Additional services booked with this reservation. Every read path on the
  /// API includes them now, so the admin list can show them like the client does.
  final List<int> additionalServiceIds;

  /// Set when the booking was paid out of a monthly package instead of money.
  final int? userMembershipId;

  const Reservation({
    required this.id,
    required this.createdAt,
    required this.reservationDate,
    required this.status,
    required this.reservationType,
    required this.userId,
    required this.trainingId,
    this.totalPrice = 0,
    this.isPaid = false,
    this.isOutsideTrainerAvailability = false,
    this.outsideAvailabilitySurcharge = 0,
    this.allowedNextStatuses = const [],
    this.cancelledAt,
    this.cancelledByUserId,
    this.cancellationReason,
    this.completedAt,
    this.userName,
    this.userEmail,
    this.trainingName,
    this.trainerName,
    this.additionalServiceIds = const [],
    this.userMembershipId,
  });

  bool get canApprove => allowedNextStatuses.contains(ReservationStatus.approved);
  bool get canComplete => allowedNextStatuses.contains(ReservationStatus.completed);
  bool get canCancel => allowedNextStatuses.contains(ReservationStatus.cancelled);

  /// Staff can record a cash payment while the reservation is still unpaid and open.
  bool get canConfirmCash =>
      !isPaid &&
      status != ReservationStatus.cancelled &&
      status != ReservationStatus.completed &&
      status != ReservationStatus.pendingApproval &&
      totalPrice > 0;

  @override
  List<Object?> get props =>
      [id, createdAt, reservationDate, status, reservationType, userId, trainingId, totalPrice,
        isPaid, additionalServiceIds, userMembershipId];
}
