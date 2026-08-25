/// The single place that turns an amount into text for display.
///
/// The backend works in **BAM**: `PaymentInsertRequest.Currency` defaults to
/// "BAM" and membership packages are priced in BAM. (PayPal cannot charge BAM,
/// so the server converts to EUR for the order only; the amount recorded stays
/// in BAM.) Most of the UI used to print a `$` prefix instead, so the same figure
/// appeared as "$28" on one screen and "99.00 BAM" on another. Everything now
/// goes through here.
String formatMoney(num amount, {String currency = 'BAM', int decimals = 2}) =>
    '${amount.toStringAsFixed(decimals)} $currency';

/// Same, prefixed with a sign, for add-on prices shown as extras.
String formatMoneyDelta(num amount, {String currency = 'BAM', int decimals = 2}) =>
    '+${formatMoney(amount, currency: currency, decimals: decimals)}';
