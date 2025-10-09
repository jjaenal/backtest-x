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
- **Data Import/Export**: Import CSV data and export backtest results
- **Share Results**: Share backtest results with others

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
- [ ] Save/load strategies
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

## 🧭 Theming Guide (Quick Reference)

- Text primary: `colorScheme.onSurface`
- Muted text: `onSurface` with `0.6–0.8` opacity
- Icons: `onSurface` or `primary` when active
- Card/sheet backgrounds: `colorScheme.surface` or `surfaceVariant`
- Outlines/dividers: `colorScheme.outline`
- Success/Error/Warning: `colorScheme.primary/tertiary/error` with low-opacity fills

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
