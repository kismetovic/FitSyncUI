import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/paypal_order_model.dart';
import '../models/payment_model.dart';

/// Payment calls as the backend now defines them: the app names a reservation and the
/// server decides the amount. There is no endpoint here that lets the client state a
/// price or declare a payment successful.
abstract class PaymentsRemoteDataSource {
  Future<List<PaymentModel>> getMyPayments();

  /// Asks the backend to open a PayPal order for a reservation.
  Future<PayPalOrderModel> createPayPalOrder({required int reservationId});

  /// Asks the backend to capture the approved order and verify it with PayPal.
  Future<PayPalCaptureModel> capturePayPalOrder({
    required String orderId,
    required int reservationId,
  });

  /// Records the intent to pay on arrival. Does not mark the reservation as paid.
  Future<PaymentModel> selectCashPayment({required int reservationId});

  Future<PaymentModel?> getPaymentForReservation(int reservationId);
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  String get baseUrl => AppConfig.baseUrl;

  PaymentsRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  Future<Options> _getAuthOptions() async {
    final token = await localDataSource.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// The API returns {error, message} on every failure, so surface the server's own
  /// message rather than a generic one.
  Failure _toFailure(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      // The code travels with the message: the payment screen has to tell
      // ORDER_NOT_APPROVED (the user simply has not finished at PayPal yet) apart
      // from a real failure, and matching on prose would be fragile.
      return ServerFailure(data['message'].toString(), data['error']?.toString());
    }
    return ServerFailure(e.message ?? 'Zahtjev nije uspio.');
  }

  @override
  Future<List<PaymentModel>> getMyPayments() async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get('$baseUrl/Payments/mine', options: opts);
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => PaymentModel.fromJson(e)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }

  @override
  Future<PayPalOrderModel> createPayPalOrder({required int reservationId}) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.post(
        '$baseUrl/Payments/paypal/create-order',
        // Only the reservation id. Amount and currency come from the reservation
        // record on the server.
        data: {'reservationId': reservationId},
        options: opts,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PayPalOrderModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerFailure('Kreiranje PayPal narudžbe nije uspjelo.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<PayPalCaptureModel> capturePayPalOrder({
    required String orderId,
    required int reservationId,
  }) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.post(
        '$baseUrl/Payments/paypal/capture',
        data: {'orderId': orderId, 'reservationId': reservationId},
        options: opts,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PayPalCaptureModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerFailure('Naplata PayPal narudžbe nije uspjela.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<PaymentModel> selectCashPayment({required int reservationId}) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.post(
        '$baseUrl/Payments/cash/select',
        data: {'reservationId': reservationId},
        options: opts,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentModel.fromJson(response.data);
      }
      throw const ServerFailure('Odabir plaćanja pri dolasku nije uspio.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<PaymentModel?> getPaymentForReservation(int reservationId) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get('$baseUrl/Payments/by-reservation/$reservationId', options: opts);
      if (response.statusCode == 200) {
        return PaymentModel.fromJson(response.data);
      }
      return null;
    } on DioException {
      return null;
    }
  }
}
