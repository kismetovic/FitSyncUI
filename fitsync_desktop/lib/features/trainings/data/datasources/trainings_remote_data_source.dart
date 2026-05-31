import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../models/training_model.dart';
import '../../domain/entities/training_difficulty.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

abstract class TrainingsRemoteDataSource {
  Future<List<TrainingModel>> getTrainings([String? searchQuery]);
  Future<TrainingModel> createTraining({
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    required int maxCapacity,
    required TrainingDifficulty difficulty,
    required int trainingTypeId,
  });
  Future<TrainingModel> updateTraining(int id, {
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    required int maxCapacity,
    required TrainingDifficulty difficulty,
    required int trainingTypeId,
  });
  Future<void> deleteTraining(int id);
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
        return (response.data as List)
            .map((e) => TrainingModel.fromJson(e))
            .toList();
      } else {
        throw const ServerFailure('Failed to get trainings');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<TrainingModel> createTraining({
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    required int maxCapacity,
    required TrainingDifficulty difficulty,
    required int trainingTypeId,
  }) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.post(
        '$baseUrl/Trainings',
        data: {
          'name': name,
          'description': description,
          'price': price,
          'durationMinutes': durationMinutes,
          'maxCapacity': maxCapacity,
          'difficulty': difficulty.index,
          'trainingTypeId': trainingTypeId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return TrainingModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to create training');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<TrainingModel> updateTraining(int id, {
    required String name,
    required String description,
    required double price,
    required int durationMinutes,
    required int maxCapacity,
    required TrainingDifficulty difficulty,
    required int trainingTypeId,
  }) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.put(
        '$baseUrl/Trainings/$id',
        data: {
          'name': name,
          'description': description,
          'price': price,
          'durationMinutes': durationMinutes,
          'maxCapacity': maxCapacity,
          'difficulty': difficulty.index,
          'trainingTypeId': trainingTypeId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return TrainingModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to update training');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<void> deleteTraining(int id) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.delete(
        '$baseUrl/Trainings/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw const ServerFailure('Failed to delete training');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }
}

