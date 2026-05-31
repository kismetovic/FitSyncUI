import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final int id;
  final int userId;
  final int trainingId;
  final int rating;
  final String? comment;
  final String? userName;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.trainingId,
    required this.rating,
    this.comment,
    this.userName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, trainingId, rating, comment, userName, createdAt];
}
