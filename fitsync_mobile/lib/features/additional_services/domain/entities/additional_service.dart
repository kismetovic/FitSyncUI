import 'package:equatable/equatable.dart';

class AdditionalService extends Equatable {
  final int id;
  final String name;
  final double price;

  const AdditionalService({required this.id, required this.name, required this.price});

  @override
  List<Object?> get props => [id, name, price];
}
