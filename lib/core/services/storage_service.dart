import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';

class StorageService {
  static const String _hijriYearKey = 'hijri_year';
  static const String _hijriMonthKey = 'hijri_month';
  static const String _hijriDayKey = 'hijri_day';
  static const String _gramsPrefix = 'grams_';
  static const String _localeKey = 'locale';

  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  Future<void> saveGrams(int karat, double grams) =>
      _prefs.setDouble('$_gramsPrefix$karat', grams);

  double getGrams(int karat) =>
      _prefs.getDouble('$_gramsPrefix$karat') ?? 0.0;

  Future<void> saveHijriDate({
    required int year,
    required int month,
    required int day,
  }) async {
    await _prefs.setInt(_hijriYearKey, year);
    await _prefs.setInt(_hijriMonthKey, month);
    await _prefs.setInt(_hijriDayKey, day);
  }

  ({int year, int month, int day})? getHijriDate() {
    final year = _prefs.getInt(_hijriYearKey);
    final month = _prefs.getInt(_hijriMonthKey);
    final day = _prefs.getInt(_hijriDayKey);
    if (year == null || month == null || day == null) return null;
    return (year: year, month: month, day: day);
  }

  Future<void> reset() async {
    for (final purity in AppConstants.purities) {
      await _prefs.remove('$_gramsPrefix${purity.karat}');
    }
    await _prefs.remove(_hijriYearKey);
    await _prefs.remove(_hijriMonthKey);
    await _prefs.remove(_hijriDayKey);
  }

  void saveLocale(String languageCode) =>
      _prefs.setString(_localeKey, languageCode);

  String? getLocale() => _prefs.getString(_localeKey);
}
