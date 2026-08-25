import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/paypal_order.dart';
import '../repositories/payments_repository.dart';

class CapturePayPalOrderParams extends Equatable {
  final String orderId;
  final int reservationId;

  const CapturePayPalOrderParams({required this.orderId, required this.reservationId});

  @override
  List<Object?> get props => [orderId, reservationId];
}

/// Asks the backend to capture the approved order. The backend verifies the status,
/// amount, currency and reservation reference with PayPal before recording anything,
/// so a successful return here really means the money arrived.
class CapturePayPalOrder {
  final PaymentsRepository repository;

  CapturePayPalOrder(this.repository);

  Future<Either<Failure, PayPalCapture>> call(CapturePayPalOrderParams params) =>
      repository.capturePayPalOrder(orderId: params.orderId, reservationId: params.reservationId);
}
