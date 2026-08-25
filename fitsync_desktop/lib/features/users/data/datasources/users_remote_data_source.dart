import 'package:dio/dio.dart';
import '../../../../core/error/dio_failure.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../models/user_model.dart';
import '../../../../core/pagination/paged_result.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

abstract class UsersRemoteDataSource {
  /// [role] filters server-side to "Client" or "Administrator". The screens are
  /// split by role, so the filter belongs in SQL rather than in the page.
  Future<PagedResult<UserModel>> getUsers({String? searchQuery, String? role, int page, int pageSize});
  Future<UserModel> getUserById(int id);
  Future<UserModel> updateUser(int id, {
    required String userName,
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    String? address,
    required String role,
    required bool enabled,
  });

  /// Creates an account. The API assigns the Identity role during creation, so
  /// [role] is not a cosmetic field here either.
  Future<UserModel> createUser({
    required String userName,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required String role,
    required bool enabled,
  });
  Future<void> deleteUser(int id);
  Future<void> sendPaymentReminder(int userId);
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;
  String get baseUrl => AppConfig.baseUrl;

  UsersRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  /// Pulls the server's own message out of a failure. Creating a user is the
  /// case that needs it most: duplicate user name and password-policy errors
  /// come back as a field map that would otherwise render as raw JSON.
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
  Future<PagedResult<UserModel>> getUsers({
    String? searchQuery,
    String? role,
    int page = 1,
    int pageSize = kDefaultPageSize,
  }) async {
    try {
      final token = await localDataSource.getToken();
      // Always the paged search endpoint: name filtering and paging both happen
      // in SQL, so the admin list never materialises the whole user table.
      final response = await dio.get(
        '$baseUrl/Users/search',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (searchQuery != null && searchQuery.isNotEmpty) 'name': searchQuery,
          if (role != null && role.isNotEmpty) 'role': role,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return PagedResult.fromJson(response.data, UserModel.fromJson);
      } else {
        throw const ServerFailure('Failed to get users');
      }
    } on DioException catch (e) {
      throw ServerFailure(_message(e));
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
      throw failureFrom(e);
    }
  }

  @override
  Future<UserModel> updateUser(int id, {
    required String userName,
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    String? address,
    required String role,
    required bool enabled,
  }) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.put(
        '$baseUrl/Users/$id',
        data: {
          'name': firstName,
          'surname': lastName,
          // Carry the existing user name through. Sending the e-mail here used to
          // rename accounts as a side effect of any edit.
          'userName': userName,
          'email': email,
          'phoneNumber': phoneNumber,
          // Enabled is a real switch now. It used to be hardcoded true, so every
          // edit silently re-enabled a locked account and disabling was impossible.
          'enabled': enabled,
          // The role dropdown used to be cosmetic: it was never sent, so changing it
          // in the UI had no effect on the backend. The API now accepts it and
          // rewrites the Identity role assignment.
          'role': role,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to update user');
      }
    } on DioException catch (e) {
      throw failureFrom(e);
    }
  }

  @override
  Future<UserModel> createUser({
    required String userName,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required String role,
    required bool enabled,
  }) async {
    try {
      final token = await localDataSource.getToken();
      final response = await dio.post(
        '$baseUrl/Users',
        data: {
          'userName': userName,
          'email': email,
          'password': password,
          'name': firstName,
          'surname': lastName,
          'phoneNumber': phoneNumber,
          'role': role,
          'enabled': enabled,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to create user');
      }
    } on DioException catch (e) {
      throw ServerFailure(_message(e));
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
      throw failureFrom(e);
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
      throw failureFrom(e);
    }
  }
}

