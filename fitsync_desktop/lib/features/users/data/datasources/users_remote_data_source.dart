import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../models/user_model.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

abstract class UsersRemoteDataSource {
  Future<List<UserModel>> getUsers([String? searchQuery]);
  Future<UserModel> getUserById(int id);
  Future<UserModel> updateUser(int id, {
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    String? address,
    required String role,
  });
  Future<void> deleteUser(int id);
  Future<void> sendPaymentReminder(int userId);
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;
  String get baseUrl => AppConfig.baseUrl;

  UsersRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  @override
  Future<List<UserModel>> getUsers([String? searchQuery]) async {
    try {
      final token = await localDataSource.getToken();
      final String endpoint = (searchQuery != null && searchQuery.isNotEmpty)
          ? '$baseUrl/Users/search'
          : '$baseUrl/Users';
      final queryParams = <String, dynamic>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['name'] = searchQuery;
      }

      final response = await dio.get(
        endpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => UserModel.fromJson(e))
            .toList();
      } else {
        throw const ServerFailure('Failed to get users');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<UserModel> getUserById(int id) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.get(
        '$baseUrl/Users/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to get user');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<UserModel> updateUser(int id, {
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    String? address,
    required String role,
  }) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.put(
        '$baseUrl/Users/$id',
        data: {
          'name': firstName,
          'surname': lastName,
          'userName': email,
          'email': email,
          'phoneNumber': phoneNumber,
          'enabled': true,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to update user');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.delete(
        '$baseUrl/Users/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const ServerFailure('Failed to delete user');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<void> sendPaymentReminder(int userId) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.post(
        '$baseUrl/Notifications/send-payment-reminder',
        data: {'userId': userId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const ServerFailure('Failed to send payment reminder');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }
}

