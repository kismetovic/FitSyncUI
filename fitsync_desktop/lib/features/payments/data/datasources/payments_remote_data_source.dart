import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/admin_payment_model.dart';

class PaymentsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;
  String get baseUrl => AppConfig.baseUrl;

  PaymentsRemoteDataSource({required this.dio, required this.localDataSource});

  Future<Options> _auth() async {
    final token = await localDataSource.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<AdminPaymentModel>> getAllPayments() async {
    try {
      final response = await dio.get('$baseUrl/Payments', options: await _auth());
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => AdminPaymentModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Failed to get payments');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }
}
