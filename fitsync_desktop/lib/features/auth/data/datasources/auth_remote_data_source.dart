import 'package:dio/dio.dart';
import '../../../../core/error/dio_failure.dart';
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
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;
  String get baseUrl => AppConfig.baseUrl; 

  AuthRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  @override
  Future<String> login(String username, String password) async {
    try {
      final response = await dio.post('$baseUrl/auth/login', data: {
        'userNameOrEmail': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        return response.data['token'] ?? response.data['jwt'] ?? response.data.toString(); 
      } else {
        throw const ServerFailure('Login failed');
      }
    } on DioException catch (e) {
      throw failureFrom(e);
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
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
         return UserModel(
            id: response.data['id'],
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phone,
            address: null,
            role: "Client",
         );
      } else {
        throw const ServerFailure('Registration failed');
      }
    } on DioException catch (e) {
         throw failureFrom(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) throw const CacheFailure("No token found");

      final response = await dio.get(
        '$baseUrl/auth/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
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
}

