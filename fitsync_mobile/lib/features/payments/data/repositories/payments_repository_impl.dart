import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_remote_data_source.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource remoteDataSource;

  PaymentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Payment>> getMyPayments() async {
    try {
      return await remoteDataSource.getMyPayments();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> createPayPalOrder({
    required double amount,
    required int reservationId,
    String currency = 'USD',
  }) async {
    try {
      final result = await remoteDataSource.createPayPalOrder(
        amount: amount,
        reservationId: reservationId,
        currency: currency,
      );
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> capturePayPalOrder(String orderId) async {
    try {
      final result = await remoteDataSource.capturePayPalOrder(orderId);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Payment>> confirmPayment({
    required double amount,
    required String transactionId,
    required PaymentProvider paymentProvider,
    required int reservationId,
    String currency = 'USD',
  }) async {
    try {
      final result = await remoteDataSource.confirmPayment(
        amount: amount,
        transactionId: transactionId,
        paymentProvider: paymentProvider,
        reservationId: reservationId,
        currency: currency,
      );
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Payment>> confirmCashPayment({
    required double amount,
    required int reservationId,
  }) async {
    try {
      final result = await remoteDataSource.confirmCashPayment(
        amount: amount,
        reservationId: reservationId,
      );
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
