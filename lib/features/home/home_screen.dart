import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../core/bloc/locale_cubit.dart';
import '../../core/models/purity.dart';
import '../../core/services/zakat_calculator.dart';
import '../../l10n/app_localizations.dart';
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final p in AppConstants.purities) {
      _controllers[p.karat] = TextEditingController();
    }
    context.read<HomeBloc>().add(HomeLoadRequested());
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _formatValue(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  String _formatHijriDate(HijriCalendar date, AppLocalizations l10n) {
    return '${date.hDay} ${l10n.hijriMonths[date.hMonth - 1]} ${date.hYear} ${l10n.hijriSuffix}';
  }

  void _syncControllers(HomeLoaded state) {
    for (final p in AppConstants.purities) {
      final value = state.grams[p.karat] ?? 0.0;
      final formatted = value > 0 ? _formatValue(value) : '';
      if (_controllers[p.karat]!.text != formatted) {
        _controllers[p.karat]!.text = formatted;
      }
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────────

  void _increment(int karat, double current) {
    final next = current + 1.0;
    _controllers[karat]!.text = _formatValue(next);
    context.read<HomeBloc>().add(HomeGramsUpdated(karat, next));
  }

  void _decrement(int karat, double current) {
    final next = (current - 1.0).clamp(0.0, double.infinity);
    _controllers[karat]!.text = next > 0 ? _formatValue(next) : '';
    context.read<HomeBloc>().add(HomeGramsUpdated(karat, next));
  }

  void _onGramsChanged(int karat, String text) {
    if (text.isEmpty) {
      context.read<HomeBloc>().add(HomeGramsUpdated(karat, 0.0));
      return;
    }
    final value = double.tryParse(text);
    if (value == null) return;
    context.read<HomeBloc>().add(
          HomeGramsUpdated(karat, value.clamp(0.0, double.infinity)),
        );
  }

  /// Returns the number of days in a Hijri month using the Umm al-Qura
  /// convention: odd-numbered months have 30 days, even-numbered months have
  /// 29 days, except month 12 in a leap year (11 leap years per 30-year cycle)
  /// which has 30 days.
  static int _daysInHijriMonth(int year, int month) {
    if (month == 12) {
      // Leap years in the 30-year Hijri cycle:
      const leapYears = {2, 5, 7, 10, 13, 15, 18, 21, 24, 26, 29};
      if (leapYears.contains(year % 30)) return 30;
      return 29;
    }
    return month.isOdd ? 30 : 29;
  }

  Widget _pickerRow(String label, Widget dropdown) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ),
        Expanded(child: dropdown),
      ],
    );
  }

  Future<void> _pickHijriDate(HijriCalendar? current) async {
    final l10n = AppLocalizations.of(context);
    final initial = current ?? HijriCalendar.now();
    int selYear = initial.hYear;
    int selMonth = initial.hMonth;
    int selDay = initial.hDay;

    final picked = await showDialog<HijriCalendar>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final maxDays = _daysInHijriMonth(selYear, selMonth);
          if (selDay > maxDays) selDay = maxDays;
          return AlertDialog(
            title: Text(l10n.hijriDatePickerTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _pickerRow(l10n.yearLabel, DropdownButton<int>(
                  value: selYear,
                  isExpanded: true,
                  items: [
                    for (int y = 1400; y <= 1500; y++)
                      DropdownMenuItem(value: y, child: Text('$y ${l10n.hijriSuffix}')),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => selYear = v ?? selYear),
                )),
                const SizedBox(height: 8),
                _pickerRow(l10n.monthLabel, DropdownButton<int>(
                  value: selMonth,
                  isExpanded: true,
                  items: [
                    for (int m = 0; m < l10n.hijriMonths.length; m++)
                      DropdownMenuItem(
                          value: m + 1, child: Text(l10n.hijriMonths[m])),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => selMonth = v ?? selMonth),
                )),
                const SizedBox(height: 8),
                _pickerRow(l10n.dayLabel, DropdownButton<int>(
                  value: selDay,
                  isExpanded: true,
                  items: [
                    for (int d = 1; d <= maxDays; d++)
                      DropdownMenuItem(value: d, child: Text('$d')),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => selDay = v ?? selDay),
                )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.no),
              ),
              TextButton(
                onPressed: () => Navigator.pop(
                  ctx,
                  HijriCalendar()
                    ..hYear = selYear
                    ..hMonth = selMonth
                    ..hDay = selDay,
                ),
                child: Text(l10n.yes),
              ),
            ],
          );
        },
      ),
    );

    if (picked != null && mounted) {
      context.read<HomeBloc>().add(HomeHijriDateUpdated(picked));
    }
  }

  Future<void> _confirmReset() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.resetConfirmTitle),
        content: Text(l10n.resetConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.yes,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<HomeBloc>().add(HomeResetRequested());
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (prev, curr) =>
          (prev is HomeLoading && curr is HomeLoaded) ||
          (curr is HomeLoaded && curr.justReset),
      listener: (context, state) {
        if (state is HomeLoaded) _syncControllers(state);
      },
      builder: (context, state) {
        if (state is! HomeLoaded) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        return _buildLoadedUI(state);
      },
    );
  }

  Widget _buildLoadedUI(HomeLoaded state) {
    final l10n = AppLocalizations.of(context);
    final topPad =
        MediaQuery.of(context).padding.top + kToolbarHeight + 8;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.appTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.read<LocaleCubit>().toggleLocale(),
            child: Text(
              l10n.switchLanguageLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: l10n.resetTooltip,
            onPressed: _confirmReset,
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          ListView(
            padding: EdgeInsets.only(
              top: topPad,
              left: 16,
              right: 16,
              bottom: 24,
            ),
            children: [
              _buildDateCard(state.hijriDate, l10n),
              const SizedBox(height: 12),
              ...AppConstants.purities
                  .map((p) => _buildPurityCard(p, state.grams[p.karat] ?? 0.0, l10n)),
              const SizedBox(height: 6),
              _buildResultCard(state.grams, l10n),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────────

  Widget _buildDateCard(HijriCalendar? date, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      color: const Color(0xE0FFFFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _pickHijriDate(date),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: AppColors.primaryDark,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.hijriDateLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date != null
                          ? _formatHijriDate(date, l10n)
                          : l10n.selectHijriDate,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: date != null
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                l10n.isArabic ? Icons.chevron_left : Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurityCard(Purity purity, double currentGrams, AppLocalizations l10n) {
    final karat = purity.karat;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 1,
        color: const Color(0xE0FFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.karatLabel(karat),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              _counterButton(
                Icons.remove,
                () => _decrement(karat, currentGrams),
              ),
              SizedBox(
                width: 82,
                child: TextField(
                  controller: _controllers[karat],
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  decoration: InputDecoration(
                    hintText: '0',
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                  ),
                  onChanged: (text) => _onGramsChanged(karat, text),
                ),
              ),
              _counterButton(
                Icons.add,
                () => _increment(karat, currentGrams),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.gramsUnit,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 20),
      color: AppColors.primary,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0x1A009688),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(6),
        minimumSize: const Size(36, 36),
      ),
    );
  }

  Widget _buildResultCard(Map<int, double> grams, AppLocalizations l10n) {
    final total = ZakatCalculator.totalEquivalent(grams);
    final zakatRequired = ZakatCalculator.isZakatRequired(total);

    return Card(
      elevation: 2,
      color: zakatRequired
          ? const Color(0xEBE0F2F1)
          : const Color(0xEBFFF9C4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.resultTitle,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: zakatRequired
                    ? AppColors.primaryDark
                    : const Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.total24KLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${_formatValue(total)} ${l10n.gramsUnit}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade300, height: 1, thickness: 1),
            const SizedBox(height: 10),
            if (zakatRequired)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.zakatDueLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    '${_formatValue(ZakatCalculator.calculateZakat(total))} ${l10n.gramsUnit}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              )
            else
              Text(
                l10n.zakatNotRequired,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5D4037),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

