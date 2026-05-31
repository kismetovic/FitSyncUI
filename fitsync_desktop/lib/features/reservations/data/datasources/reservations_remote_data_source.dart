import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../models/reservation_model.dart';
import '../../domain/entities/reservation_status.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

abstract class ReservationsRemoteDataSource {
  Future<List<ReservationModel>> getReservations();
  Future<ReservationModel> updateReservation(int id, ReservationStatus status);
  Future<ReservationModel> approveReservation(int id);
  Future<void> deleteReservation(int id);
}

class ReservationsRemoteDataSourceImpl implements ReservationsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;
  String get baseUrl => AppConfig.baseUrl;

  ReservationsRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  @override
  Future<List<ReservationModel>> getReservations() async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.get(
        '$baseUrl/Reservations',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => ReservationModel.fromJson(e))
            .toList();
      } else {
        throw const ServerFailure('Failed to get reservations');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<ReservationModel> updateReservation(int id, ReservationStatus status) async {
    try {
      final token = await localDataSource.getToken();

final currentResponse = await dio.get(
        '$baseUrl/Reservations/$id',
         options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      
      if (currentResponse.statusCode != 200) throw const ServerFailure("Failed to fetch reservation for update");
      
      final data = currentResponse.data;
      data['status'] = status.index;
      
      final response = await dio.put(
        '$baseUrl/Reservations/$id',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return ReservationModel.fromJson(response.data);
      } else {
         throw const ServerFailure('Failed to update reservation');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<ReservationModel> approveReservation(int id) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.patch(
        '$baseUrl/Reservations/$id/approve',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) return ReservationModel.fromJson(response.data);
      throw const ServerFailure('Failed to approve reservation');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<void> deleteReservation(int id) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.delete(
        '$baseUrl/Reservations/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const ServerFailure('Failed to delete reservation');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }
}

