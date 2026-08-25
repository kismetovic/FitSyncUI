import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class MarkNotificationRead implements UseCase<AppNotification, int> {
  final NotificationsRepository repository;

  MarkNotificationRead(this.repository);

  @override
  Future<Either<Failure, AppNotification>> call(int id) => repository.markAsRead(id);
}
