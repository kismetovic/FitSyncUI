import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';
import '../../../../core/config/app_config.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/notification_model.dart';
import '../../domain/entities/app_notification.dart';

/// Live connection to the API's SignalR hub.
///
/// This is what replaces the manual refresh button: the server pushes each new
/// notification as it is created, so the list and the unread badge update on their own.
class NotificationsHubService {
  /// Server-side method names, mirroring SignalRNotificationPublisher on the API.
  static const String _notificationReceived = 'NotificationReceived';
  static const String _unreadCountChanged = 'UnreadCountChanged';

  final AuthLocalDataSource localDataSource;

  HubConnection? _connection;

  final _notificationController = StreamController<AppNotification>.broadcast();
  final _unreadCountController = StreamController<int>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  NotificationsHubService({required this.localDataSource});

  Stream<AppNotification> get onNotification => _notificationController.stream;
  Stream<int> get onUnreadCount => _unreadCountController.stream;
  Stream<bool> get onConnectionStateChanged => _connectionStateController.stream;

  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  /// The hub lives next to the API but outside the /api prefix.
  String get _hubUrl {
    final base = AppConfig.baseUrl;
    final root = base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
    return '$root/hubs/notifications';
  }

  Future<void> connect() async {
    if (_connection != null && _connection!.state != HubConnectionState.Disconnected) return;

    final token = await localDataSource.getToken();
    if (token == null || token.isEmpty) return;

    // A WebSocket handshake cannot carry an Authorization header, so the API is
    // configured to also read the token from the access_token query parameter.
    _connection = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => (await localDataSource.getToken()) ?? '',
          ),
        )
        .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000])
        .build();

    _connection!.on(_notificationReceived, _handleNotification);
    _connection!.on(_unreadCountChanged, _handleUnreadCount);

    _connection!.onclose(({Exception? error}) => _connectionStateController.add(false));
    _connection!.onreconnected(({String? connectionId}) => _connectionStateController.add(true));
    _connection!.onreconnecting(({Exception? error}) => _connectionStateController.add(false));

    try {
      await _connection!.start();
      _connectionStateController.add(true);
    } catch (_) {
      // A hub that cannot be reached must not break the app: the provider falls back
      // to periodic polling, so notifications still arrive, just less promptly.
      _connectionStateController.add(false);
    }
  }

  void _handleNotification(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;
    final payload = arguments.first;
    if (payload is Map) {
      try {
        _notificationController.add(NotificationModel.fromJson(Map<String, dynamic>.from(payload)));
      } catch (_) {
        // Ignore a malformed push rather than tearing down the connection.
      }
    }
  }

  void _handleUnreadCount(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;
    final value = arguments.first;
    if (value is int) _unreadCountController.add(value);
    if (value is num) _unreadCountController.add(value.toInt());
  }

  Future<void> disconnect() async {
    try {
      await _connection?.stop();
    } catch (_) {
      // Already closed.
    }
    _connection = null;
    _connectionStateController.add(false);
  }

  Future<void> dispose() async {
    await disconnect();
    await _notificationController.close();
    await _unreadCountController.close();
    await _connectionStateController.close();
  }
}
