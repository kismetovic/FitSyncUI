import '../../domain/entities/training.dart';
import '../../domain/entities/training_difficulty.dart';

class TrainingModel extends Training {
  const TrainingModel({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    required super.durationMinutes,
    super.averageRating,
    super.reviewCount,
    required super.maxCapacity,
    required super.difficulty,
    required super.trainingTypeId,
    super.trainingTypeName,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      durationMinutes: json['durationMinutes'] ?? 60,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      maxCapacity: json['maxCapacity'] ?? 0,
      difficulty: TrainingDifficulty.fromIndex(json['difficulty'] ?? 0),
      trainingTypeId: json['trainingTypeId'] ?? 0,
      trainingTypeName: json['trainingType'] != null ? json['trainingType']['name'] : null,
    );
  }
}
