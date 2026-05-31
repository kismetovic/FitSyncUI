import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../../core/error/failures.dart';
import '../models/dashboard_stats_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getStats();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;
  String get baseUrl => AppConfig.baseUrl;

  DashboardRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  @override
  Future<DashboardStatsModel> getStats() async {
    try {
      final token = await localDataSource.getToken();
      
      final response = await dio.get(
        '$baseUrl/Dashboard/stats',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return DashboardStatsModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to get dashboard stats');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }
}

