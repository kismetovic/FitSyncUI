import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../models/user_model.dart';
import 'auth_local_data_source.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(String username, String password);
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  });
  Future<UserModel> getCurrentUser();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  String get baseUrl => AppConfig.baseUrl;

  AuthRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  /// Builds a failure that carries a stable code as well as a message, so the
  /// screen can print the reason in the user's language. The message stays in
  /// English as a fallback for a code the UI does not know.
  ServerFailure _dioFailure(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ServerFailure(
          'Connection timed out. Please check the server is running.',
          'NETWORK_TIMEOUT');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const ServerFailure(
          'Cannot reach server. Check your network or that the API is running.',
          'NETWORK_UNREACHABLE');
    }
    final body = e.response?.data;
    if (body is Map) {
      final code = body['error']?.toString();
      final message = body['message']?.toString() ?? body['title']?.toString();
      if (message != null) return ServerFailure(message, code);

      // ASP.NET model validation: { errors: { Field: ["..."] } }
      if (body['errors'] is Map) {
        final first = (body['errors'] as Map).values.first;
        if (first is List && first.isNotEmpty) {
          return ServerFailure(first.first.toString(), code);
        }
      }
      if (code != null) return ServerFailure(code, code);
    }
    return ServerFailure(body?.toString() ?? e.message ?? 'Request failed');
  }

  @override
  Future<String> login(String username, String password) async {
    try {
      final response = await dio.post('$baseUrl/auth/login', data: {
        'userNameOrEmail': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          return data['token']?.toString() ??
              data['jwt']?.toString() ??
              data['accessToken']?.toString() ??
              data.toString();
        }
        return data.toString();
      } else {
        throw const ServerFailure('Login failed');
      }
    } on Failure {
      rethrow;
    } on DioException catch (e) {
      throw _dioFailure(e);
    }
  }

  @override
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await dio.post('$baseUrl/auth/register', data: {
        'name': firstName,
        'surname': lastName,
        'email': email,
        'password': password,
        'userName': email,
        'phoneNumber': phone,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel(
          id: response.data['id'],
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: phone,
          address: null,
          role: 'Client',
        );
      } else {
        throw const ServerFailure('Registration failed');
      }
    } on Failure {
      rethrow;
    } on DioException catch (e) {
      throw _dioFailure(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) throw const CacheFailure('No token found');

      final response = await dio.get(
        '$baseUrl/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to get user');
      }
    } on Failure {
      rethrow;
    } on DioException catch (e) {
      throw _dioFailure(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) throw const CacheFailure('No token found');

      final response = await dio.post(
        '$baseUrl/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerFailure(response.data?.toString() ?? 'Password change failed');
      }
    } on Failure {
      rethrow;
    } on DioException catch (e) {
      throw _dioFailure(e);
    }
  }
}
