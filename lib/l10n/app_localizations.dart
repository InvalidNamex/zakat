import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  // ── App ───────────────────────────────────────────────────────────────────────

  String get appTitle => isArabic ? 'زكاة الذهب' : 'Gold Zakat';

  String get switchLanguageLabel => isArabic ? 'EN' : 'ع';

  // ── Date card ─────────────────────────────────────────────────────────────────

  String get hijriDateLabel =>
      isArabic ? 'بداية حول الزكاة (هجري)' : 'Zakat Year Start (Hijri)';

  String get selectHijriDate =>
      isArabic ? 'اختر التاريخ الهجري' : 'Select Hijri Date';

  String get hijriSuffix => isArabic ? 'هـ' : 'H';

  // ── Date picker dialog ────────────────────────────────────────────────────────

  String get hijriDatePickerTitle =>
      isArabic ? 'تاريخ بداية السنة الهجرية' : 'Hijri Year Start Date';

  String get yearLabel => isArabic ? 'السنة' : 'Year';

  String get monthLabel => isArabic ? 'الشهر' : 'Month';

  String get dayLabel => isArabic ? 'اليوم' : 'Day';

  // ── Purity card ───────────────────────────────────────────────────────────────

  String karatLabel(int karat) =>
      isArabic ? '$karat عيار' : '${karat}K';

  String get gramsUnit => isArabic ? 'جرام' : 'g';

  // ── Result card ───────────────────────────────────────────────────────────────

  String get resultTitle => isArabic ? 'نتيجة الحساب' : 'Calculation Result';

  String get total24KLabel => isArabic ? 'المعادل عيار 24' : '24K Equivalent';

  String get zakatDueLabel => isArabic ? 'الزكاة المستحقة' : 'Zakat Due';

  String get zakatNotRequired => isArabic
      ? 'لا تجب عليك الزكاة\nلم يبلغ الذهب النصاب (85 جرام عيار 24)'
      : 'Zakat is not required\nGold has not reached the Nisab (85g of 24K)';

  // ── Reset ─────────────────────────────────────────────────────────────────────

  String get resetTooltip => isArabic ? 'إعادة تعيين' : 'Reset';

  String get resetConfirmTitle =>
      isArabic ? 'إعادة تعيين البيانات' : 'Reset Data';

  String get resetConfirmContent => isArabic
      ? 'هل تريد مسح جميع القيم المحفوظة؟'
      : 'Are you sure you want to clear all saved values?';

  String get yes => isArabic ? 'نعم' : 'Yes';

  String get no => isArabic ? 'لا' : 'No';

  // ── Price calculator ──────────────────────────────────────────────────────────

  String get pricePerGramLabel =>
      isArabic ? 'سعر الجرام (عيار 24)' : 'Price per gram (24K)';

  String get priceHint => isArabic ? 'أدخل السعر' : 'Enter price';

  String get zakatValueLabel =>
      isArabic ? 'قيمة الزكاة بالعملة' : 'Zakat value in currency';

  String get copiedMessage => isArabic ? 'تم النسخ' : 'Copied';

  // ── Hijri months ─────────────────────────────────────────────────────────────

  List<String> get hijriMonths => isArabic
      ? [
          'محرم',
          'صفر',
          'ربيع الأول',
          'ربيع الثاني',
          'جمادى الأولى',
          'جمادى الآخرة',
          'رجب',
          'شعبان',
          'رمضان',
          'شوال',
          'ذو القعدة',
          'ذو الحجة',
        ]
      : [
          'Muharram',
          'Safar',
          "Rabi' al-Awwal",
          "Rabi' al-Thani",
          'Jumada al-Awwal',
          'Jumada al-Thani',
          'Rajab',
          "Sha'ban",
          'Ramadan',
          'Shawwal',
          "Dhu al-Qi'dah",
          'Dhu al-Hijjah',
        ];
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
