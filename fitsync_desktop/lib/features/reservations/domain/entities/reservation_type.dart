enum ReservationType {
  oneTime,
  monthly;

  static ReservationType fromIndex(int index) {
    if (index >= 0 && index < ReservationType.values.length) {
      return ReservationType.values[index];
    }
    return ReservationType.oneTime;
  }

  /// Shown in the admin list. Printing `name` leaked the Dart identifier
  /// ("oneTime" / "monthly") straight into a Bosnian UI.
  String get label => switch (this) {
        ReservationType.oneTime => 'Jednokratna',
        ReservationType.monthly => 'Mjesečna',
      };
}
