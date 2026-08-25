/// Mirrors `PaymentSummaryResponse`.
///
/// Review item 22: these totals are aggregated in the database. The desktop used
/// to load every payment row and sum it locally, which stopped being correct the
/// moment the list was paged.
class PaymentSummary {
  final double totalRevenue;
  final int capturedCount;
  final int payPalCount;
  final int cashCount;

  const PaymentSummary({
    this.totalRevenue = 0,
    this.capturedCount = 0,
    this.payPalCount = 0,
    this.cashCount = 0,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) => PaymentSummary(
        totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
        capturedCount: json['capturedCount'] ?? 0,
        payPalCount: json['payPalCount'] ?? 0,
        cashCount: json['cashCount'] ?? 0,
      );
}
