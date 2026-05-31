import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<AppNotification>>> getMyNotifications();
  Future<Either<Failure, List<AppNotification>>> getMyUnreadNotifications();
  Future<Either<Failure, void>> markAsRead(int id);
}
