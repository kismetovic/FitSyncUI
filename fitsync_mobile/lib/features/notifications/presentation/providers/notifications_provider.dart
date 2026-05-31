import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/get_my_notifications.dart';
import '../../domain/usecases/mark_notification_read.dart';

class NotificationsProvider extends ChangeNotifier {
  final GetMyNotifications getMyNotifications;
  final MarkNotificationRead markNotificationRead;

  NotificationsProvider({
    required this.getMyNotifications,
    required this.markNotificationRead,
  });

  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getMyNotifications(NoParams());
    result.fold(
      (f) { _error = f.message; _isLoading = false; notifyListeners(); },
      (list) {
        _notifications = list..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> markRead(int id) async {
    final result = await markNotificationRead(id);
    result.fold(
      (f) {},
      (_) {
        final idx = _notifications.indexWhere((n) => n.id == id);
        if (idx != -1) {
          _notifications = List.from(_notifications);
          notifyListeners();
        }
        loadNotifications();
      },
    );
  }
}
