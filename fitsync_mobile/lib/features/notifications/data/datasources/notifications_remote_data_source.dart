import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getMyNotifications({int page, int pageSize});
  Future<List<NotificationModel>> getMyUnreadNotifications();
  Future<int> getUnreadCount();

  /// Marks one notification read through the dedicated endpoint.
  Future<NotificationModel> markAsRead(int id);

  Future<int> markAllAsRead();
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

  Failure _toFailure(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return ServerFailure(data['message'].toString(), data['error']?.toString());
    }
    return ServerFailure(e.message ?? 'Zahtjev nije uspio.');
  }

  /// Uses the paged endpoint (review item 22) rather than `/Notifications/mine`,
  /// which returns the user's whole history in one response. The inbox shows the
  /// newest page first and loads older ones on demand.
  @override
  Future<List<NotificationModel>> getMyNotifications({int page = 1, int pageSize = 30}) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get(
        '$baseUrl/Notifications/mine/paged',
        queryParameters: {'page': page, 'pageSize': pageSize},
        options: opts,
      );
      if (response.statusCode == 200) {
        final items = response.data['items'] as List? ?? const [];
        return items.map((e) => NotificationModel.fromJson(e)).toList();
      }
      throw const ServerFailure('Dohvat obavijesti nije uspio.');
    } on DioException catch (e) {
      throw _toFailure(e);
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
      throw const ServerFailure('Dohvat nepročitanih obavijesti nije uspio.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.get('$baseUrl/Notifications/mine/unread-count', options: opts);
      if (response.statusCode == 200) {
        return (response.data as Map<String, dynamic>)['count'] as int? ?? 0;
      }
      return 0;
    } on DioException {
      return 0;
    }
  }

  /// Uses PATCH /Notifications/{id}/read. The old approach fetched the notification
  /// and PUT the whole object back, which let the client rewrite the title and body
  /// of a message the server had sent it.
  @override
  Future<NotificationModel> markAsRead(int id) async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.patch('$baseUrl/Notifications/$id/read', options: opts);
      if (response.statusCode == 200) {
        return NotificationModel.fromJson(response.data);
      }
      throw const ServerFailure('Označavanje obavijesti nije uspjelo.');
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<int> markAllAsRead() async {
    try {
      final opts = await _getAuthOptions();
      final response = await dio.patch('$baseUrl/Notifications/mine/read-all', options: opts);
      if (response.statusCode == 200) {
        return (response.data as Map<String, dynamic>)['updated'] as int? ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }
}
