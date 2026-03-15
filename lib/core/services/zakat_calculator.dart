import '../../constants/app_constants.dart';

class ZakatCalculator {
  ZakatCalculator._();

  /// Converts [grams] of the given [karat] to 24K-equivalent grams.
  /// Formula: grams × karat ÷ 24
  static double to24KEquivalent(double grams, int karat) {
    return (grams * karat) / 24.0;
  }

  /// Sums the 24K-equivalent across all purity entries.
  static double totalEquivalent(Map<int, double> karatGrams) {
    return karatGrams.entries.fold(
      0.0,
      (sum, e) => sum + to24KEquivalent(e.value, e.key),
    );
  }

  /// Returns true when the 24K-equivalent total meets or exceeds the nisab.
  static bool isZakatRequired(double total24K) =>
      total24K >= AppConstants.nisabGrams;

  /// Returns the zakah amount: 2.5% of the 24K-equivalent total (= total ÷ 40).
  static double calculateZakat(double total24K) =>
      total24K / AppConstants.zakatDivisor;
}
