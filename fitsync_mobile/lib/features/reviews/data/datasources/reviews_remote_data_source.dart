import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/review_model.dart';

abstract class ReviewsRemoteDataSource {
  Future<List<ReviewModel>> getTrainingReviews(int trainingId);
  Future<ReviewModel> createReview({required int trainingId, required int rating, String? comment});
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  String get baseUrl => AppConfig.baseUrl;

  ReviewsRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  Future<Options> _getAuthOptions() async {
    final token = await localDataSource.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<ReviewModel>> getTrainingReviews(int trainingId) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get(
        '$baseUrl/Reviews/by-training/$trainingId',
        options: opts,
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
  Future<ReviewModel> createReview({required int trainingId, required int rating, String? comment}) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.post(
        '$baseUrl/Reviews',
        data: {'trainingId': trainingId, 'rating': rating, 'comment': comment},
        options: opts,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReviewModel.fromJson(response.data);
      }
      throw const ServerFailure('Failed to create review');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }
}
