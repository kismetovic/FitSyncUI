import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/reservation_model.dart';
import '../../domain/entities/reservation_status.dart';
import '../../domain/entities/reservation_type.dart';

abstract class ReservationsRemoteDataSource {
  Future<List<ReservationModel>> getMyReservations();
  Future<List<ReservationModel>> getReservationsByTraining(int trainingId);
  Future<ReservationModel> createReservation({
    required int trainingId,
    required DateTime reservationDate,
    required ReservationType reservationType,
    List<int> additionalServiceIds,
    bool requestOutsideAvailability,
  });
  Future<ReservationModel> updateReservation(int id, ReservationStatus status);
  Future<void> cancelReservation(int id);
}

class ReservationsRemoteDataSourceImpl implements ReservationsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  String get baseUrl => AppConfig.baseUrl;

  ReservationsRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  Future<Options> _getAuthOptions() async {
    final token = await localDataSource.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<ReservationModel>> getMyReservations() async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get('$baseUrl/Reservations/my', options: opts);
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => ReservationModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Failed to get reservations');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<List<ReservationModel>> getReservationsByTraining(int trainingId) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get('$baseUrl/Reservations/by-training/$trainingId', options: opts);
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => ReservationModel.fromJson(e)).toList();
      }
      return [];
    } on DioException {
      return [];
    }
  }

  @override
  Future<ReservationModel> createReservation({
    required int trainingId,
    required DateTime reservationDate,
    required ReservationType reservationType,
    List<int> additionalServiceIds = const [],
    bool requestOutsideAvailability = false,
  }) async {
    try {
      final opts = await _getAuthOptions();
      final body = <String, dynamic>{
        'trainingId': trainingId,
        'reservationDate': reservationDate.toIso8601String(),
        'reservationType': reservationType.index,
        'additionalServiceIds': additionalServiceIds,
      };
      if (requestOutsideAvailability) {
        body['status'] = 5;
      }
      final response = await dio.post('$baseUrl/Reservations', data: body, options: opts);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReservationModel.fromJson(response.data);
      }
      throw const ServerFailure('Failed to create reservation');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<ReservationModel> updateReservation(int id, ReservationStatus status) async {
    try {
      final opts = await _getAuthOptions();
      final currentResp = await dio.get('$baseUrl/Reservations/$id', options: opts);
      if (currentResp.statusCode != 200) throw const ServerFailure('Failed to fetch reservation');

      final data = Map<String, dynamic>.from(currentResp.data);
      data['status'] = status.index;

      final response = await dio.put('$baseUrl/Reservations/$id', data: data, options: opts);
      if (response.statusCode == 200) return ReservationModel.fromJson(response.data);
      throw const ServerFailure('Failed to update reservation');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<void> cancelReservation(int id) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.delete('$baseUrl/Reservations/$id', options: opts);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const ServerFailure('Failed to cancel reservation');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }
}
