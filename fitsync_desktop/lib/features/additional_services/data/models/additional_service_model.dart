import '../../domain/entities/additional_service.dart';

class AdditionalServiceModel extends AdditionalService {
  const AdditionalServiceModel({required super.id, required super.name, required super.price});

  factory AdditionalServiceModel.fromJson(Map<String, dynamic> json) => AdditionalServiceModel(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
  );
}
