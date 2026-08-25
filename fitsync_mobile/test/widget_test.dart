import 'package:flutter_test/flutter_test.dart';
import 'package:fitsync_mobile/core/utils/money.dart';

/// Replaces Flutter's generated counter smoke test, which referred to a widget
/// this project never had and therefore always failed.
///
/// What is worth pinning down instead is the money formatter: the gym prices in
/// KM, the review asked for one consistent currency, and every amount on screen
/// goes through this one function.
void main() {
  group('formatMoney', () {
    test('prints BAM with two decimals by default', () {
      expect(formatMoney(28), '28.00 BAM');
      expect(formatMoney(99.5), '99.50 BAM');
      expect(formatMoney(0), '0.00 BAM');
    });

    test('never prints a dollar sign', () {
      // The defect this function exists to prevent.
      expect(formatMoney(17.0), isNot(contains('\$')));
      expect(formatMoney(17.0), contains('BAM'));
    });

    test('rounds rather than truncating', () {
      expect(formatMoney(8.685), '8.69 BAM');
      expect(formatMoney(1.004), '1.00 BAM');
    });

    test('an explicit currency is honoured, for the PayPal figure', () {
      // PayPal cannot charge BAM, so the app also shows the euro amount the
      // server actually sends to PayPal.
      expect(formatMoney(8.69, currency: 'EUR'), '8.69 EUR');
    });

    test('add-on prices are signed', () {
      expect(formatMoneyDelta(2), '+2.00 BAM');
      expect(formatMoneyDelta(8.5), '+8.50 BAM');
    });
  });
}
