import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<AppNotification>>> getMyNotifications({int page, int pageSize});
  Future<Either<Failure, List<AppNotification>>> getMyUnreadNotifications();
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, AppNotification>> markAsRead(int id);
  Future<Either<Failure, int>> markAllAsRead();
}
