import '../../domain/entities/training_type.dart';

class TrainingTypeModel extends TrainingType {
  const TrainingTypeModel({
    required super.id,
    required super.name,
  });

  factory TrainingTypeModel.fromJson(Map<String, dynamic> json) {
    return TrainingTypeModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
