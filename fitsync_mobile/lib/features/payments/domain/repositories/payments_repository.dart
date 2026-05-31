import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment.dart';

abstract class PaymentsRepository {
  Future<List<Payment>> getMyPayments();
  Future<Either<Failure, Map<String, String>>> createPayPalOrder({
    required double amount,
    required int reservationId,
    String currency,
  });
  Future<Either<Failure, String>> capturePayPalOrder(String orderId);
  Future<Either<Failure, Payment>> confirmPayment({
    required double amount,
    required String transactionId,
    required PaymentProvider paymentProvider,
    required int reservationId,
    String currency,
  });
  Future<Either<Failure, Payment>> confirmCashPayment({
    required double amount,
    required int reservationId,
  });
}
