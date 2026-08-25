import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/review_model.dart';

abstract class ReviewsRemoteDataSource {
  Future<List<ReviewModel>> getTrainingReviews(int trainingId);
  Future<List<ReviewModel>> getMyReviews();

  /// A review is tied to a reservation, not just a training. The backend uses that
  /// reservation to verify the caller actually attended, and to stop a second review
  /// of the same session. The author comes from the JWT, never from the body.
  Future<ReviewModel> createReview({
    required int reservationId,
    required int rating,
    String? comment,
  });
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

  Failure _toFailure(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data['message'] != null) {
        return ServerFailure(data['message'].toString(), data['error']?.toString());
      }
      if (data['errors'] is Map) {
        final first = (data['errors'] as Map).values.first;
        if (first is List && first.isNotEmpty) return ServerFailure(first.first.toString());
      }
    }
    return ServerFailure(e.message ?? 'Zahtjev nije uspio.');
  }

  @override
  Future<List<ReviewModel>> getTrainingReviews(int trainingId) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get('$baseUrl/Reviews/by-training/$trainingId', options: opts);
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => ReviewModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Dohvat recenzija nije uspio.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<List<ReviewModel>> getMyReviews() async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get('$baseUrl/Reviews/mine', options: opts);
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => ReviewModel.fromJson(e)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }

  @override
  Future<ReviewModel> createReview({
    required int reservationId,
    required int rating,
    String? comment,
  }) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.post(
        '$baseUrl/Reviews',
        data: {'reservationId': reservationId, 'rating': rating, 'comment': comment},
        options: opts,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReviewModel.fromJson(response.data);
      }
      throw const ServerFailure('Kreiranje recenzije nije uspjelo.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }
}
