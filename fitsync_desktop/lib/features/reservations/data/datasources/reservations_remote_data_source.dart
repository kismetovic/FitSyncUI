import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../models/reservation_model.dart';
import '../../../../core/pagination/paged_result.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

/// Administrative reservation actions.
///
/// Every status change goes through its own endpoint, matching the backend state
/// machine. There is no generic "write whatever status you like" call any more, and
/// nothing here deletes a reservation.
abstract class ReservationsRemoteDataSource {
  /// One page of reservations from the paged search endpoint (review item 22).
  /// The whole table is never pulled at once.
  Future<PagedResult<ReservationModel>> getReservations({int page, int pageSize, String? query});

  /// Trainer/administrator approves a request that was waiting for approval.
  Future<ReservationModel> approveReservation(int id);

  /// Marks an attended training as completed.
  Future<ReservationModel> completeReservation(int id, {String? note});

  /// Cancels with a mandatory reason. The reservation stays in the system as
  /// cancelled, with an audit trail, rather than being removed.
  Future<ReservationModel> cancelReservation(int id, String reason);

  /// Confirms that a client paid cash at the desk. This is what moves the
  /// reservation to Paid; a client cannot do it themselves.
  Future<void> confirmCashPayment(int reservationId, {String? note});
}

class ReservationsRemoteDataSourceImpl implements ReservationsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  String get baseUrl => AppConfig.baseUrl;

  ReservationsRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  Future<Options> _authOptions() async {
    final token = await localDataSource.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// Surfaces the API's own error code and message, e.g. INVALID_STATUS_TRANSITION.
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
  Future<PagedResult<ReservationModel>> getReservations({
    int page = 1,
    int pageSize = kDefaultPageSize,
    String? query,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/Reservations/search',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (query != null && query.isNotEmpty) 'query': query,
        },
        options: await _authOptions(),
      );
      if (response.statusCode == 200) {
        return PagedResult.fromJson(response.data, ReservationModel.fromJson);
      }
      throw const ServerFailure('Dohvat rezervacija nije uspio.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<ReservationModel> approveReservation(int id) async {
    try {
      final response = await dio.patch('$baseUrl/Reservations/$id/approve', options: await _authOptions());
      if (response.statusCode == 200) return ReservationModel.fromJson(response.data);
      throw const ServerFailure('Odobravanje rezervacije nije uspjelo.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<ReservationModel> completeReservation(int id, {String? note}) async {
    try {
      final response = await dio.patch(
        '$baseUrl/Reservations/$id/complete',
        data: {'note': note},
        options: await _authOptions(),
      );
      if (response.statusCode == 200) return ReservationModel.fromJson(response.data);
      throw const ServerFailure('Označavanje treninga kao završenog nije uspjelo.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<ReservationModel> cancelReservation(int id, String reason) async {
    try {
      final response = await dio.patch(
        '$baseUrl/Reservations/$id/cancel',
        data: {'reason': reason},
        options: await _authOptions(),
      );
      if (response.statusCode == 200) return ReservationModel.fromJson(response.data);
      throw const ServerFailure('Otkazivanje rezervacije nije uspjelo.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<void> confirmCashPayment(int reservationId, {String? note}) async {
    try {
      final response = await dio.post(
        '$baseUrl/Payments/cash/confirm',
        data: {'reservationId': reservationId, 'note': note},
        options: await _authOptions(),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw const ServerFailure('Potvrda gotovinske uplate nije uspjela.');
      }
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }
}
