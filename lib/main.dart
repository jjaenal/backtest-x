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
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:backtestx/services/auth_service.dart';
import 'package:universal_html/html.dart' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for Web (IndexedDB backend)
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Setup locator
  await setupLocator();

  // On Web: sanitize URL before Supabase.initialize to avoid unhandled AuthException
  if (kIsWeb) {
    try {
      final href = html.window.location.href;
      final uri = Uri.tryParse(href);
      if (uri != null) {
        final qp = Map<String, String>.from(uri.queryParameters);
        final fragUri =
            uri.fragment.isNotEmpty ? Uri.tryParse(uri.fragment) : null;
        final fragQp = fragUri?.queryParameters ?? const {};
        final error = qp['error'] ?? fragQp['error'];
        final errorDesc =
            qp['error_description'] ?? fragQp['error_description'];
        if (error != null || errorDesc != null) {
          // Persist a hint in sessionStorage to show a friendly message later
          html.window.sessionStorage['supabase_auth_error'] =
              errorDesc ?? error ?? 'unknown';
          // Remove error params from query
          final cleanedQuery = Map<String, String>.from(qp)
            ..remove('error')
            ..remove('error_description');
          // Remove error params from fragment if present
          String? cleanedFragment;
          if (fragUri != null) {
            final cleanedFragQuery = Map<String, String>.from(fragQp)
              ..remove('error')
              ..remove('error_description');
            final fragClean = Uri(
              path: fragUri.path,
              queryParameters:
                  cleanedFragQuery.isEmpty ? null : cleanedFragQuery,
            ).toString();
            cleanedFragment = fragClean.isEmpty ? null : fragClean;
          }
          final newUri = Uri(
            scheme: uri.scheme,
            userInfo: uri.userInfo,
            host: uri.host,
            port: uri.port,
            path: uri.path,
            queryParameters: cleanedQuery.isEmpty ? null : cleanedQuery,
            fragment: cleanedFragment,
          ).toString();
          html.window.history.replaceState(null, '', newUri);
        }
      }
    } catch (_) {
      // Non-critical; continue
    }
  }

  // Initialize Supabase (use dart-define SUPABASE_URL & SUPABASE_ANON_KEY)
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://localhost',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'invalid-key',
  );
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  setupDialogUi();
  setupBottomSheetUi();
  setupSnackbarUi();

  // Load persisted locale choice before starting UI
  await locator<ThemeService>().loadLocale();
  runApp(const MyApp());

  // Initialize auth listener AFTER first frame to ensure navigator is ready
  WidgetsBinding.instance.addPostFrameCallback((_) {
    locator<AuthService>().setupGlobalPasswordRecoveryListener();
  });
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
