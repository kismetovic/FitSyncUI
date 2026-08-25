enum TrainingDifficulty {
  beginner,
  intermediate,
  advanced;

  static TrainingDifficulty fromIndex(int index) {
    switch (index) {
      case 0:
        return TrainingDifficulty.beginner;
      case 1:
        return TrainingDifficulty.intermediate;
      case 2:
        return TrainingDifficulty.advanced;
      default:
        return TrainingDifficulty.beginner;
    }
  }

  /// Shown on the training cards. Printing `name` put the Dart identifier
  /// ("beginner" / "advanced") into an otherwise Bosnian UI.
  String get label => switch (this) {
        TrainingDifficulty.beginner => 'Početni',
        TrainingDifficulty.intermediate => 'Srednji',
        TrainingDifficulty.advanced => 'Napredni',
      };
}
