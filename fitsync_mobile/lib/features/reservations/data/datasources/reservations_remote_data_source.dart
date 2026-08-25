import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/reservation_model.dart';
import '../models/slot_availability_model.dart';
import '../../domain/entities/reservation_type.dart';

abstract class ReservationsRemoteDataSource {
  Future<List<ReservationModel>> getMyReservations();

  /// Free places per day, without exposing other clients' bookings.
  Future<List<SlotAvailabilityModel>> getTrainingAvailability(int trainingId, {int days});

  /// Creates a reservation. Neither the owner nor the status is sent: the backend
  /// takes the owner from the JWT and decides the initial status itself.
  Future<ReservationModel> createReservation({
    required int trainingId,
    required DateTime reservationDate,
    required ReservationType reservationType,
    List<int> additionalServiceIds,
    bool requestOutsideAvailability,
    int? userMembershipId,
  });

  /// Cancels a reservation through the dedicated endpoint, with a mandatory reason.
  /// The reservation stays in the system as cancelled rather than being deleted.
  Future<ReservationModel> cancelReservation(int id, String reason);
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

  /// Surfaces the server's own error message and code. The backend answers
  /// {error, message} for every failure, e.g. TIME_CONFLICT or CAPACITY_FULL.
  Failure _toFailure(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final code = data['error']?.toString();
      final message = data['message']?.toString();
      if (message != null) return ServerFailure(message, code);
      // Validation failures carry a per-field map.
      if (data['errors'] is Map) {
        final first = (data['errors'] as Map).values.first;
        if (first is List && first.isNotEmpty) return ServerFailure(first.first.toString());
      }
    }
    return ServerFailure(e.message ?? 'Zahtjev nije uspio.');
  }

  @override
  Future<List<ReservationModel>> getMyReservations() async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get('$baseUrl/Reservations/mine', options: opts);
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => ReservationModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Dohvat rezervacija nije uspio.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<List<SlotAvailabilityModel>> getTrainingAvailability(int trainingId, {int days = 14}) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get(
        '$baseUrl/Reservations/availability/$trainingId',
        queryParameters: {'days': days},
        options: opts,
      );
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => SlotAvailabilityModel.fromJson(e)).toList();
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
    int? userMembershipId,
  }) async {
    try {
      final opts = await _getAuthOptions();
      final body = <String, dynamic>{
        'trainingId': trainingId,
        'reservationDate': reservationDate.toIso8601String(),
        'reservationType': reservationType.index,
        'additionalServiceIds': additionalServiceIds,
        // Asks for an out-of-hours slot. The backend re-checks this against the
        // trainer's availability and decides the surcharge and the status.
        'requestOutsideAvailability': requestOutsideAvailability,
        if (userMembershipId != null) 'userMembershipId': userMembershipId,
      };

      final response = await dio.post('$baseUrl/Reservations', data: body, options: opts);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReservationModel.fromJson(response.data);
      }
      throw const ServerFailure('Kreiranje rezervacije nije uspjelo.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<ReservationModel> cancelReservation(int id, String reason) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.patch(
        '$baseUrl/Reservations/$id/cancel',
        data: {'reason': reason},
        options: opts,
      );
      if (response.statusCode == 200) {
        return ReservationModel.fromJson(response.data);
      }
      throw const ServerFailure('Otkazivanje rezervacije nije uspjelo.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }
}
