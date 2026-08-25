import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/paypal_order.dart';
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
  Future<Either<Failure, PayPalOrder>> createPayPalOrder({required int reservationId}) async {
    try {
      return Right(await remoteDataSource.createPayPalOrder(reservationId: reservationId));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PayPalCapture>> capturePayPalOrder({
    required String orderId,
    required int reservationId,
  }) async {
    try {
      return Right(await remoteDataSource.capturePayPalOrder(
        orderId: orderId,
        reservationId: reservationId,
      ));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Payment>> selectCashPayment({required int reservationId}) async {
    try {
      return Right(await remoteDataSource.selectCashPayment(reservationId: reservationId));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Payment?> getPaymentForReservation(int reservationId) =>
      remoteDataSource.getPaymentForReservation(reservationId);
}
