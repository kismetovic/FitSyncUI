enum ReservationType {
  oneTime,
  monthly;

  static ReservationType fromIndex(int index) {
    if (index >= 0 && index < ReservationType.values.length) {
      return ReservationType.values[index];
    }
    return ReservationType.oneTime;
  }
}
