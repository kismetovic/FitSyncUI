import 'package:dio/dio.dart';
import '../../../../core/error/dio_failure.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../models/training_model.dart';
import '../../../../core/pagination/paged_result.dart';
import '../../domain/entities/training_difficulty.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

abstract class TrainingsRemoteDataSource {
  /// One page of trainings. `/Trainings/search` answers with a PagedResult
  /// envelope, not a bare array (review item 22).
  Future<PagedResult<TrainingModel>> getTrainings({String? searchQuery, int page, int pageSize});
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
  Future<PagedResult<TrainingModel>> getTrainings({
    String? searchQuery,
    int page = 1,
    int pageSize = kDefaultPageSize,
  }) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.get(
        '$baseUrl/Trainings/search',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (searchQuery != null && searchQuery.isNotEmpty) 'name': searchQuery,
        },
        options: Options(headers: token != null ? {'Authorization': 'Bearer $token'} : null),
      );

      if (response.statusCode == 200) {
        // The endpoint answers with {items, page, pageSize, totalCount}. Reading
        // it as a bare array used to throw before it reached the UI.
        return PagedResult.fromJson(response.data, TrainingModel.fromJson);
      } else {
        throw const ServerFailure('Failed to get trainings');
      }
    } on DioException catch (e) {
      throw failureFrom(e);
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
      throw failureFrom(e);
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
      throw failureFrom(e);
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
      throw failureFrom(e);
    }
  }
}

