import 'package:equatable/equatable.dart';

/// One question and answer shown on the mobile help screen.
class Faq extends Equatable {
  final int id;
  final String question;
  final String answer;
  final int sortOrder;

  /// Retired entries stay in the table but are not sent to clients.
  final bool isActive;

  const Faq({
    required this.id,
    required this.question,
    required this.answer,
    required this.sortOrder,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, question, answer, sortOrder, isActive];
}
