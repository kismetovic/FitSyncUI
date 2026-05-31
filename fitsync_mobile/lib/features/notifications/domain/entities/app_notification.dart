import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final int userId;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.userId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, message, isRead, userId, createdAt];
}
