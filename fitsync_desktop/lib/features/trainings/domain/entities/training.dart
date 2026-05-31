import 'package:equatable/equatable.dart';
import 'training_difficulty.dart';

class Training extends Equatable {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;
  final double? averageRating;
  final int? reviewCount;
  final int maxCapacity;
  final TrainingDifficulty difficulty;
  final int trainingTypeId;
  final String? trainingTypeName;

  const Training({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.averageRating,
    this.reviewCount,
    required this.maxCapacity,
    required this.difficulty,
    required this.trainingTypeId,
    this.trainingTypeName,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        durationMinutes,
        averageRating,
        reviewCount,
        maxCapacity,
        difficulty,
        trainingTypeId,
        trainingTypeName,
      ];
}
