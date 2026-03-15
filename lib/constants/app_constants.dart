import '../core/models/purity.dart';

class AppConstants {
  AppConstants._();

  /// Nisab threshold in 24K-equivalent grams.
  static const double nisabGrams = 85.0;

  /// Zakah divisor (2.5% = 1/40).
  static const double zakatDivisor = 40.0;

  static const int splashDurationSeconds = 2;

  /// Fixed purities for v1. Extend this list to add more carats in the future.
  static const List<Purity> purities = [
    Purity(karat: 14),
    Purity(karat: 18),
    Purity(karat: 21),
    Purity(karat: 22),
    Purity(karat: 24),
  ];
}
