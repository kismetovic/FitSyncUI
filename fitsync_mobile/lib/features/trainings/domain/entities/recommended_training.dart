import 'training.dart';

/// A training returned by the recommender, carrying the explanation the API
/// produced alongside it.
///
/// Review item 23 asks that the user be told *why* a training was recommended,
/// so the scoring metadata travels with the training instead of being dropped
/// during parsing. [reason] is a ready-to-display sentence from the backend;
/// [matchedSignals] lists the individual signals that fed the score.
class RecommendedTraining extends Training {
  /// Recommender score, roughly 0..1. Higher means a stronger match.
  final double score;

  /// Which strategy produced this pick, e.g. `ContentBased` or `Collaborative`.
  final String strategy;

  /// Human-readable explanation, already localised by the backend.
  final String? reason;

  /// The individual signals behind the score, e.g. `Tip treninga: Yoga`.
  final List<String> matchedSignals;

  const RecommendedTraining({
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
    required this.score,
    required this.strategy,
    this.reason,
    this.matchedSignals = const [],
  });

  @override
  List<Object?> get props => [...super.props, score, strategy, reason, matchedSignals];
}
