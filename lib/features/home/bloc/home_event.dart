import 'package:hijri/hijri_calendar.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class HomeLoadRequested extends HomeEvent {}

final class HomeGramsUpdated extends HomeEvent {
  final int karat;
  final double grams;
  const HomeGramsUpdated(this.karat, this.grams) : super();
}

final class HomeHijriDateUpdated extends HomeEvent {
  final HijriCalendar date;
  const HomeHijriDateUpdated(this.date) : super();
}

final class HomeResetRequested extends HomeEvent {}
