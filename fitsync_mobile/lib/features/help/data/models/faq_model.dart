import '../../domain/entities/faq.dart';

class FaqModel extends Faq {
  const FaqModel({
    required super.id,
    required super.question,
    required super.answer,
    required super.sortOrder,
    required super.isActive,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) => FaqModel(
        id: json['id'] ?? 0,
        question: json['question']?.toString() ?? '',
        answer: json['answer']?.toString() ?? '',
        sortOrder: json['sortOrder'] ?? 0,
        isActive: json['isActive'] ?? true,
      );

  /// The id is not sent: the API takes it from the route on update and assigns
  /// it on insert.
  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
        'sortOrder': sortOrder,
        'isActive': isActive,
      };
}
