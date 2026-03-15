import 'package:hijri/hijri_calendar.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final Map<int, double> grams;
  final HijriCalendar? hijriDate;

  /// True only when this state was emitted as a result of a reset, so the
  /// UI listener can clear the text controllers.
  final bool justReset;

  HomeLoaded({
    required this.grams,
    this.hijriDate,
    this.justReset = false,
  });

  HomeLoaded copyWith({
    Map<int, double>? grams,
    HijriCalendar? hijriDate,
    bool justReset = false,
  }) {
    return HomeLoaded(
      grams: grams ?? this.grams,
      hijriDate: hijriDate ?? this.hijriDate,
      justReset: justReset,
    );
  }
}
