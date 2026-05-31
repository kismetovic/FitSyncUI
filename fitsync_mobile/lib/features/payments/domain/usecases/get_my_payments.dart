import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

class GetMyPayments {
  final PaymentsRepository repository;
  GetMyPayments(this.repository);
  Future<List<Payment>> call() => repository.getMyPayments();
}
