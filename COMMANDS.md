# Development Commands Cheatsheet

## 🚀 Initial Setup

```bash
# Create Flutter project
flutter create backtestx
cd backtestx

# Add all dependencies from pubspec.yaml
flutter pub get

# Generate code (run this after EVERY model change)
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🔄 Code Generation

### When to Run

Run build_runner when you:

- Create/modify Freezed models
- Create/modify JSON serializable models
- Add new routes in app.dart
- Add new services in app.dart

### Commands

```bash
# Generate all code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean generated files
flutter pub run build_runner clean

# Full clean rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📱 Running App

```bash
# Run on connected device
flutter run

# Run with hot reload
flutter run --hot

# Run specific device
flutter devices  # List devices
flutter run -d chrome  # Web
flutter run -d android  # Android
flutter run -d ios  # iOS

# Release build
flutter run --release
```

## 🏗️ Stacked CLI (Optional but Recommended)

```bash
# Install Stacked CLI globally
dart pub global activate stacked_cli

# Create new view with ViewModel
stacked create view home
stacked create view strategy_builder
stacked create view backtest_result

# Create service
stacked create service export
stacked create service chart

# Create widget
stacked create widget candlestick_chart

# Update app (regenerate locator & routes)
stacked generate
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/indicator_service_test.dart

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Widget tests
flutter test test/ui/views/home_view_test.dart
```

### Performance Tests (Quick)

```bash
# Integration 10k+ candles
flutter test test/performance/backtest_large_dataset_test.dart

# Isolate stress 50k candles
flutter test test/performance/backtest_isolate_stress_test.dart

# EMA crossover 20k candles
flutter test test/performance/backtest_ema_20k_test.dart

# RSI threshold 20k candles
flutter test test/performance/backtest_rsi_20k_test.dart

# Isolate stress 100k candles
flutter test test/performance/backtest_isolate_100k_stress_test.dart
```

## 🖼️ Golden Tests

```bash
# Update golden baseline for a specific test
flutter test test/golden/home_view_populated_golden_test.dart --update-goldens

# Run all golden tests with compact output
flutter test test/golden -r compact

# Run a single test by name (VM)
dart test test/golden/home_view_populated_golden_test.dart \
  -p vm --plain-name 'HomeView - populated state'

# Run all golden tests via tag (configured in dart_test.yaml)
flutter test --tags golden

# Update all golden baselines via tag
flutter test --tags golden --update-goldens
```

# Commands

## Flutter

- Run the app: `flutter run`
- Analyze: `flutter analyze`
- Format: `dart format .`

## Golden Tests

Preferred (stable, bypass disk I/O via `GOLDEN_TEST`):

- Run all goldens: `make goldens`
- Update all goldens: `make goldens-update`

### Grup HomeView

- Jalankan semua skenario HomeView: `make goldens-home`
- Update semua baseline HomeView: `make goldens-update-home`

Kedua perintah berjalan berurutan untuk skenario:
- default
- empty
- populated
- populated warmup
- populated postwarmup
- warmup

Semua dijalankan dengan `--dart-define=GOLDEN_TEST=true` untuk bypass I/O disk.

Update per-file:

- Update default: `make golden-update-home-default`
- Update empty: `make golden-update-home-empty`
- Update populated: `make golden-update-home-populated`
- Update populated warmup: `make golden-update-home-populated-warmup`
- Update populated postwarmup: `make golden-update-home-populated-postwarmup`
- Update warmup: `make golden-update-home-warmup`

Notes:

- These commands pass `--dart-define=GOLDEN_TEST=true` so `DataManager` skips disk cache init and read/write during tests, preventing hangs.
- Ensure deterministic snapshots: use `TickerMode(enabled: false)`, add sufficient `pump` cycles, and avoid async side effects.
- If DB-backed tests are needed later, consider `sqflite_common_ffi` and call `initSqfliteFfiForTests()` before running.

Tips agar snapshot deterministik:
- Kunci viewport: set `SurfaceSize` dan `devicePixelRatio` ke nilai tetap.
- Hindari `pumpAndSettle`; gunakan beberapa `pump` pendek lalu `expectLater`.
- Matikan warm-up background `DataManager` di test untuk mencegah churn async.
- Stub `StorageService` untuk mengontrol jumlah strategi, datasets, dan `latest result`.

Troubleshooting umum:
- `MissingPluginException(getApplicationDocumentsDirectory)`: muncul di VM test saat `path_provider` tidak tersedia. Abaikan jika tidak memblokir, atau hindari operasi disk (jangan panggil `DataManager.cacheData(...)` di golden).
- `databaseFactory not initialized`: jika memakai `sqflite_common_ffi` di VM, inisialisasi di setup test: `databaseFactory = databaseFactoryFfi;`.
 - Pesan log yang bising: panggil `silenceInfoLogsForTests()` di `setUpAll` untuk menaikkan threshold logger ke `warning`.

## DevTools Memory Profiling

```bash
# 1) Launch app in Profile mode (recommended)
flutter run -d chrome --profile --web-port 7357
# or
flutter run -d macos --profile

# 2) Start DevTools server (if IDE doesn't auto-launch)
dart devtools
# DevTools prints a URL, e.g. http://127.0.0.1:9100

# 3) Open DevTools → Memory tab
# - Take heap snapshots
# - Monitor allocation/GC during interactions
# - Use Diff to compare before/after heavy interactions

# 4) Optional: record Timeline for frame analysis

# 5) Web rendering tweaks for charts
flutter run -d chrome --profile --web-renderer canvaskit --web-port 7357
```

## 📦 Build & Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires Mac + Xcode)
flutter build ios --release

# Generate app icons
flutter pub run flutter_launcher_icons:main

# Generate splash screen
flutter pub run flutter_native_splash:create
```

## 🗄️ Database

```bash
# View SQLite database (Android)
adb shell
run-as com.yourcompany.backtestx
cd databases/
cat backtestx.db

# Pull database to local (for inspection)
adb pull /data/data/com.yourcompany.backtestx/databases/backtestx.db

# Open with DB Browser for SQLite
# Download: https://sqlitebrowser.org/
```

## 🐛 Debugging

```bash
# Debug with logs
flutter run --verbose

# Debug with DevTools
flutter run --observatory-port=8888
# Open: http://localhost:8888

# Check for issues
flutter doctor -v
flutter analyze

# Fix formatting
dart format lib/

# Check unused dependencies
flutter pub deps
```

## 🧹 Cleanup

```bash
# Clean build files
flutter clean

# Remove generated files
find . -name "*.g.dart" -delete
find . -name "*.freezed.dart" -delete

# Full reset (nuclear option)
flutter clean
rm -rf pubspec.lock
rm -rf .dart_tool/
rm -rf build/
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📝 Git Workflow

```bash
# Ignore generated files in .gitignore
*.g.dart
*.freezed.dart
*.gr.dart
*.config.dart
*.lock
.dart_tool/
build/

# Commit
git add .
git commit -m "feat: add backtest engine service"
git push origin main
```

## 🔥 Quick Dev Workflow

```bash
# Terminal 1: Watch for changes
flutter pub run build_runner watch

# Terminal 2: Run app with hot reload
flutter run --hot

# Make changes → Save → Hot reload automatically
```

## 📊 Performance Profiling

```bash
# Profile performance
flutter run --profile

# Trace Dart code
flutter run --trace-startup

# Memory profiling
flutter run --observatory-port=8888
# Use DevTools memory profiler
```

## 🌐 Web Development

```bash
# Run on web
flutter run -d chrome

# Build web
flutter build web --release

# Serve locally
cd build/web
python3 -m http.server 8000
# Open: http://localhost:8000
```

## 📱 Device Screenshots

```bash
# Take screenshot
flutter screenshot

# Record screen
flutter drive --target=test_driver/app.dart
```

## 🔐 Environment Variables

```bash
# Create .env file
API_KEY=your_api_key
BASE_URL=https://api.example.com

# Use flutter_dotenv
flutter pub add flutter_dotenv

# Load in main.dart
await dotenv.load();
```

## 📚 Documentation

```bash
# Generate documentation
dart doc .

# Serve docs
dhttpd --path doc/api

# Open: http://localhost:8080
```

## 🎯 Quick Commands Reference

| Task          | Command                                 |
| ------------- | --------------------------------------- |
| Install deps  | `flutter pub get`                       |
| Generate code | `flutter pub run build_runner build -d` |
| Run app       | `flutter run`                           |
| Hot reload    | `r` (in running app)                    |
| Hot restart   | `R` (in running app)                    |
| Tests         | `flutter test`                          |
| Format        | `dart format lib/`                      |
| Analyze       | `flutter analyze`                       |
| Clean         | `flutter clean`                         |
| Build APK     | `flutter build apk --release`           |

## 🚨 Common Fixes

### "Version solving failed"

```bash
flutter clean
rm pubspec.lock
flutter pub get
```

### "Build runner conflicts"

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### "No devices found"

```bash
# Android
flutter devices
adb devices
adb kill-server && adb start-server

# iOS
open -a Simulator
```

### "Gradle build failed" (Android)

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

**Pro Tip:** Alias commands in your shell config:

```bash
# Add to ~/.zshrc or ~/.bashrc
alias fbuild="flutter pub run build_runner build --delete-conflicting-outputs"
alias fwatch="flutter pub run build_runner watch --delete-conflicting-outputs"
alias frun="flutter run --hot"
alias ftest="flutter test"
alias fclean="flutter clean && flutter pub get"
```

### Filter berdasarkan nama/file

- Filter nama (run): `make goldens-name NAME="HomeView warmup"`
- Filter nama (update): `make goldens-update-name NAME="HomeView warmup"`
- Filter file (run): `make goldens-file FILE=test/golden/home_view_populated_golden_test.dart`
- Filter file (update): `make goldens-update-file FILE=test/golden/home_view_populated_golden_test.dart`

Tips:
- Kutip `NAME` jika mengandung spasi.
- Semua perintah menyertakan `--dart-define=GOLDEN_TEST=true` untuk bypass I/O disk.
