import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.secureStorage, required this.sharedPreferences});

  @override
  Future<void> cacheToken(String token) async {
    await secureStorage.write(key: 'jwt_token', value: token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'jwt_token');
  }

  @override
  Future<void> clearToken() async {
    await secureStorage.delete(key: 'jwt_token');
  }
}
