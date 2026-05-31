import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class GetMyNotifications implements UseCase<List<AppNotification>, NoParams> {
  final NotificationsRepository repository;

  GetMyNotifications(this.repository);

  @override
  Future<Either<Failure, List<AppNotification>>> call(NoParams params) async {
    return await repository.getMyNotifications();
  }
}
