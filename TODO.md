# TODO - Implementation Checklist

## Top Priorities (Sorted)

### High Priority
- Workspace Compare: visualize results across timeframes
- Backtest Result: per‑TF chart sorting by metric value
- Performance: memory optimization for large datasets (>10k candles)
- Known Issues: BacktestEngine edge cases; division by zero; parser messages; storage migration

### Medium Priority
- UI/UX: error handling UI; onboarding tutorial; empty states
- Documentation: Theming Guide for contributors
- Export: combined Chart+Panel multi‑page PDF; dynamic file naming

### Low Priority
- Social sharing integration

## Next Sprint (1–2 weeks)

- Deliver Workspace Compare MTF visualization (charts + summary)
- Implement per‑TF chart sorting by selected metric
- Tackle memory optimization for 10k+ candles datasets
- Draft Theming Guide section (colorScheme, opacity rationale)

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

### Multi-Asset Backtest

- [ ] Select multiple symbols
- [ ] Run backtest on all
- [x] Compare results
- [ ] Portfolio view

### UI/UX Improvements

- [ ] Onboarding tutorial
- [ ] Empty states
- [x] Loading skeletons
 - [x] Startup view: centered animated steps (AnimatedSwitcher)
 - [x] Startup view: remove loader and check icon
 - [x] Startup view: micro-delay pacing for smoother transitions
- [x] Home: "Loading cache..." banner saat warm-up background
- [x] Home: kontrol AppBar untuk pause/enable dan Load Now
- [x] Home: skeleton angka quick stats saat busy
- [ ] Error handling UI
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
- [ ] Add Base TF vs Rule TF badge in preview results
- [x] Tooltip for timeframe dropdown explaining correction behavior
- [x] Auto-switch Value ke Indicator untuk operator crossAbove/crossBelow
- [x] Nonaktifkan segmen Number saat operator cross; tampilkan hint penjelasan
 - [x] Strategy Builder: error summary banner under Save button
 - [x] Save/Test button labels show error count when disabled
- [ ] Add Theming Guide docs for contributors
- [ ] UI tests for dark mode components (toggle, sheets, chart labels)

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

- [ ] User can upload CSV data
- [ ] User can create basic strategy (3 indicators minimum)
- [ ] User can run backtest
- [ ] User can view results with charts
- [ ] User can save/load strategies
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

- [ ] BacktestEngine: Handle edge cases (empty data, single candle)
- [ ] IndicatorService: Division by zero checks
- [ ] DataParser: Better error messages for malformed CSV
- [ ] Storage: Handle database migration failures
- [ ] Memory: Large datasets (>10k candles) crash on low-end devices

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
