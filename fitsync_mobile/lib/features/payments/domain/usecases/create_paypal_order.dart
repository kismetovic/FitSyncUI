import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/payments_repository.dart';

class CreatePayPalOrderParams extends Equatable {
  final double amount;
  final int reservationId;
  final String currency;

  const CreatePayPalOrderParams({
    required this.amount,
    required this.reservationId,
    this.currency = 'USD',
  });

  @override
  List<Object?> get props => [amount, reservationId, currency];
}

class CreatePayPalOrder implements UseCase<Map<String, String>, CreatePayPalOrderParams> {
  final PaymentsRepository repository;

  CreatePayPalOrder(this.repository);

  @override
  Future<Either<Failure, Map<String, String>>> call(CreatePayPalOrderParams params) async {
    return await repository.createPayPalOrder(
      amount: params.amount,
      reservationId: params.reservationId,
      currency: params.currency,
    );
  }
}
