import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getMyNotifications();
  Future<List<NotificationModel>> getMyUnreadNotifications();
  Future<void> markAsRead(int id);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource localDataSource;

  String get baseUrl => AppConfig.baseUrl;

  NotificationsRemoteDataSourceImpl({required this.dio, required this.localDataSource});

  Future<Options> _getAuthOptions() async {
    final token = await localDataSource.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<NotificationModel>> getMyNotifications() async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get('$baseUrl/Notifications/mine', options: opts);
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => NotificationModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Failed to get notifications');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<List<NotificationModel>> getMyUnreadNotifications() async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get('$baseUrl/Notifications/mine/unread', options: opts);
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => NotificationModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Failed to get unread notifications');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }

  @override
  Future<void> markAsRead(int id) async {
    try {
      final opts = await _getAuthOptions();
      final current = await dio.get('$baseUrl/Notifications/$id', options: opts);
      if (current.statusCode != 200) throw const ServerFailure('Failed to get notification');

      final data = Map<String, dynamic>.from(current.data);
      data['isRead'] = true;

      final response = await dio.put('$baseUrl/Notifications/$id', data: data, options: opts);
      if (response.statusCode != 200) {
        throw const ServerFailure('Failed to mark notification as read');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data?.toString() ?? e.message ?? 'Request failed');
    }
  }
}
