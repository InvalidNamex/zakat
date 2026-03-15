import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/storage_service.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._storage)
      : super(
          _storage.getLocale() == 'en'
              ? const Locale('en')
              : const Locale('ar', 'EG'),
        );

  final StorageService _storage;

  void toggleLocale() {
    final next = state.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar', 'EG');
    _storage.saveLocale(next.languageCode);
    emit(next);
  }
}
