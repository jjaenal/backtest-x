## Progress Update — Project Rules Priorities

- [x] Linting bersih (`flutter analyze`) — tidak ada issues
- [x] Dokumentasi `AuthService` ditambahkan (class + metode inti)
- [x] Redaksi Supabase keys dari `project_rules.md` (gunakan `--dart-define`)
- [ ] Test baseline gagal; rencanakan triage subset unit tests terlebih dulu

## Progress Update — Auth Verification Banner & Cooldown

- [x] Ekstrak widget reusable `VerificationBanner`; integrasi di `LoginView` dan `SignupView`.
- [x] Tambah ticker cooldown per detik di `LoginViewModel` dan `SignupViewModel` (gunakan `Timer.periodic` + `notifyListeners()`).
- [x] Hentikan ticker saat banner ditutup (`dismissVerificationBanner()`); pastikan `dispose()` membersihkan timer; ganti `Future.delayed` dengan ticker setelah kirim ulang.
- [x] Verifikasi via preview web di `http://localhost:8080/`: countdown live, tanpa error.
- [x] Unit test: ticker cooldown Login/Signup (countdown, auto-stop di akhir, dismiss, ticker stop saat dismiss, remaining never negative)
- [x] Helper test: `@visibleForTesting` `debugStartCooldownNow()` + `debugSetCooldownElapsedSeconds()` + `isResendTickerRunning` untuk simulasi cepat
- [x] Opsional: ekstrak warna/gaya banner ke theme extension; tambahkan unit test untuk ticker.
- [x] Opsional: tambahkan debounce pada klik "Kirim Ulang".
- [x] Opsional: tambahkan indikator progress saat cooldown.

# TODO - Implementation Checklist

## Focused Checklist — User Authentication (Google & Email)

Prioritas: deliver login/signup via Google dan email/password, mulai dari Web, lalu iOS/Android.

### High Priority (Sprint 1)

- [x] Pilih provider & arsitektur auth
  - [x] Default: Supabase Auth (`supabase_flutter`) — single source untuk backend
  - [ ] Alternatif (opsional): Firebase Auth (hanya jika perlu compat)
- [x] Tambah dependencies di `pubspec.yaml`
  - [x] `supabase_flutter`
  - [x] (opsional) gunakan `--dart-define` untuk inject keys (dev web)
  - [ ] (opsional) `flutter_secure_storage` untuk secrets lain (bukan session)
- [ ] Konfigurasi platform
  - [ ] Supabase Dashboard: set Redirect URLs (Web/mobile) untuk OAuth Google
  - [x] Web: tidak perlu edit `index.html`; pastikan `SUPABASE_URL` dan `SUPABASE_ANON_KEY` tersedia (preview berjalan)
  - [x] Android: intent filter untuk OAuth callback (custom scheme, ex: `io.supabase.flutter://login-callback`)
  - [x] iOS: `CFBundleURLSchemes` (custom scheme sama), pastikan openURL handler aktif
- [x] Init Supabase di `lib/main.dart`
  - [x] `WidgetsFlutterBinding.ensureInitialized();`
  - [x] `await Supabase.initialize(url: const String.fromEnvironment('SUPABASE_URL'), anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'));` (tanpa `authFlowType` untuk kompatibilitas versi saat ini)
- [x] Implement `AuthService`
  - [x] `signInWithGoogle()` via `supabase.auth.signInWithOAuth(Provider.google)` (auto set `redirectTo` di Web)
  - [x] `signUpWithEmail()` via `supabase.auth.signUp(email, password)`
  - [x] `signInWithEmail()` via `supabase.auth.signInWithPassword(email, password)`
  - [x] `signOut()` via `supabase.auth.signOut()`
  - [x] `sendPasswordResetEmail()` via `supabase.auth.resetPasswordForEmail(email)`
  - [x] Stream `onAuthStateChange` → sinkronisasi dengan ViewModel/Router
- [x] UI & Navigasi
  - [x] `LoginView`: tombol Google + form email/password (banner redirect pasca-login)
  - [x] `LoginView`: tautan "Lupa Password"
  - [x] `SignupView`: form email/password + konfirmasi password
  - [x] `UserView`: menu user (avatar, email, Change Password, Logout, Delete Account, Language, Theme, Help, background processing, etc)
  - [x] Route guard: proteksi akses ke Strategy Builder bila belum login (set redirect + konsumsi di Login)
  - [x] Menu user di AppBar (avatar, email, tombol Sign Out)
- [x] i18n & Error Handling
  - [x] Tambahkan label & pesan error ke `app_en.arb` dan `app_id.arb`
  - [x] Pemetaan error Supabase → pesan ramah pengguna (snackbar/banner)
- [ ] Verifikasi Web
  - [x] Jalankan preview web dengan define: `flutter run -d web-server --dart-define SUPABASE_URL=<url> --dart-define SUPABASE_ANON_KEY=<key>` (UI OK; uji login butuh keys valid)
  - [x] Jalankan widget tests web (Chrome) untuk UI: semua lulus
  - [x] Stabilkan konfigurasi test web (`test/flutter_test_config.dart`) untuk web runner
  - [x] Perbaiki helper test web (hindari `dart:io`, mock `path_provider`)

### Medium Priority (Sprint 2)

- [x] Integrasi mobile (Android/iOS)
  - [x] Konfigurasi redirect scheme & intent filter; uji Google Sign-In pada perangkat
  - [x] Session persistence via `supabase_flutter` (secure storage opsional)
- [x] UX polish
  - [x] Loading state & disable button saat proses auth
  - [x] Konsistensi spacing dengan `StrategyBuilderConstants`
- [x] Arsitektur Stacked
  - [x] `AuthViewModel` + wiring `NavigationService` (redirect on login/logout)
  - [x] Update `app.router.dart` untuk routes & guards

### Low Priority (Sprint 3)

- [x] Password reset flow lengkap (email link & konfirmasi)
- [x] Social login tambahan (Apple, GitHub) — opsional
- [x] CI/guard build: deteksi env yang belum dikonfigurasi; fallback dev‑mode (web)
- [x] Backend: desain tabel `profiles`, `strategies`, `results` di Supabase
- [x] RLS policies untuk per-user akses; migrasi SQL (opsional)
- [x] Dokumentasi
  - [x] README: panduan setup per platform (Web/Android/iOS)
  - [x] COMMANDS.md: ringkas perintah Supabase CLI & Dashboard (referensi)

### Milestone & Deliverables

- Milestone 1: Web login/signup (Google + Email) berjalan; Strategy Builder terproteksi auth
- Milestone 2: Mobile login/signup berjalan dengan persist aman; UX polished
- Milestone 3: Error handling & i18n lengkap; dokumentasi & uji dasar

## Focused Checklist Prioritas refactoring Strategy Builder

- [x] Integrasi Template Picker ke BottomSheetService dan refactor `_showTemplateSheet` - Register `TemplatePickerSheet` sebagai `BottomSheetType.templatePicker` - Ubah pemanggilan dari `showModalBottomSheet` ke `BottomSheetService.showCustomSheet` - Kirim `StrategyBuilderViewModel` via `request.data` untuk sinkronisasi state - Perbaiki logika kategori di `TemplatePickerSheet` (gunakan `_categorizeTemplate` berbasis key) - Verifikasi compile dan preview web tanpa error

- [x] Extract major card widgets (RiskManagement, EntryRules, Preview, etc) ke separate file
- [x] Move \_buildRuleCard() ke separate class - ini yang paling urgent

  - example:

    ```dart
      class _RuleCardBuilder {
        static Widget build(BuildContext context, ...) { ... }

        static Widget _buildIndicatorSection(...) { ... }
        static Widget _buildOperatorSection(...) { ... }
        static Widget _buildValueSection(...) { ... }
        static Widget _buildValidationMessages(...) { ... }
      }
    ```

- [x] Consolidate formatting methods ke utilities

  - example:

    ```dart
      class IndicatorFormatter {
        static String format(IndicatorType indicator) { ... }
        static String formatOperator(BuildContext context, ComparisonOperator op) { ... }
        static String formatRiskType(RiskType type) { ... }
        static String operatorTooltip(BuildContext context, ComparisonOperator op) { ... }
      }
    ```

- [x] Extract reusable dialogs

  - example:

    ```dart
      class _DialogBuilder {
        static Future<void> showConfirmationDialog(
          BuildContext context, {
          required String title,
          required String content,
          required String confirmLabel,
          bool isDangerous = false,
        }) async { ... }
      }
    ```

- [x] Create constants class untuk magic numbers

  - example:

    ```dart
      class StrategyBuilderConstants {
        static const double cardPadding = 16.0;
        static const double itemSpacing = 16.0;
        static const double sectionSpacing = 24.0;
        static const Duration animationDuration = Duration(milliseconds: 180);

        // Timeframe logic constants
        static const int m5CandleCount = 360;
        static const int m15CandleCount = 240;
        static const int h1CandleCount = 180;
        static const int defaultCandleCount = 120;
      }
    ```

## Focused Checklist — Refactor & Optimasi

- [x] Parallel indicator calculation
      Bisa pakai compute() di Flutter buat thread terpisah kalau data candle banyak (supaya nggak freeze UI).
- [x] Modularize Strategy Rules
      Pisahkan evaluasi condition jadi class kecil (misal ConditionEvaluator) biar mudah testing & reusability.
- [x] Use stream atau isolate untuk long backtests
      Biar UI tetap responsif saat running ribuan candle.
- [x] Add intermediate progress callback
      Supaya UI bisa tampilkan progress bar (% backtest selesai).
- [x] Cache indikator antar run
      Kalau user pakai strategi sama dan data sama, nggak perlu hitung ulang semua indikator.

## Focused Checklist — Realtime UI & Refresh

- [x] Buat AppEventBus/stream perubahan di `StorageService` (market_data, strategies, results)
- [x] Emit event pada `saveMarketData`, `deleteMarketData` (dan operasi terkait strategi/hasil)
- [x] Tambah `ReactiveServiceMixin`/stream subscription di ViewModel untuk dengar event
- [x] HomeViewModel: subscribe event market_data & refresh stats/recent uploads otomatis
- [x] HomeViewModel: pasang `RouteObserver` (`didPopNext`) untuk refresh saat kembali dari layar lain
- [x] DataUploadViewModel: emit event setelah upload/delete; refresh `recentUploads` tanpa re‑enter view
- [x] WorkspaceViewModel: subscribe event strategi/hasil; tambah pull‑to‑refresh
- [x] StrategyBuilderViewModel: subscribe market_data; refresh `availableData` & preview list
- [x] PatternScannerViewModel: subscribe market_data; tambah tombol/gesture refresh
- [x] MarketAnalysisViewModel: subscribe market_data; tambah tombol/gesture refresh
- [x] BacktestResultViewModel: subscribe hasil backtest; tombol refresh dan sinkronisasi menu share/export
- [x] Konsolidasi `RefreshIndicator` di view yang belum punya aksi refresh
- [x] Tambah Base class `BaseRefreshableViewModel` (metode `refresh()`) untuk konsistensi
- [x] Invalidate cache `StorageService` pada event; pastikan data terbaru di query berikutnya
- [x] Integrasi dengan `DataManager.warmupNotifier` untuk banner/status cache realtime
- [x] Navigasi hasil: dari Upload → `NavigationService.back(result: true)`; Home tangkap & refresh
- [x] Debounce/throttle event agar UI tidak spam rebuild saat batch operasi
- [x] Throttle per‑event di Backtest Result untuk mencegah over‑refresh
- [x] Indikator status cache di AppBar (ikon validasi cache)
- [x] Unit test: propagasi event → `notifyListeners()` dipanggil; verifikasi refresh via `RouteObserver`
- [x] Dokumentasi di README: perilaku realtime & pola refresh (subscription, RouteObserver)

## Top Priorities (Sorted)

### High Priority

- Workspace Compare: visualize results across timeframes
- Backtest Result: per‑TF chart sorting by metric value [Completed]
- Performance: memory optimization for large datasets (>10k candles) [Completed]
- Known Issues: BacktestEngine edge cases; division by zero; parser messages; storage migration [Completed]
- Anchored VWAP: Anchor Mode (Start/Date) with Strategy Builder controls [Completed]
- Multi‑language support (English + Indonesian)

## 🎯 Focused Checklist — Performance: Memory Optimization (>10k candles)

- [x] Profile memory hotspots using DevTools (timeline/memory)
- [x] Virtualize long lists with builder widgets (`ListView.builder`, `GridView.builder`)
- [x] Downsample chart series per zoom/window to limit draw calls
- [x] Cache aggregated stats and reuse computed values across views
- [x] Throttle UI notifications and window updates to reduce rebuilds
- [x] Integration test for 10k+ candles scenario (Web + Mobile)
- [x] Document performance best practices in README (charts, lists, isolates)
- [x] Isolate backtest stress test on 50k candles
- [x] EMA crossover backtest performance test on 20k candles
- [x] RSI threshold backtest performance test on 20k candles
- [x] Isolate backtest stress test on 100k candles

## 🎯 Focused Checklist — Known Issues: Engine/Indicator/Parser/Storage

- [x] `IndicatorService`: add division-by-zero guards and unit tests
- [x] `BacktestEngineService`: handle empty data and single-candle runs
- [x] `DataParserService`: improve error messages with line/column context
- [x] `StorageService`: migration safety, fallback path, and validation routine
- [x] Unit tests covering these edge cases end-to-end
- [x] Basic error surfaces in UI (snackbar/banner) for critical failures

### Test/Golden & Plugins

- [x] Golden tests: HomeView empty/default/populated/warm-up states stabilized
- [x] Deterministic golden setup (viewport, DPR, limited pumps)
- [x] Document golden commands and tips (COMMANDS.md, README.md)
- [x] Disable background warm-up in tests via `DataManager.setBackgroundWarmupEnabled(false)`
- [x] Add golden: populated state after warm-up completed (banner hidden)
- [x] Mock `getApplicationDocumentsDirectory` in tests (helper `mockPathProviderForTests()`) to avoid MissingPluginException
- [x] Configure `dart_test.yaml` tags (`golden`) and use `--tags golden`
- [x] Annotate golden tests with `@Tags(['golden'])`
- [x] Add helper `silenceInfoLogsForTests()` to raise logger threshold in tests
- [x] Consolidate sqflite FFI init for unit tests (central helper `initSqfliteFfiForTests()`)
- [x] Investigate `file_picker` platform plugin warnings; decision: informational only, safe to ignore in tests

### Medium Priority

- UI/UX: error handling UI; onboarding tutorial; empty states
- Documentation: Theming Guide for contributors
- Export: combined Chart+Panel multi‑page PDF; dynamic file naming

#### Focused Checklist — Medium Priority

- [x] Tambahkan UI error handling (banner/toast + aksi retry)
- [x] Implementasikan onboarding tutorial (persist status selesai)
- [x] Desain & hubungkan empty states (Home, Workspace, Upload)
- [x] Susun Theming Guide: colorScheme & token system
- [x] Tambahkan contoh palet terang/gelap beserta panduan penggunaan
- [x] Dokumentasikan praktik styling komponen dengan contoh
- [x] Implementasi ekspor PDF multi‑halaman (Chart + Panel)
- [x] Tambahkan pagination/layout untuk dataset panjang
- [x] Terapkan penamaan file dinamis `<strategy>-<tf>-<date>.pdf` (sanitize)
- [x] Tambahkan unit test untuk penamaan & generasi PDF

### Low Priority

- Social sharing integration
  - [x] Mobile share via `share_plus` (Android/iOS) via ShareService
  - [x] Web share via Web Share API, fallback copy text or download file
  - [x] Share PDF exports and chart snapshot images
  - [x] Share summary text
  - [x] Deep links to results
  - [x] Deep links to strategies
  - [x] Sanitize content & validate filenames
  - [x] PII removal policy and redaction rules
  - [x] Document usage and examples in README

## Next Sprint (1–2 weeks)

- Deliver Workspace Compare MTF visualization (charts + summary)
- Multi‑timeframe analysis across views (Phase 2 milestone)
- Expand tests coverage (IndicatorService, BacktestEngine, refresh propagation)
- Draft Theming Guide section (colorScheme, opacity rationale)
- Implement core multi‑language infra (id/en) and migrate key screens

## 🎯 Focused Checklist — Multi‑language (i18n/L10n)

- [x] Decide approach: Flutter `gen_l10n` + ARB files (`intl`, `flutter_localizations`) — interim stub `AppLocalizations` to compile now
- [x] Enable localization in `pubspec.yaml` (generate `AppLocalizations` via `flutter gen-l10n`) — deferred; stub active and wired
- [x] Create base ARB files: `lib/l10n/app_en.arb`, `lib/l10n/app_id.arb` — added keys for Home/Startup
- [x] Wire `MaterialApp` with `localizationsDelegates`, `supportedLocales: [en, id]`, and `AppLocalizations` — using stub delegate
- [x] Locale state & persistence via `PrefsService` (system default, English, Indonesian) — menu toggles working
- [x] Settings: add Language selector (System default / English / Indonesian) — available in Home options
- [x] Migrate hardcoded strings across views/widgets (Home, Startup) — remaining:
  - [x] Data Upload
  - [ ] Workspace
  - [ ] Workspace Compare
  - [ ] Backtest Result
  - [ ] Strategy Builder
  - [x] Pattern Scanner
  - [x] Market Analysis
  - [x] sheets
    - [x] candlestick pattern guide
    - [x] indicator settings
    - [x] pattern guide
    - [x] onboarding
    - [x] quick start template
- [x] Localize menu labels, tooltips, banners, errors, snackbar/toasts — core Home/Startup tooltips/banners
- [ ] Localize PDF export labels/content and file naming
- [ ] Locale‑aware number/date formatting (`intl`)
  - [x] Workspace (currency/PnL, Win Rate %, PF, dates)
  - [ ] PDF exports (number/date/currency formatting)
  - [ ] CSV exports (number/date formatting)
  - [ ] Workspace Compare
  - [ ] Backtest Result
  - [ ] Strategy Builder
  - [ ] Market Analysis
- [ ] Interpolation & plurals for counts (trades, signals, wins)
- [ ] RTL readiness baseline (no layout break; respect `Directionality` where applicable)
- [ ] Tests: unit for localization lookups; golden for key screens in `en`/`id`
- [ ] Docs: README section for localization and contribution guidelines
- [ ] CI/guard: script to check ARB key consistency and unused keys (optional)

## Progress Update — ATR Enhancements

- Completed: Full MTF support for `ATR%` in engine/rules
- Completed: Dynamic `ATR%` presets (percentiles P25/P50/P75/P90) in Strategy Builder UI
- Completed: `RiskType.atrBased` option with ATR‑based position sizing in engine and UI
- Completed: PDF export labels updated for ATR‑based sizing

### Next Up (Prioritized)

- Workspace Compare MTF visualization (charts + summary)
- Multi‑timeframe analysis across views (Phase 2 milestone)

## Auth Test Checklist (Web)

- Run dev server: `make run-web URL=<supabase_url> KEY=<anon_key>` on `http://localhost:8081/`.
- Email signup: submit -> open verification email -> confirm -> app auto-login -> redirect ke rute tersimpan (jika ada) setelah login.
- Email login: login -> akses rute terproteksi terbuka; banner verifikasi muncul hingga email terkonfirmasi.
- Resend verification: klik kirim ulang -> cooldown berjalan (detik) -> tombol nonaktif selama cooldown.
- Password recovery: klik "Lupa Password" -> buka link dari email -> app menampilkan dialog ganti password -> login dengan password baru.
- Google OAuth: login berhasil; kembali ke origin; rute terproteksi terbuka.
