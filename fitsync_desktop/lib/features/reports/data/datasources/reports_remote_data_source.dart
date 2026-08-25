import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/report_models.dart';

/// Report data always comes from the API. The desktop app never aggregates numbers
/// locally, so a printed PDF is guaranteed to match the database.
abstract class ReportsRemoteDataSource {
  Future<ReservationReportModel> getReservationReport({
    required DateTime from,
    required DateTime to,
    int? trainingId,
  });

  Future<RevenueReportModel> getRevenueReport({
    required DateTime from,
    required DateTime to,
  });
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  String get baseUrl => AppConfig.baseUrl;

  ReportsRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  Future<Options> _authOptions() async {
    final token = await localDataSource.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Failure _toFailure(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return ServerFailure(data['message'].toString(), data['error']?.toString());
    }
    return ServerFailure(e.message ?? 'Dohvat izvjestaja nije uspio.');
  }

  String _iso(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  @override
  Future<ReservationReportModel> getReservationReport({
    required DateTime from,
    required DateTime to,
    int? trainingId,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/Reports/reservations',
        queryParameters: {
          'from': _iso(from),
          'to': _iso(to),
          if (trainingId != null) 'trainingId': trainingId,
        },
        options: await _authOptions(),
      );
      if (response.statusCode == 200) {
        return ReservationReportModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerFailure('Dohvat izvjestaja o rezervacijama nije uspio.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<RevenueReportModel> getRevenueReport({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/Reports/revenue',
        queryParameters: {'from': _iso(from), 'to': _iso(to)},
        options: await _authOptions(),
      );
      if (response.statusCode == 200) {
        return RevenueReportModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerFailure('Dohvat izvjestaja o prihodima nije uspio.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }
}
