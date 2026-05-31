import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/review_model.dart';

abstract class ReviewsRemoteDataSource {
  Future<List<ReviewModel>> getReviews();
  Future<void> deleteReview(int id);
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;
  String get baseUrl => AppConfig.baseUrl;

  ReviewsRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  @override
  Future<List<ReviewModel>> getReviews() async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.get(
        '$baseUrl/Reviews',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => ReviewModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Failed to get reviews');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
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
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }
}

