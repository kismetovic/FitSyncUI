import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/additional_service_model.dart';

abstract class AdditionalServicesRemoteDataSource {
  Future<List<AdditionalServiceModel>> getAdditionalServices();
}

class AdditionalServicesRemoteDataSourceImpl implements AdditionalServicesRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  String get baseUrl => AppConfig.baseUrl;

  AdditionalServicesRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  Future<Options> _getAuthOptions() async {
    final token = await localDataSource.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<AdditionalServiceModel>> getAdditionalServices() async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get('$baseUrl/AdditionalServices', options: opts);
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => AdditionalServiceModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Failed to get additional services');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }
}
