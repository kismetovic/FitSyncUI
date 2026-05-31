import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/training_model.dart';

abstract class TrainingsRemoteDataSource {
  Future<List<TrainingModel>> getTrainings([String? searchQuery]);
  Future<List<TrainingModel>> getRecommendations();
}

class TrainingsRemoteDataSourceImpl implements TrainingsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  String get baseUrl => AppConfig.baseUrl;

  TrainingsRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  @override
  Future<List<TrainingModel>> getTrainings([String? searchQuery]) async {
    try {
      final token = await localDataSource.getToken();
      final queryParams = <String, dynamic>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['name'] = searchQuery;
      }

      final response = await dio.get(
        '$baseUrl/Trainings/search',
        queryParameters: queryParams,
        options: Options(headers: token != null ? {'Authorization': 'Bearer $token'} : null),
      );

      if (response.statusCode == 200) {
        return (response.data as List).map((e) => TrainingModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Failed to get trainings');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<List<TrainingModel>> getRecommendations() async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.get(
        '$baseUrl/Trainings/recommendations',
        queryParameters: {'limit': 10},
        options: Options(headers: token != null ? {'Authorization': 'Bearer $token'} : null),
      );
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => TrainingModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Failed to get recommendations');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }
}
