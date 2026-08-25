import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

/// One page of the caller's notifications, newest first.
///
/// Review item 22: the inbox reads `/Notifications/mine/paged` rather than the
/// unpaged route, so a long history is not fetched in a single response.
class GetMyNotifications {
  final NotificationsRepository repository;

  GetMyNotifications(this.repository);

  Future<Either<Failure, List<AppNotification>>> call({
    int page = 1,
    int pageSize = 30,
  }) =>
      repository.getMyNotifications(page: page, pageSize: pageSize);
}
