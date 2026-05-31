import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/payments_repository.dart';

class CapturePayPalOrder {
  final PaymentsRepository repository;
  CapturePayPalOrder(this.repository);

  Future<Either<Failure, String>> call(String orderId) =>
      repository.capturePayPalOrder(orderId);
}
