# Backtest-X - Trading Backtest Application

Full-featured trading backtest application for retail traders built with Flutter & Stacked architecture.

## 🚀 Quick Start

### Prerequisites

```bash
Flutter SDK >= 3.0.0
Dart SDK >= 3.0.0
```

### Installation

1. **Clone & Install Dependencies**

```bash
flutter pub get
```

2. **Generate Code** (Stacked, Freezed, JSON)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. **Run the App**

```bash
flutter run
```

## 📱 Key Features

- **Strategy Builder**: Create trading strategies with custom entry/exit rules
- **Backtest Engine**: Test strategies against historical data
- **Performance Analytics**: Comprehensive statistics and visualizations
- **Multi-platform Support**: Works on Web, Android, iOS, and desktop platforms
- **Data Import/Export**: Import CSV data and export backtest results (CSV, PDF)
  - Export trades to CSV from Backtest Result view
  - Export comparison results to CSV from Compare Results view
  - Copy comparison summary to clipboard from Compare Results view
  - Copy backtest summary to clipboard from Backtest Result view
  - Copy trades CSV to clipboard from Workspace results
  - Copy backtest summary to clipboard from Workspace results
  - Export trades to CSV from Workspace results list
- PDF report includes Strategy Details section and improved charts (grid, axis labels, date range)
- **Share Results**: Share backtest results with others
 - **Auto-save**: Strategy Builder auto-saves drafts to prevent data loss
- **Workspace Filters**: Filter results by Profit/PF/Win Rate, Symbol, Timeframe, and Date Range
- **Background Cache Warm-up**: Pause/enable toggle and manual "Load Now" on Home
- **Warm-up Indicator Banner**: "Loading cache…" visible during background loading
- **Quick Stats Skeletons**: Placeholder numbers on Home while data loads

## 🧭 Usage - Workspace Filters

Langkah menggunakan filter di `Workspace`:
- Buka view `Workspace` dari menu utama.
- Pada kartu strategi, scroll ke daftar `Results`.
- Gunakan `FilterChip` untuk performa: `Profit Only`, `PF > 1`, `Win Rate > 50%`.
- Pilih `Symbol` dan `Timeframe` lewat dropdown di atas daftar hasil.
- Atur `Start Date` dan `End Date` untuk membatasi hasil berdasarkan tanggal eksekusi.
- Klik `Clear Filters` untuk mengembalikan semua hasil.
- Daftar hasil akan otomatis terfilter sesuai pilihan.

Catatan:
- Opsi `Symbol/Timeframe` diambil dari data hasil yang tersimpan untuk strategi tersebut.
- Jika opsi kosong atau terbatas, jalankan backtest agar data tersedia.
- Tombol `Export CSV` di header daftar hasil mengekspor ringkasan sesuai hasil terfilter (termasuk tanggal).

Export CSV (filtered):
- Gunakan tombol `Export CSV` di header daftar hasil untuk mengekspor ringkasan hasil yang sedang terfilter.
- Atau, buka menu aksi (`⋮`) pada kartu strategi dan pilih `Export Results (CSV)` untuk hasil terfilter yang sama.
- File berisi kolom: `Strategy`, `Symbol`, `Timeframe`, `Executed At`, `Total Trades`, `Win Rate %`, `Profit Factor`, `Total PnL`, `Total PnL %`, `Max Drawdown`, `Max DD %`, `Sharpe`.
- Ekspor mengikuti semua filter aktif: performa, symbol, timeframe, dan rentang tanggal.

## ⚡ Quick Test & Batch (Workspace)

Gunakan aksi cepat di kartu strategi untuk menjalankan backtest tanpa meninggalkan Workspace:
- Pilih `market data` dari dropdown di area Quick Actions.
- Klik `Quick Test` untuk menjalankan satu backtest pada data terpilih.
- Klik `Run Batch` untuk menjalankan backtest berturut pada semua data yang tersedia. Setiap hasil disimpan otomatis ke database dan muncul di daftar hasil.
- Selama proses berjalan, tombol akan nonaktif dan menampilkan indikator progres (spinner) untuk mencegah aksi ganda.

## 🔧 Usage - Home Cache Warm-up

Kontrol pemuatan cache market data di Home:
- Buka menu `⋮` di `AppBar` Home.
- Pilih `Pause Background Warm-up` atau `Enable Background Warm-up` untuk menonaktifkan/menyalakan proses background.
- Klik `Load Cache Now` untuk memaksa pemuatan cache segera.
- Saat proses berjalan, banner teks `Loading cache…` muncul di kiri bawah layar. Angka quick stats menampilkan skeleton sampai data siap.

Catatan:
- Proses warm-up ditahan bila toggle dimatikan, dan dilanjutkan kembali saat diaktifkan.
- Throttling & batching mengurangi spike I/O sehingga UI tetap responsif.

Catatan:
- `Run Batch` menggunakan seluruh koleksi data yang tersedia di aplikasi. Jika ingin membatasi jumlah, opsi batas maksimum akan ditambahkan kemudian (planned).
- Hasil batch langsung tersimpan dan akan ikut terfilter oleh pilihan aktif (Profit/PF/Win Rate, Symbol, Timeframe, Date Range) saat ditampilkan.

## 📁 Project Structure

```
lib/
├── app/
│   ├── app.dart                 # Stacked app config
│   ├── app.locator.dart         # DI (auto-generated)
│   └── app.router.dart          # Routes (auto-generated)
├── core/
│   ├── data_manager.dart
├── ui/
│   ├── views/
│   │   ├── home/
│   │   │   ├── home_view.dart
│   │   │   └── home_viewmodel.dart
│   │   ├── data_upload/
│   │   │   ├── data_upload_view.dart
│   │   │   └── data_upload_viewmodel.dart
│   │   ├── pattern_scanner/
│   │   │   ├── pattern_scanner_view.dart
│   │   │   └── pattern_scanner_viewmodel.dart
│   │   ├── strategy_builder/
│   │   │   ├── strategy_builder_view.dart
│   │   │   └── strategy_builder_viewmodel.dart
│   │   ├── market_analysis/
│   │   │   ├── market_analysis_view.dart
│   │   │   └── market_analysis_viewmodel.dart
│   │   ├── backtest_result/
│   │   │   ├── backtest_result_view.dart
│   │   │   └── backtest_result_viewmodel.dart
│   │   ├── startup/
│   │   │   ├── startup_view.dart
│   │   │   └── startup_viewmodel.dart
│   │   └── workspace/
│   │       ├── workspace_view.dart
│   │       └── workspace_viewmodel.dart
│   └── widgets/
│       ├── candlestick_chart/
|       |   └── candlestick_chart.dart
│       ├── indicator_panel/
│       │   └── indicator_panel.dart
│       └── equity_curve/
│           └── equity_curve.dart
├── services/
│   ├── data_parser_service.dart
│   ├── backtest_engine_service.dart
|   |── data_validation_service.dart
│   ├── indicator_service.dart
│   └── storage_service.dart
├── models/
│   ├── candle.dart              # Freezed model
│   ├── strategy.dart            # Freezed model
│   └── trade.dart               # Freezed model
├── helpers/
│   ├── backtest_helper.dart
│   ├── comparison_helper.dart
│   └── strategy_stats_helper.dart
└── main.dart
```

## 📦 Dependencies

Key packages used in this project:

```yaml
dependencies:
  flutter:
    sdk: flutter
  stacked: ^3.4.0
  stacked_services: ^1.1.0

  # Data & Storage
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  csv: ^6.0.0
  share_plus: ^7.2.1
  universal_html: ^2.2.4

  # Charts
  fl_chart: ^0.65.0
  candlesticks: ^2.1.0

  # Utils
  intl: ^0.18.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  uuid: ^4.2.1
  
  # Export (PDF)
  pdf: ^3.10.8
  printing: ^5.12.0
```

## 🏗️ Architecture

### Stacked MVVM Pattern

**View** → **ViewModel** → **Service** → **Model**

- **Views**: Pure UI, no business logic
- **ViewModels**: Handle UI state & user interactions
- **Services**: Business logic (backtest engine, indicators, storage)
- **Models**: Data structures with Freezed (immutable)

### Key Services

#### 1. DataParserService

- Parse CSV files (OHLCV format)
- Auto-detect headers
- Validate data integrity

#### 2. IndicatorService

- Technical indicators: SMA, EMA, RSI, ATR, MACD, Bollinger Bands
- Reusable calculation methods
- Optimized for performance

#### 3. BacktestEngineService

- Core backtest loop
- Entry/Exit condition evaluation
- Risk management (SL/TP)
- Performance statistics

#### 4. StorageService

- SQLite local storage
- Save/load strategies
- Store backtest results
- Market data management

## 📊 Data Format

### CSV Upload Format

```csv
Date,Open,High,Low,Close,Volume
2024-01-01 00:00:00,1.0500,1.0520,1.0495,1.0510,1000
2024-01-01 01:00:00,1.0510,1.0530,1.0505,1.0525,1200
```

**Requirements:**

- Date format: `YYYY-MM-DD HH:mm:ss` or any parseable format
- Columns: Date, Open, High, Low, Close, Volume (optional)
- Headers: Optional (auto-detected)

## 🔧 Adding New Features

### Create New View (Stacked CLI)

```bash
# Install Stacked CLI
dart pub global activate stacked_cli

# Create new view with ViewModel
stacked create view strategy_builder

# Create service
stacked create service export
```

### Manual Creation

1. **Create View & ViewModel**

```dart
// lib/ui/views/my_view/my_view.dart
class MyView extends StackedView<MyViewModel> {
  // Implementation
}

// lib/ui/views/my_view/my_viewmodel.dart
class MyViewModel extends BaseViewModel {
  // Logic here
}
```

2. **Register in app.dart**

```dart
@StackedApp(
  routes: [
    MaterialRoute(page: MyView),
  ],
  dependencies: [
    // Add services
  ],
)
class App {}
```

3. **Regenerate Code**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🧪 Testing

### Test Indicators

```dart
void main() {
  final indicatorService = IndicatorService();
  final candles = [...]; // Sample data

  final sma = indicatorService.calculateSMA(candles, 20);
  final rsi = indicatorService.calculateRSI(candles, 14);

  expect(sma.last, closeTo(1.0500, 0.0001));
}
```

### Test Backtest Engine

```dart
void main() {
  final engine = BacktestEngineService(IndicatorService());

  final result = await engine.runBacktest(
    marketData: sampleData,
    strategy: sampleStrategy,
  );

  expect(result.summary.winRate, greaterThan(50));
}
```

## 🎯 Development Roadmap

### Phase 1 - MVP (Current)

- [x] Project setup & architecture
- [x] Data parser service
- [x] Indicator service (SMA, EMA, RSI, ATR, MACD, BB)
- [x] Backtest engine core
- [x] Storage service (SQLite)
- [x] Home view
- [x] Data upload view
- [x] Strategy builder view (form-based)
- [x] Backtest result view
- [x] Workspace view
- [x] Market analysis view
- [x] Pattern scanner view
- [x] comparison view
- [x] Basic charts

### Phase 2 - Polish (Next 3 months)

- [x] Export results (CSV, PDF)
- [x] Save/load strategies
- [ ] Multi-timeframe analysis
- [ ] UI/UX improvements
- [x] Dark/Light theme toggle
- [x] Advanced charts (candlestick with indicators)

## ✅ Recent Progress

- Dark theme consistency pass across key screens:
  - Workspace view, Backtest Result view
  - Strategy Builder entry/exit rules
  - Candlestick chart labels and grid
  - Pattern Scanner candlestick guide sheet
  - Market Analysis indicator settings sheet
- Equity/Drawdown toggle UI refined (themed background + outline)
- Chart info panel and price labels made theme-aware
- Comparison View improvements:
  - Show human-readable strategy names in cards and table
  - Add "Copy Summary" menu to copy comparison stats to clipboard
 - Loading skeletons for smoother UX:
   - Workspace results list and quick actions show skeletons on busy
   - Backtest Result chart area uses AnimatedSwitcher to show skeleton while loading
   - Busy states wired so skeletons appear on initial load and async actions
 - Chart performance optimization:
   - Downsample candles in Backtest Result when dataset is large (>1500 points)
   - Cuts render jank on Flutter Web with big OHLC series
 - Storage performance:
   - Added SQLite index on `market_data.uploaded_at` for faster sorting
   - Existing indexes on strategies and backtest_results retained
- Backtest Result improvements:
  - Add "Copy Summary" button to copy backtest stats to clipboard
 - Workspace results quick actions:
   - Add "Copy Trades CSV", "Copy Summary", and "Export CSV" buttons on each result
   - Verified on Web build and preview
 - Workspace results list:
   - Implement lazy loading with paginated "Load more" to handle large result sets
   - Shows current count vs total (e.g., 20/200) for clarity
 - Strategy Builder:
   - Auto-save drafts with debounce to prevent data loss
   - Validation & UX improvements:
     - Per-rule warnings/errors displayed on rule cards
     - Fatal errors block Save and Quick Test actions
     - Disabled buttons when fatal errors or preview running, with tooltips explaining why
     - Inline error text on Value, Compare With, and Period fields
     - Error-highlighted rule cards with red border for visibility
     - Per-rule timeframe dropdown connected; warning if Rule TF < Base TF
     - Cross operators (crossAbove/crossBelow): auto-switch Value ke Indicator; Number dimatikan dengan hint
      - Error summary banner under Save button for quick fix guidance
      - Save/Test button labels show error count when disabled
   - Timeframe dropdown: tooltip menjelaskan perilaku resampling saat Rule TF < Base TF
   - Verified on Flutter web preview without browser errors

- Workspace results filters:
  - Added Symbol and Timeframe dropdowns in the results list
  - Added FilterChips: Profit Only, PF > 1, Win Rate > 50%
  - Rendering uses filtered list via ViewModel state

## 💡 Implementation Insights

- Prefer `Theme.of(context).colorScheme` over `Colors.*` to ensure dark/light consistency.
- Use `withOpacity(...)` or `withValues(alpha: ...)` for subtle emphasis on `onSurface` text.
- For semantic signals (bullish/bearish/warn), keep color semantics but apply low-opacity backgrounds and outlined borders.
- Bottom sheets should use `colorScheme.surface` and `colorScheme.outline` for borders/dividers.
- When a helper widget needs theme, pass `BuildContext` rather than hardcoding colors.

## 🔧 Follow-ups / Next Steps

- Replace any remaining hardcoded colors in views/widgets with `colorScheme` tokens.
- Add a short Theming Guide in docs to standardize usage across new components.
- Address web initialization warnings:
  - Update `web/index.html` to use `{{flutter_service_worker_version}}` token.
  - Migrate from `FlutterLoader.loadEntrypoint` to `FlutterLoader.load`.
- Add UI tests focusing on dark mode: equity toggle, candlestick labels, bottom sheets.
 - Integrate Strategy details into PDF export and render rules in `pdf_export_service.dart`.

## 🧭 Theming Guide (Quick Reference)

- Text primary: `colorScheme.onSurface`
- Muted text: `onSurface` with `0.6–0.8` opacity
- Icons: `onSurface` or `primary` when active
- Card/sheet backgrounds: `colorScheme.surface` or `surfaceVariant`
- Outlines/dividers: `colorScheme.outline`
- Success/Error/Warning: `colorScheme.primary/tertiary/error` with low-opacity fills

- Full guide: see `THEMING_GUIDE.md` for detailed standards and examples

### Phase 3 - Premium (6-12 months)

- [ ] Walk-forward analysis
- [ ] Monte Carlo simulation
- [ ] Parameter optimization
- [ ] Cloud sync
- [ ] Strategy marketplace
- [ ] AI strategy generator

## 🐛 Common Issues & Solutions

### Build Runner Conflicts

```bash
# Clean build
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Freezed Not Generating

Make sure all model files have:

```dart
part 'model_name.freezed.dart';
part 'model_name.g.dart';
```

### Stacked Navigation Not Working

```dart
// Regenerate routes
flutter pub run build_runner build --delete-conflicting-outputs

// Check app.locator is called in main.dart
await setupLocator();
```

## 📝 Code Style

### Naming Conventions

- **Views**: `MyView`, `MyViewModel`
- **Services**: `MyService`
- **Models**: `MyModel`
- **Variables**: camelCase
- **Constants**: UPPER_SNAKE_CASE

### Best Practices

1. Keep ViewModels thin - move logic to Services
2. Use Freezed for all models (immutability)
3. Always handle loading states (`setBusy`)
4. Show user feedback (SnackbarService)
5. Write tests for Services (pure logic)

## 🤝 Contributing

Since this is a solo founder project, focus on:

1. **MVP first** - ship basic working version
2. **Iterate based on user feedback**
3. **Don't over-engineer** - add features when needed
4. **Document as you go** - future you will thank you

## 📄 License

MIT License - Free to use and modify

## 💬 Support

For issues or questions:

- Create GitHub issue
- Email: [tuangkang@backtestpro.app]
- Twitter: [@jjayuz]

---

**Built with ❤️ using Flutter & Stacked**

## Performance & UI Update — Candlestick Controls

- Compact control bar: text labels replaced with icons + tooltips.
- Removed HQ switch; single toggle icon controls quality/performance mode.
- Responsive layout using `Wrap` with compact density to avoid overflow.
- HUD constrained to `maxWidth: 200` with ellipsis; slider width set to `200`.
- Active/inactive states use theme `colorScheme` for consistent dark/light.
- Verified on Flutter Web preview at narrow widths; no overflow warnings.
- Code reference: `lib/ui/widgets/common/candlestick_chart/candlestick_chart.dart` (`_buildZoomControls`).
