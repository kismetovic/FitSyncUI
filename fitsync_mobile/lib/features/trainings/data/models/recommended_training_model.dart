import '../../domain/entities/recommended_training.dart';
import '../../domain/entities/training_difficulty.dart';

class RecommendedTrainingModel extends RecommendedTraining {
  const RecommendedTrainingModel({
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
    required super.score,
    required super.strategy,
    super.reason,
    super.matchedSignals,
  });

  /// `RecommendedTrainingResponse` is a `TrainingResponse` plus the recommender
  /// metadata, so the training fields are read exactly as `TrainingModel` reads
  /// them and the score/reason fields are read on top.
  factory RecommendedTrainingModel.fromJson(Map<String, dynamic> json) {
    return RecommendedTrainingModel(
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
      score: (json['score'] as num?)?.toDouble() ?? 0,
      strategy: json['strategy'] as String? ?? '',
      reason: json['reason'] as String?,
      matchedSignals:
          (json['matchedSignals'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}
