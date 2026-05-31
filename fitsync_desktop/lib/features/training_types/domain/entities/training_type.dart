import 'package:equatable/equatable.dart';

class TrainingType extends Equatable {
  final int id;
  final String name;

  const TrainingType({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
