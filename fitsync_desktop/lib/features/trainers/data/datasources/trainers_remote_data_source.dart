import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/trainer_model.dart';

/// Trainers and their weekly availability windows.
///
/// `GET /Trainers` already returns each trainer with `availabilities` inline, so
/// the list view needs a single round trip. Availability itself is a
/// sub-resource: it is added and removed, never updated in place, which mirrors
/// the API (`POST /Trainers/availability`, `DELETE /Trainers/availability/{id}`).
abstract class TrainersRemoteDataSource {
  Future<List<TrainerModel>> getTrainers();
  Future<TrainerModel> createTrainer(TrainerModel trainer);
  Future<TrainerModel> updateTrainer(int id, TrainerModel trainer);
  Future<void> deleteTrainer(int id);

  Future<void> addAvailability({
    required int trainerId,
    required int dayOfWeek,
    required int startMinutes,
    required int endMinutes,
  });
  Future<void> deleteAvailability(int availabilityId);
}

class TrainersRemoteDataSourceImpl implements TrainersRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  String get baseUrl => AppConfig.baseUrl;

  TrainersRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  Future<Options> _auth() async {
    final token = await localDataSource.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// `TrainerAvailabilityRequest` is an `IValidatableObject` — an end time that is
  /// not after the start comes back as a field error, and this surfaces it.
  String _message(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message']?.toString();
      if (message != null) return message;
      if (data['errors'] is Map) {
        final first = (data['errors'] as Map).values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }
    return e.message ?? 'Request failed';
  }

  @override
  Future<List<TrainerModel>> getTrainers() async {
    try {
      final response = await dio.get('$baseUrl/Trainers', options: await _auth());
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => TrainerModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Dohvat trenera nije uspio.');
    } on DioException catch (e) {
      throw ServerFailure(_message(e));
    }
  }

  @override
  Future<TrainerModel> createTrainer(TrainerModel trainer) async {
    try {
      final response = await dio.post(
        '$baseUrl/Trainers',
        data: trainer.toRequestBody(),
        options: await _auth(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TrainerModel.fromJson(response.data);
      }
      throw const ServerFailure('Kreiranje trenera nije uspjelo.');
    } on DioException catch (e) {
      throw ServerFailure(_message(e));
    }
  }

  @override
  Future<TrainerModel> updateTrainer(int id, TrainerModel trainer) async {
    try {
      final response = await dio.put(
        '$baseUrl/Trainers/$id',
        data: trainer.toRequestBody(),
        options: await _auth(),
      );
      if (response.statusCode == 200) {
        return TrainerModel.fromJson(response.data);
      }
      throw const ServerFailure('Izmjena trenera nije uspjela.');
    } on DioException catch (e) {
      throw ServerFailure(_message(e));
    }
  }

  @override
  Future<void> deleteTrainer(int id) async {
    try {
      final response = await dio.delete('$baseUrl/Trainers/$id', options: await _auth());
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const ServerFailure('Brisanje trenera nije uspjelo.');
      }
    } on DioException catch (e) {
      throw ServerFailure(_message(e));
    }
  }

  @override
  Future<void> addAvailability({
    required int trainerId,
    required int dayOfWeek,
    required int startMinutes,
    required int endMinutes,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/Trainers/availability',
        data: {
          'trainerId': trainerId,
          'dayOfWeek': dayOfWeek,
          'startTime': TrainerAvailabilityModel.formatTime(startMinutes),
          'endTime': TrainerAvailabilityModel.formatTime(endMinutes),
        },
        options: await _auth(),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw const ServerFailure('Dodavanje termina nije uspjelo.');
      }
    } on DioException catch (e) {
      throw ServerFailure(_message(e));
    }
  }

  @override
  Future<void> deleteAvailability(int availabilityId) async {
    try {
      final response = await dio.delete(
        '$baseUrl/Trainers/availability/$availabilityId',
        options: await _auth(),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const ServerFailure('Brisanje termina nije uspjelo.');
      }
    } on DioException catch (e) {
      throw ServerFailure(_message(e));
    }
  }
}
