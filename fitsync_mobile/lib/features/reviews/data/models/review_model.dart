import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.trainingId,
    required super.rating,
    super.comment,
    super.userName,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      userId: json['userId'],
      trainingId: json['trainingId'],
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      userName: json['user'] != null
          ? '${json['user']['name'] ?? ''} ${json['user']['surname'] ?? ''}'.trim()
          : json['userName'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
