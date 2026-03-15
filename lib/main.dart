import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'constants/app_colors.dart';
import 'core/bloc/locale_cubit.dart';
import 'core/services/storage_service.dart';
import 'features/home/bloc/home_bloc.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.create();
  runApp(ZakatApp(storage: storage));
}

class ZakatApp extends StatelessWidget {
  const ZakatApp({super.key, required this.storage});

  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit(storage)),
        BlocProvider(create: (_) => HomeBloc(storage: storage)),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            title: locale.languageCode == 'ar' ? 'زكاة الذهب' : 'Gold Zakat',
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: const [
              Locale('ar', 'EG'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              fontFamily: 'Cairo',
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: AppColors.background,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
