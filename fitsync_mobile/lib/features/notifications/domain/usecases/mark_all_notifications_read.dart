import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notifications_repository.dart';

class MarkAllNotificationsRead implements UseCase<int, NoParams> {
  final NotificationsRepository repository;

  MarkAllNotificationsRead(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) => repository.markAllAsRead();
}
