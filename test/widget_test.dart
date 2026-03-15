import 'package:flutter_test/flutter_test.dart';

import 'package:zakat/core/services/zakat_calculator.dart';

void main() {
  group('ZakatCalculator', () {
    test('14K 5g converts to correct 24K equivalent', () {
      final result = ZakatCalculator.to24KEquivalent(5.0, 14);
      expect(result, closeTo(2.9166666, 0.000001));
    });

    test('18K 10g converts to 7.5g 24K', () {
      expect(ZakatCalculator.to24KEquivalent(10.0, 18), 7.5);
    });

    test('total below nisab => not required', () {
      final total = ZakatCalculator.totalEquivalent({14: 5.0, 18: 10.0});
      expect(ZakatCalculator.isZakatRequired(total), isFalse);
    });

    test('total exactly 85g => required', () {
      expect(ZakatCalculator.isZakatRequired(85.0), isTrue);
    });

    test('zakat on 100g is 2.5g', () {
      expect(ZakatCalculator.calculateZakat(100.0), 2.5);
    });

    test('all zeros produces total of 0', () {
      final total = ZakatCalculator.totalEquivalent(
          {14: 0, 18: 0, 21: 0, 22: 0, 24: 0});
      expect(total, 0.0);
    });
  });
}

