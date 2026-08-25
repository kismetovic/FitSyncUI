import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/services/notifications_hub_service.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/get_my_notifications.dart';
import '../../domain/usecases/get_unread_count.dart';
import '../../domain/usecases/mark_all_notifications_read.dart';
import '../../domain/usecases/mark_notification_read.dart';

/// Keeps the notification list current without the user pressing anything.
///
/// Primary channel is the SignalR hub, which pushes each notification the moment the
/// server creates it. A slow polling timer runs as a safety net for the case where the
/// socket cannot be established (restrictive network, hub restart), so the list still
/// refreshes on its own either way.
class NotificationsProvider extends ChangeNotifier {
  /// Fallback poll interval, used only while the hub is disconnected.
  static const Duration _pollInterval = Duration(seconds: 30);

  final GetMyNotifications getMyNotifications;
  final GetUnreadCount getUnreadCount;
  final MarkNotificationRead markNotificationRead;
  final MarkAllNotificationsRead markAllNotificationsRead;
  final NotificationsHubService hubService;

  NotificationsProvider({
    required this.getMyNotifications,
    required this.getUnreadCount,
    required this.markNotificationRead,
    required this.markAllNotificationsRead,
    required this.hubService,
  });

  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isLive = false;

  /// True while the push connection is up. The UI shows this so it is obvious the
  /// list is updating by itself.
  bool get isLive => _isLive;

  StreamSubscription<AppNotification>? _notificationSub;
  StreamSubscription<int>? _unreadSub;
  StreamSubscription<bool>? _connectionSub;
  Timer? _pollTimer;
  bool _started = false;

  /// Called once the user is authenticated.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    _notificationSub = hubService.onNotification.listen(_onPushedNotification);
    _unreadSub = hubService.onUnreadCount.listen((count) {
      _unreadCount = count;
      notifyListeners();
    });
    _connectionSub = hubService.onConnectionStateChanged.listen(_onConnectionStateChanged);

    await loadNotifications();
    await hubService.connect();

    // Until the hub confirms it is up, poll.
    _startPolling();
  }

  /// Called on logout so the next user does not inherit this one's stream.
  Future<void> stop() async {
    _started = false;
    _stopPolling();
    await _notificationSub?.cancel();
    await _unreadSub?.cancel();
    await _connectionSub?.cancel();
    _notificationSub = null;
    _unreadSub = null;
    _connectionSub = null;
    await hubService.disconnect();

    _notifications = [];
    _unreadCount = 0;
    _isLive = false;
    notifyListeners();
  }

  /// Inbox paging. The newest page loads first and older ones are appended on
  /// demand, so a long history is never fetched in one response (review item 22).
  static const int _pageSize = 30;
  int _page = 1;

  /// False once a short page comes back, which is what hides the "load older"
  /// action rather than leaving the list silently truncated.
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _page = 1;
    final result = await getMyNotifications(page: _page, pageSize: _pageSize);
    result.fold(
      (f) => _error = f.message,
      (list) {
        _notifications = List.of(list)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _hasMore = list.length == _pageSize;
      },
    );

    _isLoading = false;
    notifyListeners();
    await refreshUnreadCount();
  }

  /// The badge counts every unread message, not just the page the inbox holds,
  /// so it comes from the server rather than from this list.
  Future<void> refreshUnreadCount() async {
    final result = await getUnreadCount();
    result.fold(
      (_) {
        // A failed count must not blank a badge that is otherwise correct.
      },
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
    );
  }

  /// Appends the next page of older notifications.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    final result = await getMyNotifications(page: _page + 1, pageSize: _pageSize);
    result.fold(
      (f) => _error = f.message,
      (list) {
        if (list.isEmpty) {
          _hasMore = false;
        } else {
          _page++;
          final known = _notifications.map((n) => n.id).toSet();
          _notifications = [
            ..._notifications,
            ...list.where((n) => !known.contains(n.id)),
          ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _hasMore = list.length == _pageSize;
        }
      },
    );

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> markRead(int id) async {
    final result = await markNotificationRead(id);
    result.fold(
      (f) {
        _error = f.message;
        notifyListeners();
      },
      (updated) => _replace(updated),
    );
  }

  Future<void> markAllRead() async {
    final result = await markAllNotificationsRead(NoParams());
    result.fold(
      (f) {
        _error = f.message;
        notifyListeners();
      },
      (_) => loadNotifications(),
    );
  }

  void _onPushedNotification(AppNotification notification) {
    // A push can arrive for something already in the list after a reconnect.
    final index = _notifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      _notifications = List.of(_notifications)..[index] = notification;
    } else {
      _notifications = [notification, ..._notifications];
    }
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    notifyListeners();
  }

  void _onConnectionStateChanged(bool connected) {
    _isLive = connected;

    if (connected) {
      // Push is live, so the fallback poll is no longer needed. Refresh once to pick
      // up anything that happened while the socket was down.
      _stopPolling();
      loadNotifications();
    } else {
      _startPolling();
    }

    notifyListeners();
  }

  void _replace(AppNotification updated) {
    final index = _notifications.indexWhere((n) => n.id == updated.id);
    if (index != -1) {
      _notifications = List.of(_notifications)..[index] = updated;
    }
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    notifyListeners();
  }

  void _startPolling() {
    _pollTimer ??= Timer.periodic(_pollInterval, (_) {
      if (!_isLive) loadNotifications();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    _notificationSub?.cancel();
    _unreadSub?.cancel();
    _connectionSub?.cancel();
    super.dispose();
  }
}
