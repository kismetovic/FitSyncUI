import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../models/training_type_model.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

abstract class TrainingTypesRemoteDataSource {
  Future<List<TrainingTypeModel>> getTrainingTypes();
  Future<TrainingTypeModel> createTrainingType(String name);
  Future<TrainingTypeModel> updateTrainingType(int id, String name);
  Future<void> deleteTrainingType(int id);
}

class TrainingTypesRemoteDataSourceImpl implements TrainingTypesRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;
  String get baseUrl => AppConfig.baseUrl;

  TrainingTypesRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  @override
  Future<List<TrainingTypeModel>> getTrainingTypes() async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.get(
        '$baseUrl/TrainingTypes',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => TrainingTypeModel.fromJson(e))
            .toList();
      } else {
        throw const ServerFailure('Failed to get training types');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<TrainingTypeModel> createTrainingType(String name) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.post(
        '$baseUrl/TrainingTypes',
        data: {'name': name},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return TrainingTypeModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to create training type');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<TrainingTypeModel> updateTrainingType(int id, String name) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.put(
        '$baseUrl/TrainingTypes/$id',
        data: {'name': name},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return TrainingTypeModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to update training type');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<void> deleteTrainingType(int id) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.delete(
        '$baseUrl/TrainingTypes/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw const ServerFailure('Failed to delete training type');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }
}

