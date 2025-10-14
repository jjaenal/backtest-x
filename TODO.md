# TODO - Implementation Checklist

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
- [ ] Locale‑aware number/date formatting (`intl`: WinRate %, PF, expectancy, dates)
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

## Progress Update — Anchored VWAP

- Completed: Model updates (`AnchorMode`, `anchorDate`) for `ConditionValue.indicator`
- Completed: Engine integration — precalc keyed by anchor (start/date) and evaluation logic for compare values and crossAbove/crossBelow
- Completed: Strategy Builder UI — Anchor Mode dropdown and Anchor Date input (YYYY-MM-DD or ISO)
- Completed: ViewModel — fields, controllers, and conversion functions between `RuleBuilder` and `StrategyRule`
- Completed: Unit test — anchor by date mapping to correct index and equality with anchor by index
- Completed: README — documentation for usage and behavior

## ✅ Completed (Phase 0)

- [x] Project structure setup
- [x] Stacked architecture configuration
- [x] Data models (Candle, Strategy, Trade, BacktestResult)
- [x] DataParserService (CSV upload & validation)
- [x] IndicatorService (SMA, EMA, RSI, ATR, MACD, Bollinger Bands)
- [x] BacktestEngineService (core logic)
- [x] StorageService (SQLite)
- [x] HomeView & ViewModel
- [x] DataUploadView & ViewModel

## 🚧 In Progress (Phase 1 - MVP)

### 1. Strategy Builder View (PRIORITY)

**File:** `lib/ui/views/strategy_builder/`

**Features:**

- [x] Form-based strategy creation
- [x] Indicator selection dropdown
- [x] Condition builder (if-then logic)
- [x] Multiple entry/exit rules
- [x] Risk management settings
- [x] Save strategy to database
- [x] Load existing strategy
- [x] Quick backtest preview

**UI Components:**

```dart
- StrategyNameInput
- InitialCapitalInput
- RiskManagementForm
  - RiskType selector (Fixed/Percentage)
  - SL/TP inputs
  - Trailing stop toggle
- EntryRulesBuilder
  - Add/Remove rule buttons
  - Indicator dropdown
  - Operator dropdown
  - Value input
  - Logical operator (AND/OR)
- ExitRulesBuilder (same as entry)
- SaveButton
- TestButton (quick backtest preview)
```

**Estimated Time:** 2-3 days

### 2. Backtest Result View

**File:** `lib/ui/views/backtest_result/`

**Features:**

- [x] Summary stats cards
  - Win rate, Profit factor, Max DD
  - Total trades, Win/Loss count
  - Sharpe ratio, Expectancy
- [x] Trade list table
  - Sortable columns
  - Filter by win/loss
  - Export to CSV
- [x] Equity curve chart (fl_chart)
- [x] Drawdown chart
- [x] Share/Export button
  - Share results as text
  - Export trades to CSV

**UI Layout:**

```
┌─────────────────────────────┐
│  Summary Stats (4 cards)    │
├─────────────────────────────┤
│  Equity Curve Chart         │
├─────────────────────────────┤
│  Trade List (Scrollable)    │
└─────────────────────────────┘
```

**Estimated Time:** 2-3 days

### 3. Workspace View

**File:** `lib/ui/views/workspace/`

**Features:**

- [x] List all saved strategies
- [x] Delete strategy
- [x] Duplicate strategy
- [x] View strategy details
- [x] View historical results per strategy
- [x] Compare results
- [x] Quick run backtest
- [x] Quick batch backtest (Run Batch)
- [x] Disable quick actions while running (spinner/progress)
- [x] Copy trades CSV from results list
- [x] Copy summary from results list
- [x] Export trades CSV from results list
- [x] Filter results by Profit Only, PF > 1, Win Rate > 50%
- [x] Filter results by Symbol and Timeframe
- [x] Filter results by Date Range (Start/End)
- [x] Export filtered results CSV from results list

**Estimated Time:** 1-2 days

### 4. Chart Widget

**File:** `lib/ui/widgets/candlestick_chart/`

**Features:**

- [x] Basic candlestick chart
- [x] Zoom & pan
- [x] Show entry/exit markers
- [x] Overlay indicators (SMA, EMA)
- [x] Tooltip on hover

**Library:** Use `candlesticks` or `fl_chart`

**Estimated Time:** 2-3 days

---

## 📋 Phase 2 - Polish (Next 3 Months)

### Export Features

- [x] Export trades to CSV
- [x] Export comparison to CSV
- [x] Generate PDF report (enhanced)
  - [x] Summary stats
  - [x] Trade list
  - [x] Strategy details
  - [x] Charts (grid vertikal/horizontal, X/Y min–max, rentang tanggal)
- [ ] Share via social media
- [x] Copy trades to clipboard (Workspace)
- [x] Copy summary to clipboard (Workspace)
- [x] Backtest Result: export per‑TF metrics (Avg Win/Loss, R/R) dan Entry TFs
- [x] Comparison CSV respects chart order (Sort/Agg) on grouped TF chart

### Deep Link

- [x] Service untuk membangun tautan hasil backtest (DeepLinkService)
- [x] Sertakan deep link di payload share BacktestResult
- [x] Tangani deep link pada startup Web (navigasi langsung)
- [x] Tambah dokumentasi & contoh di README
- [x] Unit test untuk format URL dan encoding id

### Multi-Asset Backtest

- [ ] Select multiple symbols
- [ ] Run backtest on all
- [x] Compare results
- [ ] Portfolio view

### UI/UX Improvements

- [x] Onboarding tutorial
- [x] Empty states
- [x] Loading skeletons
- [x] Startup view: centered animated steps (AnimatedSwitcher)
- [x] Startup view: remove loader and check icon
- [x] Startup view: micro-delay pacing for smoother transitions
- [x] Home: "Loading cache..." banner saat warm-up background
- [x] Home: kontrol AppBar untuk pause/enable dan Load Now
- [x] Home: skeleton angka quick stats saat busy
- [x] Error handling UI
- [ ] Animations & transitions
- [x] Dark/Light theme toggle
- [x] Dark theme consistency across views (workspace, backtest result, strategy builder)
- [x] Themed chart labels/grid and info panels
- [x] Themed bottom sheets (pattern guide, indicator settings)
- [x] Strategy Builder: per-rule validation messages on rule cards
- [x] Disable Save/Test buttons when fatal errors; show tooltips
- [x] Inline errorText on problematic fields (Value, Compare With, Period)
- [x] Red border highlight on rule cards with errors
- [x] Operator-specific validation for crossAbove/crossBelow
- [x] Add Base TF vs Rule TF badge in preview results
- [x] Tooltip for timeframe dropdown explaining correction behavior
- [x] Auto-switch Value ke Indicator untuk operator crossAbove/crossBelow
- [x] Nonaktifkan segmen Number saat operator cross; tampilkan hint penjelasan
- [x] Strategy Builder: error summary banner under Save button
- [x] Save/Test button labels show error count when disabled
- [x] Add Theming Guide docs for contributors
- [x] UI tests for dark mode components (toggle, sheets, chart labels)
- [x] Persist Compare view preferences (Sort/Agg) across sessions
- [x] Strategy Builder: reset filter template saat keluar layar
- [x] Strategy Builder: konfirmasi keluar saat ada draft autosave; opsi "Discard & Keluar"
- [x] Strategy Builder: sembunyikan tombol "Discard Draft" bila tidak ada draft autosave

#### Focused Checklist — Onboarding Revamp

- [x] Tujuan utama: percepat waktu ke nilai, kurangi kebingungan awal
- [x] Welcome modal singkat: jelaskan 3 langkah (pilih data, pilih template/indikator, jalankan preview)
- [x] Template Quick‑Start: 3–5 template ("Swing RSI", "Breakout EMA", "Anchored VWAP by date")
- [x] Data onboarding card: "Import Data" dengan tautan contoh CSV dan penjelasan timeframe
- [x] Coach marks pada MarketData & timeframe untuk dampak ke indikator
- [x] Strategy Builder tour (tooltips progresif): rule kiri/kanan, period, operator; tampilkan Anchor Mode & contoh Anchor Date untuk Anchored VWAP
- [x] Preview cepat: CTA "Run Preview" di AppBar; tampilkan ringkasan (WinRate, Profit, Max DD) + tombol "Save as Template"
- [x] Draft autosave awareness: badge "Draft tersimpan otomatis" + aksi "Pulihkan Draft"
- [x] Learn panel: tautan singkat ke README Anchored VWAP & video
- [x] Deep link onboarding: buka app dengan template + data contoh untuk eksplorasi

### Data Management

- [ ] Import from TradingView
- [ ] Import from MetaTrader
- [ ] Connect to Binance API
- [ ] Data refresh/update
  - [ ] Add sample adapters and validation paths

---

## 🚀 Phase 3 - Advanced (6-12 Months)

### Optimization Engine

- [ ] Grid search parameters
- [ ] Walk-forward analysis
- [ ] Monte Carlo simulation
- [ ] Genetic algorithm optimization

### Cloud Features

- [ ] User authentication
- [ ] Cloud sync
- [ ] Cross-device access
- [ ] Backup/restore

### Marketplace

- [ ] Share strategies
- [ ] Browse community strategies
- [ ] Rating system
- [ ] Comments & discussion

### AI Features

- [ ] AI strategy generator
- [ ] Pattern recognition
- [ ] Market regime detection
- [ ] Risk prediction

---

## 🔧 Technical Debt

### Testing

- [ ] Unit tests for IndicatorService
- [ ] Unit tests for BacktestEngineService
- [ ] Widget tests for views
- [ ] Integration tests

### Documentation

- [ ] API documentation (dart doc)
- [ ] User guide
- [ ] Video tutorials
- [ ] FAQ
- [ ] Theming Guide (usage of colorScheme, opacity rationale)

### Performance

- [x] Optimize backtest loop (use Isolate)
- [x] Database indexing
- [x] Background cache warm-up throttling & batching (kurangi jank)
- [x] Lazy loading for large datasets — Workspace results list (Load more)
- [ ] Memory optimization
  - [x] Chart rendering optimizations for >1000 candles

### Code Quality

- [ ] Add logging
- [ ] Error handling
- [ ] Code coverage > 80%
- [ ] Linting rules

---

## 📝 Immediate Next Actions (This Week)

### Next Main Feature Focus: Multi-timeframe Analysis (MVP)

1. Add timeframe selector and multi-select across views — [x]
2. Extend DataManager to aggregate multi-timeframe candles — [x]
3. Update BacktestEngineService to support multi-timeframe conditions — [x]
4. Adjust StrategyBuilder to define MTF rules cleanly — [x]
5. Update Backtest Result to show per-timeframe stats — [x]
   - Per‑timeframe charts visualization — [x]
     • Dropdown metrik (winRate, profitFactor, expectancy, rr, trades, wins, signals, avgWin/avgLoss)
     • Chart bar horizontal sederhana di panel TF Stats
     • Follow‑up: sorting by nilai, export gambar chart
6. Enhance Workspace Compare to visualize results across timeframes — [ ]

### Day 1-2: Strategy Builder View

1. Create `strategy_builder_view.dart` and `strategy_builder_viewmodel.dart`
2. Build form UI
3. Implement rule builder logic
4. Connect to StorageService
5. Test save/load functionality

### Day 3-4: Backtest Result View

1. Create `backtest_result_view.dart` and viewmodel
2. Build stats cards
3. Implement trade list
4. Add basic chart (equity curve)
5. Test with sample data

### Day 5-6: Integration & Testing

1. Connect all views via navigation
2. End-to-end flow testing
3. Bug fixes
4. UI polish
5. Prepare for initial release
6. Ensure dark theme tests pass (toggle, chart labels, bottom sheets)

### Day 7: Documentation & Release

1. Update README with usage guide
2. Create demo video
3. Write release notes
4. Deploy to internal testing

---

## 🎯 Success Metrics (MVP)

- [x] User can upload CSV data
- [x] User can create basic strategy (3 indicators minimum)
- [x] User can run backtest
- [x] User can view results with charts
- [x] User can save/load strategies
- [ ] App runs smoothly on Android & iOS
- [ ] No critical bugs
- [ ] App size < 50MB

---

## 💡 Quick Wins (Low Effort, High Impact)

1. **Add example strategies** - Pre-load 3-5 popular strategies
2. **Sample data included** - Ship with demo CSV data
3. **Quick start guide** - In-app tutorial (first launch)
4. **Dark mode default** - Traders love dark themes
5. **Keyboard shortcuts** - Power user features
6. **Auto-save** - Never lose work
   - [x] Implemented: Strategy Builder auto-saves drafts with debounce
7. **Undo/Redo** - Strategy builder safety net
8. **Templates** - Common strategy patterns
9. **Copy to clipboard** - Easy sharing of results
   - [x] Implemented for Comparison View (Copy Summary)
   - [x] Implemented for Backtest Result View (Copy Summary)
10. **Rate limiting** - Prevent app abuse

---

## 🐛 Known Issues to Fix

### High Priority

- [x] BacktestEngine: Handle edge cases (empty data, single candle)
- [x] IndicatorService: Division by zero checks
- [x] DataParser: Better error messages for malformed CSV
- [x] Storage: Handle database migration failures
- [x] Memory: Large datasets (>10k candles) crash on low-end devices

### Medium Priority

- [ ] UI: Overflow text in trade list
- [ ] Navigation: Back button doesn't save draft
- [ ] Chart: Performance issues with >1000 candles
- [ ] Export: CSV encoding issues (special characters)

### Low Priority

- [ ] Animation: Jank on slow devices
- [x] Theme: Some colors don't match in dark mode
- [ ] Keyboard: Doesn't dismiss on submit

---

## 🔐 Security & Privacy

- [ ] No data collection (comply with GDPR)
- [ ] Local-only storage (mention in privacy policy)
- [ ] No analytics by default
- [ ] Optional cloud backup with encryption
- [ ] Clear data deletion option

---

## 📱 Platform-Specific Tasks

### Android

- [ ] Configure ProGuard rules
- [ ] Test on different screen sizes
- [ ] Add adaptive icons
- [ ] Configure deep links
- [ ] Test on Android 8+ and 13+

### iOS

- [ ] Configure Info.plist permissions
- [ ] Test on iPhone & iPad
- [ ] Dark mode app icon variant
- [ ] Add to Apple TestFlight
- [ ] Notarize for distribution

### Web (Future)

- [ ] Responsive layout
- [ ] PWA configuration
- [ ] IndexedDB for storage
- [ ] File download/upload
- [ ] Address web init warnings (service worker token, FlutterLoader.load)

---

## 📊 Analytics to Track (Post-Launch)

### User Behavior

- Most used indicators
- Average backtest duration
- Most common strategy patterns
- Retention rate (D1, D7, D30)

### Performance

- App crash rate
- Average load time
- Database query performance
- Memory usage

### Features

- Upload success rate
- Backtest completion rate
- Strategy save rate
- Export usage

---

## 🎨 Design System (Consistency)

### Colors

```dart
Primary: Colors.blue[700]
Secondary: Colors.blueAccent
Success: Colors.green[600]
Error: Colors.red[600]
Warning: Colors.orange[600]
Background (Light): Colors.grey[50]
Background (Dark): Colors.grey[900]
```

### Typography

```dart
Heading: 24px, Bold
Subtitle: 18px, SemiBold
Body: 14px, Regular
Caption: 12px, Regular
```

### Spacing

```dart
xs: 4px
sm: 8px
md: 16px
lg: 24px
xl: 32px
```

### Components

- Buttons: Rounded 12px
- Cards: Elevated 2, Rounded 12px
- Inputs: Outlined, Rounded 12px
- Lists: Dividers, Padding 16px

---

## 🚀 Launch Checklist

### Pre-Launch (MVP Ready)

- [ ] All core features working
- [ ] No critical bugs
- [ ] Tested on 3+ devices
- [ ] App store screenshots ready
- [ ] App description written
- [ ] Privacy policy created
- [ ] Terms of service created
- [ ] Support email setup

### Launch Day

- [ ] Submit to Google Play (beta)
- [ ] Submit to Apple TestFlight
- [ ] Create landing page
- [ ] Post on Reddit (r/algotrading)
- [ ] Tweet announcement
- [ ] Product Hunt submission
- [ ] Discord/Telegram group

### Post-Launch (Week 1)

- [ ] Monitor crash reports
- [ ] Respond to reviews
- [ ] Fix critical bugs
- [ ] Gather user feedback
- [ ] Plan v1.1 features

---

## 💰 Monetization Strategy

### Free Tier

- 1 strategy max
- 5,000 candles limit
- Basic indicators (SMA, RSI)
- Local storage only
- Export to CSV

### Premium ($9.99/month)

- Unlimited strategies
- Unlimited data
- All indicators
- Cloud sync
- PDF export
- Advanced analytics
- Priority support

### Lifetime ($199 one-time)

- All premium features
- Future updates included
- No recurring payment

---

## 📚 Learning Resources

### For Users

- YouTube tutorial series
- Blog posts (strategy ideas)
- Discord community
- FAQ section
- Example strategies library

### For Contributors (Future)

- Contributing guidelines
- Code style guide
- Architecture documentation
- API reference

---

## 🎯 KPIs to Track

### Product

- **MAU** (Monthly Active Users): Target 1,000 in 3 months
- **Retention**: D7 > 40%, D30 > 20%
- **Feature adoption**: 70%+ users create strategy
- **Backtest completion rate**: 80%+

### Business

- **Conversion rate**: Free → Premium > 5%
- **MRR** (Monthly Recurring Revenue): $1,000 in 6 months
- **Churn rate**: < 10% monthly
- **CAC** (Customer Acquisition Cost): < $20

### Technical

- **Crash-free rate**: > 99%
- **Average load time**: < 2 seconds
- **API response time**: < 500ms
- **App size**: < 50MB

---

## 🔄 Iteration Plan

### v1.0 (MVP) - Now

- Core backtest functionality
- Basic UI
- Local storage

### v1.1 - Month 2

- Multi-asset backtest
- Export features
- UI improvements

### v1.2 - Month 3

- Optimization engine
- Walk-forward analysis
- Advanced charts

### v2.0 - Month 6

- Cloud sync
- Social features
- AI assistant

---

## 📞 Support Plan

### Channels

- Email: support@backtestpro.app
- Discord: discord.gg/backtestpro
- Twitter: @backtestpro
- GitHub Issues (for bugs)

### Response Time

- Critical bugs: < 4 hours
- General support: < 24 hours
- Feature requests: < 7 days

### Documentation

- In-app help center
- Video tutorials
- Knowledge base
- Community forum

---

## ✨ Nice-to-Have Features (Backlog)

- [ ] Multi-language support
- [ ] Voice commands
- [ ] Keyboard shortcuts
- [ ] Custom indicators (user-defined)
- [ ] Strategy versioning
- [ ] A/B testing strategies
- [ ] Real-time market data
- [ ] Paper trading mode
- [ ] Live trading integration
- [ ] Mobile notifications
- [ ] Widget support
- [ ] Watch app
- [ ] Desktop app (macOS/Windows)
- [ ] Chrome extension

---

## 🎓 Educational Content Ideas

### Blog Posts

1. "5 Common Backtesting Mistakes"
2. "How to Validate Your Trading Strategy"
3. "RSI Strategy: A Complete Guide"
4. "Understanding Profit Factor"
5. "Walk-Forward Analysis Explained"

### Video Tutorials

1. Getting Started (5 min)
2. Creating Your First Strategy (10 min)
3. Understanding Backtest Results (8 min)
4. Advanced Strategy Building (15 min)
5. Optimization Techniques (20 min)

### Case Studies

- RSI + MACD: 67% Win Rate
- Bollinger Bands: Low DD Strategy
- Multi-Timeframe Analysis Results

---

## 🤝 Community Building

### Discord Server Structure

- #announcements
- #general
- #strategy-sharing
- #help-support
- #feature-requests
- #show-your-results

### Engagement Ideas

- Weekly strategy contest
- Monthly performance challenge
- User spotlight
- Q&A sessions
- Live backtesting sessions

---

## 🏁 Final Thoughts

**Focus Areas:**

1. **Ship fast** - Don't wait for perfect
2. **Listen to users** - Build what they need
3. **Iterate quickly** - Weekly releases
4. **Stay lean** - No feature bloat
5. **Enjoy the process** - You're building something cool!

**Remember:**

- MVP doesn't need to be perfect
- Early users are forgiving
- Feedback is gold
- Consistency beats perfection
- Solo founder = prioritize ruthlessly

**Next Step:** Start building Strategy Builder View! 🚀

### Checklist Update — Performance (Candlestick Controls)

- [x] Ganti label teks kontrol chart dengan ikon + tooltip
- [x] Hapus Switch HQ; gunakan satu ikon toggle untuk mode kualitas/performa
- [x] Kompakkan kontrol pakai `Wrap` + visual density kecil agar tidak overflow
- [x] Batasi lebar HUD (`maxWidth: 200`) dan `ellipsis`
- [x] Set lebar slider ke `200` agar proporsional
- [x] Verifikasi di Flutter Web preview pada lebar sempit; tidak ada overflow

---

## 🎯 Focused Checklist — Backtest Result: Per‑TF Sorting

- [x] Tambah state sort di ViewModel (Value ↑/↓, Timeframe)
- [x] Urutkan series di helper sesuai sort terpilih
- [x] Tambah dropdown sort di Backtest Result view
- [x] Pastikan `PerTfBarChart` render mengikuti urutan input
- [x] Sinkronkan urutan ekspor CSV per‑TF dengan urutan chart
- [x] Unit test untuk logika pengurutan (NaN, ties, empty)

---

## 🎯 Focused Checklist — Workspace Compare: MTF Visualization

- [x] Tambah panel Grouped TF Chart di Comparison View
- [x] Dropdown metrik untuk grouped chart (winRate, PF, expectancy, rr)
- [x] Opsi sort (Timeframe, Value ↑/↓) dan agregasi (Avg/Max)
- [x] Sinkronkan urutan ekspor CSV dengan urutan chart grouped
- [x] Export PNG untuk grouped chart (panel dan chart saja)
- [x] Unit test untuk agregasi dan pengurutan grouped
- [x] Empty state & tooltip deskripsi metrik di Comparison View
- [x] Batasi item dan responsif untuk dataset besar

---

## 🎯 Focused Checklist — Workspace: Quick Test UX

- [x] Tampilkan bottom sheet “View Full Results” setelah Quick Test
- [x] Pemilih data pasar via bottom sheet dengan opsi radio

---

## 🎯 Focused Checklist — Strategy Builder: Pengembangan Lanjutan

### Strategi Prioritas untuk Diimplementasikan

#### Top Prioritas (MVP Sprint)

- [x] Breakout (HH/HL, range box, volatility filter)
- [x] Trend Following (EMA/SMA cross, ADX filter)
- [x] EMA Ribbon (multi‑EMA alignment)

##### Implementasi (Sprint)

- [x] Akses cepat 3 template MVP di Template Picker (highlight & urutan)
- [x] Risk preset konsisten per template (SL/TP, RR, trailing)
- [x] Quick preview subset data stabil di Strategy Builder
- [x] Unit test untuk 3 template (validasi rule & save/load)
- [x] Quick Run dari Workspace untuk Breakout & Trend (EMA Ribbon sudah ada)

#### Backlog

- [x] Mean Reversion (Bollinger Bands, RSI oversold/overbought)
- [x] Bollinger Squeeze (BB width + breakout trigger)
- [x] Momentum (RSI/MACD konfirmasi, multi‑TF opsi)
- [x] MACD Signal (cross, histogram momentum, filter noise)
- [x] VWAP (pullback/cross)
- [x] Anchored VWAP (pullback/cross)
- [x] RSI Divergence (regular + hidden, dengan konfirmasi MA)
- [x] Stochastic (K/D cross + threshold)

### Template & Rule Builder

- [x] Tambah template per strategi (pre‑filled rules)
  - Ditambah: `bb_squeeze_breakout` dan `rsi_divergence_approx` di library template.
  - Tersedia: Breakout, Trend Following, EMA Ribbon, Mean Reversion, MACD (lihat `strategy_templates.dart`).
- [x] Validasi otomatis per operator (crossAbove/crossBelow, thresholds)
  - Peringatan: TF rule < TF dasar, operator `equals` rapuh, RSI/ADX 0–100, period indikator utama wajib.
  - Error fatal: nilai angka/indikator pembanding wajib, period pembanding > 0, `mainPeriod` > 0 untuk indikator ber‑periode.
  - Semantik `rising/falling` dan `cross` ditangani di engine dan builder.
- [x] Dukungan multi‑timeframe per rule (TF base vs rule TF)
  - UI: dropdown TF per rule + chip rekap TF, warning otomatis bila TF lebih kecil dari data.
  - Engine: `_evaluateRuleMTF` memakai `rule.timeframe` bila tersedia, fallback ke TF dasar.
- [ ] Preset risk management per template (SL/TP, RR, trailing)
- [ ] Hint & tooltip deskripsi strategi pada kartu rule

### Integrasi & UX

- [x] Quick preview hasil strategi dari builder (subset data)
- [x] Indikator wajib & kompatibilitas rule (hindari kombinasi tidak valid)
- [x] Badge performa cepat (WinRate/PF dari preview)
- [ ] Export/Import template strategi (JSON)
- [x] Export/Import strategy (JSON) via AppBar overflow
- [ ] Unit test per template (validasi rule, save/load, quick backtest)
- [x] Konfirmasi keluar saat ada draft autosave; opsi "Discard & Keluar"
- [x] Sembunyikan tombol "Discard Draft" bila tidak ada draft autosave
- [x] Reset filter template (query & kategori) saat keluar builder

### Dokumentasi

- [ ] STRATEGY_BUILDER_GUIDE.md: tambah bab Template & Best Practices
- [ ] Contoh strategi siap pakai (5+ contoh) di README/guide
- [x] STRATEGY_BUILDER_GUIDE.md: bab Exit & Filter State (autosave, konfirmasi, reset)
- [x] README: ringkas Exit & Filter State dan tombol Discard kondisional

---

## 🎯 Focused Checklist — Strategy Builder: AppBar Overflow Actions

- [x] Satukan menu overflow agar selalu muncul
- [x] Kondisikan `Export/Copy/Save` berdasarkan `canSave`
- [x] Pindahkan `Delete Strategy` ke overflow saat `isEditing`
- [x] Hapus ikon Import/Delete terpisah saat state invalid
- [x] Tambah opsi "Import dari file .json" untuk non‑web
- [x] Pertahankan opsi "Import JSON..." (paste teks)
