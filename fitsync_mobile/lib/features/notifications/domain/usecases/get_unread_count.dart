import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notifications_repository.dart';

/// The unread badge counts every unread notification, not only the page the
/// inbox currently holds, so it comes from `/Notifications/mine/unread-count`.
class GetUnreadCount {
  final NotificationsRepository repository;

  GetUnreadCount(this.repository);

  Future<Either<Failure, int>> call() => repository.getUnreadCount();
}
