enum ReservationStatus {
  initial,
  approved,
  paid,
  cancelled,
  completed,
  pendingApproval;

  static ReservationStatus fromIndex(int index) {
    if (index >= 0 && index < ReservationStatus.values.length) {
      return ReservationStatus.values[index];
    }
    return ReservationStatus.initial;
  }
}
