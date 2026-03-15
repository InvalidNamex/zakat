import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../../constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final StorageService _storage;

  HomeBloc({required StorageService storage})
      : _storage = storage,
        super(HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeGramsUpdated>(_onGramsUpdated);
    on<HomeHijriDateUpdated>(_onHijriDateUpdated);
    on<HomeResetRequested>(_onResetRequested);
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    final gramsMap = <int, double>{
      for (final p in AppConstants.purities) p.karat: _storage.getGrams(p.karat),
    };
    HijriCalendar? hijriDate;
    final saved = _storage.getHijriDate();
    if (saved != null) {
      hijriDate = HijriCalendar()
        ..hYear = saved.year
        ..hMonth = saved.month
        ..hDay = saved.day;
    }
    emit(HomeLoaded(grams: gramsMap, hijriDate: hijriDate));
  }

  Future<void> _onGramsUpdated(
    HomeGramsUpdated event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is HomeLoaded) {
      final newGrams = Map<int, double>.from(current.grams)
        ..[event.karat] = event.grams;
      await _storage.saveGrams(event.karat, event.grams);
      emit(current.copyWith(grams: newGrams));
    }
  }

  Future<void> _onHijriDateUpdated(
    HomeHijriDateUpdated event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is HomeLoaded) {
      await _storage.saveHijriDate(
        year: event.date.hYear,
        month: event.date.hMonth,
        day: event.date.hDay,
      );
      emit(current.copyWith(hijriDate: event.date));
    }
  }

  Future<void> _onResetRequested(
    HomeResetRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _storage.reset();
    emit(HomeLoaded(
      grams: {for (final p in AppConstants.purities) p.karat: 0.0},
      justReset: true,
    ));
  }
}
