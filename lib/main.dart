import 'package:backtestx/app/app.bottomsheets.dart';
import 'package:backtestx/app/app.dialogs.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup locator
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  setupSnackbarUi();

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
        return MaterialApp(
          title: 'Backtest Pro',
          debugShowCheckedModeBanner: false,
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
          navigatorObservers: [StackedService.routeObserver],
        );
      },
    );
  }
}
