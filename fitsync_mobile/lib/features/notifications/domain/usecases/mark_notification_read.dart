import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notifications_repository.dart';

class MarkNotificationRead implements UseCase<void, int> {
  final NotificationsRepository repository;

  MarkNotificationRead(this.repository);

  @override
  Future<Either<Failure, void>> call(int id) async {
    return await repository.markAsRead(id);
  }
}
