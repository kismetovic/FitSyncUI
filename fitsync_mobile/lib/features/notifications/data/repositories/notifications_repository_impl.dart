import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppNotification>>> getMyNotifications({int page = 1, int pageSize = 30}) =>
      _guard(() async => await remoteDataSource.getMyNotifications(page: page, pageSize: pageSize));

  @override
  Future<Either<Failure, List<AppNotification>>> getMyUnreadNotifications() =>
      _guard(() async => await remoteDataSource.getMyUnreadNotifications());

  @override
  Future<Either<Failure, int>> getUnreadCount() => _guard(remoteDataSource.getUnreadCount);

  @override
  Future<Either<Failure, AppNotification>> markAsRead(int id) =>
      _guard(() async => await remoteDataSource.markAsRead(id));

  @override
  Future<Either<Failure, int>> markAllAsRead() => _guard(remoteDataSource.markAllAsRead);
}
