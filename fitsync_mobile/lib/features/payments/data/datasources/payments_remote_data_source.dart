import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../payments/domain/entities/payment.dart';
import '../models/payment_model.dart';

abstract class PaymentsRemoteDataSource {
  Future<List<PaymentModel>> getMyPayments();
  Future<Map<String, String>> createPayPalOrder({
    required double amount,
    required int reservationId,
    String currency,
  });
  Future<String> capturePayPalOrder(String orderId);
  Future<PaymentModel> confirmPayment({
    required double amount,
    required String transactionId,
    required PaymentProvider paymentProvider,
    required int reservationId,
    String currency,
  });
  Future<PaymentModel> confirmCashPayment({
    required double amount,
    required int reservationId,
  });
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  String get baseUrl => AppConfig.baseUrl;

  PaymentsRemoteDataSourceImpl({required this.dio, required this.localDataSource});

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

  Future<Options> _getAuthOptions() async {
    final token = await localDataSource.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<Map<String, String>> createPayPalOrder({
    required double amount,
    required int reservationId,
    String currency = 'USD',
  }) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.post(
        '$baseUrl/Payments/paypal/create-order',
        data: {'amount': amount, 'currency': currency, 'reservationId': reservationId},
        options: opts,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return {
          'orderId': data['orderId']?.toString() ?? '',
          'approvalUrl': data['approvalUrl']?.toString() ?? '',
        };
      }
      throw const ServerFailure('Failed to create PayPal order');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<String> capturePayPalOrder(String orderId) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.post(
        '$baseUrl/Payments/paypal/capture',
        data: {'orderId': orderId},
        options: opts,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['transactionId']?.toString() ?? '';
      }
      throw const ServerFailure('Failed to capture PayPal order');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<PaymentModel> confirmPayment({
    required double amount,
    required String transactionId,
    required PaymentProvider paymentProvider,
    required int reservationId,
    String currency = 'USD',
  }) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.post(
        '$baseUrl/Payments/confirm',
        data: {
          'amount': amount,
          'transactionId': transactionId,
          'currency': currency,
          'paymentProvider': paymentProvider.index,
          'reservationId': reservationId,
        },
        options: opts,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentModel.fromJson(response.data);
      }
      throw const ServerFailure('Failed to confirm payment');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<PaymentModel> confirmCashPayment({
    required double amount,
    required int reservationId,
  }) async {
    return confirmPayment(
      amount: amount,
      transactionId: 'CASH-${DateTime.now().millisecondsSinceEpoch}',
      paymentProvider: PaymentProvider.cash,
      reservationId: reservationId,
    );
  }
}
