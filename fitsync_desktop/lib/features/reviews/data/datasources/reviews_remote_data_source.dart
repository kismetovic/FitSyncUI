import 'package:dio/dio.dart';
import '../../../../core/error/dio_failure.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/review_model.dart';
import '../../../../core/pagination/paged_result.dart';

abstract class ReviewsRemoteDataSource {
  /// One page of reviews from the paged search endpoint (review item 22).
  Future<PagedResult<ReviewModel>> getReviews({int page, int pageSize, String? query});
  Future<void> deleteReview(int id);
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;
  String get baseUrl => AppConfig.baseUrl;

  ReviewsRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  @override
  Future<PagedResult<ReviewModel>> getReviews({
    int page = 1,
    int pageSize = kDefaultPageSize,
    String? query,
  }) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.get(
        '$baseUrl/Reviews/search',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (query != null && query.isNotEmpty) 'query': query,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        return PagedResult.fromJson(response.data, ReviewModel.fromJson);
      }
      throw const ServerFailure('Failed to get reviews');
    } on DioException catch (e) {
      throw failureFrom(e);
    }
  }

  @override
  Future<void> deleteReview(int id) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.delete(
        '$baseUrl/Reviews/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const ServerFailure('Failed to delete review');
      }
    } on DioException catch (e) {
      throw failureFrom(e);
    }
  }
}

