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

  /// Price calculated by the server at booking time. The app displays this and pays
  /// exactly this; it never computes an amount of its own.
  final double totalPrice;

  final bool isOutsideTrainerAvailability;
  final double outsideAvailabilitySurcharge;
  final int? userMembershipId;

  /// True once the backend has recorded a captured payment.
  final bool isPaid;

  /// Statuses the server will accept next. Drives which action buttons are shown.
  final List<ReservationStatus> allowedNextStatuses;

  final DateTime? cancelledAt;
  final int? cancelledByUserId;
  final String? cancellationReason;
  final DateTime? completedAt;

  final String? userName;
  final String? trainingName;
  final double? trainingPrice;
  final int? trainingDurationMinutes;
  final String? trainerName;
  final List<int> additionalServiceIds;

  const Reservation({
    required this.id,
    required this.createdAt,
    required this.reservationDate,
    required this.status,
    required this.reservationType,
    required this.userId,
    required this.trainingId,
    this.totalPrice = 0,
    this.isOutsideTrainerAvailability = false,
    this.outsideAvailabilitySurcharge = 0,
    this.userMembershipId,
    this.isPaid = false,
    this.allowedNextStatuses = const [],
    this.cancelledAt,
    this.cancelledByUserId,
    this.cancellationReason,
    this.completedAt,
    this.userName,
    this.trainingName,
    this.trainingPrice,
    this.trainingDurationMinutes,
    this.trainerName,
    this.additionalServiceIds = const [],
  });

  /// A reservation can only be cancelled while the server still allows that transition.
  bool get canBeCancelled => allowedNextStatuses.contains(ReservationStatus.cancelled);

  /// Payment is possible once the reservation is not waiting for approval and not paid.
  bool get canBePaid =>
      !isPaid &&
      status != ReservationStatus.cancelled &&
      status != ReservationStatus.pendingApproval &&
      status != ReservationStatus.completed &&
      totalPrice > 0;

  /// Reviews are only accepted for a training the user actually attended.
  bool get canBeReviewed => status == ReservationStatus.completed;

  bool get isCoveredByMembership => userMembershipId != null;

  @override
  List<Object?> get props =>
      [id, createdAt, reservationDate, status, reservationType, userId, trainingId, totalPrice, isPaid];
}
