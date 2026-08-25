import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment.dart';
import '../entities/paypal_order.dart';

abstract class PaymentsRepository {
  Future<List<Payment>> getMyPayments();

  Future<Either<Failure, PayPalOrder>> createPayPalOrder({required int reservationId});

  Future<Either<Failure, PayPalCapture>> capturePayPalOrder({
    required String orderId,
    required int reservationId,
  });

  Future<Either<Failure, Payment>> selectCashPayment({required int reservationId});

  Future<Payment?> getPaymentForReservation(int reservationId);
}
