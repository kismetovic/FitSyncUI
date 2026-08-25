import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/training_model.dart';
import '../models/recommended_training_model.dart';

abstract class TrainingsRemoteDataSource {
  Future<List<TrainingModel>> getTrainings([String? searchQuery]);
  Future<List<RecommendedTrainingModel>> getRecommendations();
}

class TrainingsRemoteDataSourceImpl implements TrainingsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  String get baseUrl => AppConfig.baseUrl;

  TrainingsRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  @override
  /// `/Trainings/search` answers with a `PagedResult` envelope
  /// (`{items, page, pageSize, totalCount}`), not a bare array, and its
  /// `PageSize` is capped at 100 server-side.
  ///
  /// The catalogue screen filters and sorts over the full set, so this walks the
  /// pages and returns everything rather than silently showing only the first
  /// page. Each individual query stays bounded, which is the point of the cap.
  Future<List<TrainingModel>> getTrainings([String? searchQuery]) async {
    try {
      final token = await localDataSource.getToken();
      final options =
          Options(headers: token != null ? {'Authorization': 'Bearer $token'} : null);

      const pageSize = 100;
      final all = <TrainingModel>[];
      var page = 1;

      while (true) {
        final response = await dio.get(
          '$baseUrl/Trainings/search',
          queryParameters: {
            'page': page,
            'pageSize': pageSize,
            if (searchQuery != null && searchQuery.isNotEmpty) 'name': searchQuery,
          },
          options: options,
        );

        if (response.statusCode != 200) {
          throw const ServerFailure('Failed to get trainings');
        }

        final data = response.data as Map<String, dynamic>;
        final items = (data['items'] as List? ?? const [])
            .map((e) => TrainingModel.fromJson(e))
            .toList();
        all.addAll(items);

        final totalCount = data['totalCount'] as int? ?? all.length;
        if (all.length >= totalCount || items.isEmpty) break;
        page++;
      }

      return all;
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<List<RecommendedTrainingModel>> getRecommendations() async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.get(
        '$baseUrl/Trainings/recommendations',
        queryParameters: {'limit': 10},
        options: Options(headers: token != null ? {'Authorization': 'Bearer $token'} : null),
      );
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => RecommendedTrainingModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Failed to get recommendations');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }
}
