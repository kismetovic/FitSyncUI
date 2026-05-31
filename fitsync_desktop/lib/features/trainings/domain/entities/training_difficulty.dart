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
}
