import 'package:backtestx/app/app.bottomsheets.dart';
import 'package:backtestx/app/app.dialogs.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/app/route_observer.dart';
import 'package:backtestx/services/theme_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:backtestx/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for Web (IndexedDB backend)
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Setup locator
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  setupSnackbarUi();
  // Load persisted locale choice before starting UI
  await locator<ThemeService>().loadLocale();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = locator<ThemeService>();
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeService.themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: themeService.locale,
          builder: (context, appLocale, __) {
            return MaterialApp(
              title: AppLocalizations.of(context)?.appTitle ?? 'Backtest‑X',
              debugShowCheckedModeBanner: false,
              locale: appLocale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('id'),
              ],
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
                cardTheme: CardTheme(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
                cardTheme: CardTheme(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
              ),
              themeMode: mode,
              initialRoute: Routes.startupView,
              navigatorKey: StackedService.navigatorKey,
              onGenerateRoute: StackedRouter().onGenerateRoute,
              navigatorObservers: [
                StackedService.routeObserver,
                appRouteObserver
              ],
            );
          },
        );
      },
    );
  }
}
