import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/paypal_order.dart';
import '../repositories/payments_repository.dart';

/// Opens a PayPal order for a reservation. Only the reservation id is sent; the
/// backend derives the amount from the reservation it priced at booking time.
class CreatePayPalOrder {
  final PaymentsRepository repository;

  CreatePayPalOrder(this.repository);

  Future<Either<Failure, PayPalOrder>> call(int reservationId) =>
      repository.createPayPalOrder(reservationId: reservationId);
}
