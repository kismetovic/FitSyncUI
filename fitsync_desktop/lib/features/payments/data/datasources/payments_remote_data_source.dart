import 'package:dio/dio.dart';
import '../../../../core/error/dio_failure.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/admin_payment_model.dart';
import '../models/payment_summary.dart';
import '../../../../core/pagination/paged_result.dart';

class PaymentsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;
  String get baseUrl => AppConfig.baseUrl;

  PaymentsRemoteDataSource({required this.dio, required this.localDataSource});

  Future<Options> _auth() async {
    final token = await localDataSource.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// One page of payments from the paged search endpoint (review item 22).
  Future<PagedResult<AdminPaymentModel>> getPayments({
    int page = 1,
    int pageSize = kDefaultPageSize,
    String? query,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/Payments/search',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (query != null && query.isNotEmpty) 'query': query,
        },
        options: await _auth(),
      );
      if (response.statusCode == 200) {
        return PagedResult.fromJson(response.data, AdminPaymentModel.fromJson);
      }
      throw const ServerFailure('Failed to get payments');
    } on DioException catch (e) {
      throw failureFrom(e);
    }
  }

  /// Totals across every payment, not just the visible page.
  Future<PaymentSummary> getSummary() async {
    try {
      final response = await dio.get('$baseUrl/Payments/summary', options: await _auth());
      if (response.statusCode == 200) {
        return PaymentSummary.fromJson(response.data);
      }
      throw const ServerFailure('Failed to get payment summary');
    } on DioException catch (e) {
      throw failureFrom(e);
    }
  }
}
