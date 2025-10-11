# Strategy Builder View - Usage Guide

## 🎨 Features Overview

### ✅ Complete Implementation

**Strategy Details:**

- Strategy Name input
- Initial Capital amount

**Risk Management:**

- Risk Type: Fixed Lot or Percentage Risk
- Risk Value (lot size or %)
- Stop Loss (in points)
- Take Profit (in points)

**Entry Rules:**

- Dynamic rule builder
- Add unlimited entry rules
- Connect rules with AND/OR logic
- Delete individual rules

**Exit Rules:**

- Dynamic rule builder
- Add unlimited exit rules
- Same flexibility as entry rules

**Rule Configuration:**

- Indicator selection (RSI, SMA, EMA, MACD, ATR, BB, Close, Open, High, Low)
- Operator selection (>, <, >=, <=, =, Cross Above, Cross Below)
- Value type: Number OR Indicator comparison
- Period input for indicators
- Logical operators for chaining

## 🚀 How to Use

### Create New Strategy

1. **Navigate to Strategy Builder**

   ```dart
   navigationService.navigateToStrategyBuilderView();
   ```

2. **Fill Strategy Details**

   - Enter name: "My RSI Strategy"
   - Set capital: "10000"

3. **Configure Risk Management**

   - Select risk type
   - Set risk value (e.g., 2% or 0.1 lot)
   - Set SL: 100 points
   - Set TP: 200 points

4. **Add Entry Rules**

   - Tap + button
   - Select indicator: RSI
   - Select operator: Less Than (<)
   - Choose value type: Number
   - Enter value: 30
   - (Optional) Add more rules with AND/OR

5. **Add Exit Rules**

   - Tap + button
   - Select indicator: RSI
   - Select operator: Greater Than (>)
   - Enter value: 70

6. **Save**
   - Tap "Save Strategy"
   - Strategy saved to database!

### Edit Existing Strategy

```dart
navigationService.navigateToStrategyBuilderView(
  strategyId: 'your-strategy-id',
);
```

- All fields will be pre-filled
- Modify any settings
- Tap "Update Strategy"
- Or tap delete icon to remove

## 📋 Example Strategies

### 1. RSI Mean Reversion

**Entry Rules:**

- RSI < 30

**Exit Rules:**

- RSI > 70

### 2. SMA Trend Following

**Entry Rules:**

- Close > SMA(50) AND
- RSI < 60

**Exit Rules:**

- Close < SMA(20)

### 3. Multi-Indicator Confluence

**Entry Rules:**

- Close > SMA(50) AND
- RSI > 35 AND
- RSI < 60

**Exit Rules:**

- RSI > 75

## 🎯 Rule Builder Explained

### Value Types:

**Number:**

- Direct value comparison
- Example: RSI < 30
- Used for threshold-based rules

**Indicator:**

- Compare two indicators
- Example: Close > SMA(50)
- Requires period input
- Used for crossover strategies

### Operators:

| Operator    | Description      | Use Case          |
| ----------- | ---------------- | ----------------- |
| >           | Greater Than     | Price above level |
| <           | Less Than        | RSI oversold      |
| >=          | Greater or Equal | Include boundary  |
| <=          | Less or Equal    | Include boundary  |
| =           | Equals           | Exact match       |
| Cross Above | Crosses upward   | MA crossover      |
| Cross Below | Crosses downward | MA crossdown      |

### Logical Operators:

**AND:**

- All conditions must be true
- Example: Close > SMA(50) AND RSI < 60
- More strict (fewer signals)

**OR:**

- Any condition can be true
- Example: RSI < 30 OR RSI > 70
- More flexible (more signals)

## 🔄 Integration with Backtest

After saving strategy, run backtest:

```dart
// 1. Save strategy via UI
await viewModel.saveStrategy(context);

// 2. Load strategy
final strategy = await storageService.getStrategy(strategyId);

// 3. Run backtest
final result = await backtestEngine.runBacktest(
  marketData: yourData,
  strategy: strategy,
);

// 4. View results
navigationService.navigateToBacktestResultView(resultId: result.id);
```

## 💡 Tips & Best Practices

### Good Strategy Design:

1. **Start Simple**

   - 1-2 entry rules
   - 1 exit rule
   - Test before adding complexity

2. **Use Risk Management**

   - Always set SL/TP
   - Risk 1-2% per trade
   - Use 2:1 reward/risk ratio

3. **Combine Indicators**

   - Trend indicator (MA)
   - Momentum indicator (RSI)
   - Volatility filter (ATR)

4. **Test Multiple Markets**
   - Gold, Forex, Crypto
   - Different timeframes
   - Different market conditions

### Common Mistakes:

❌ **Too Many Rules**

- More rules ≠ better strategy
- Keep it simple (3-5 rules max)

❌ **No Risk Management**

- Always set SL/TP
- Without stops, losses can be huge

❌ **Over-optimization**

- Don't tune to past data
- Test on unseen data

❌ **Ignoring Win Rate**

- <40% win rate needs high RR ratio
- > 60% win rate is rare, be skeptical

## 🧪 Testing Workflow

### 1. Create Strategy

```
Strategy Builder → Fill form → Save
```

### 2. Run Backtest

```
Load data → Select strategy → Run backtest
```

### 3. View Results

```
Backtest Result View → Analyze performance
```

### 4. Iterate

```
Edit strategy → Adjust rules → Re-test
```

## 📊 Strategy Examples with Code

### Conservative Gold Strategy

```dart
Strategy(
  name: 'Gold Conservative',
  initialCapital: 10000,
  riskManagement: RiskManagement(
    riskType: RiskType.percentageRisk,
    riskValue: 1.5,
    stopLoss: 350,
    takeProfit: 700,
  ),
  entryRules: [
    StrategyRule(
      indicator: IndicatorType.close,
      operator: ComparisonOperator.greaterThan,
      value: ConditionValue.indicator(
        type: IndicatorType.sma,
        period: 50,
      ),
      logicalOperator: LogicalOperator.and,
    ),
    StrategyRule(
      indicator: IndicatorType.rsi,
      operator: ComparisonOperator.greaterThan,
      value: ConditionValue.number(35),
      logicalOperator: LogicalOperator.and,
    ),
    StrategyRule(
      indicator: IndicatorType.rsi,
      operator: ComparisonOperator.lessThan,
      value: ConditionValue.number(60),
    ),
  ],
  exitRules: [
    StrategyRule(
      indicator: IndicatorType.rsi,
      operator: ComparisonOperator.greaterThan,
      value: ConditionValue.number(75),
    ),
  ],
)
```

### How to Create in UI:

1. **Name**: "Gold Conservative"
2. **Capital**: "10000"
3. **Risk**: Percentage, 1.5%
4. **SL**: 350, **TP**: 700
5. **Entry Rules:**
   - Rule 1: Close > SMA(50) → AND
   - Rule 2: RSI > 35 → AND
   - Rule 3: RSI < 60
6. **Exit Rules:**
   - Rule 1: RSI > 75

## 🐛 Troubleshooting

### "Cannot save strategy"

- Check strategy name is filled
- Verify at least 1 entry rule exists
- Ensure initial capital is valid number

### Rules not working in backtest

- Check indicator periods are valid
- Verify operators match intended logic
- Test with debug mode to see signals

### Strategy loads but fields empty

- Check strategyId is correct
- Verify strategy exists in database
- Try creating new instead of editing

## 🎯 Next Features (Coming Soon)

- [ ] Strategy templates library
- [ ] Visual rule preview
- [ ] Rule validation warnings
- [ ] Copy existing strategy
- [ ] Import/Export strategies
- [ ] Strategy marketplace
- [ ] AI-suggested rules

---

**Ready to create strategies!** 🚀

Just navigate to Strategy Builder and start building your winning strategy!

---

## 🔒 Exit & Filter State (Autosave & Kondisi Keluar)

### Autosave Drafts

- Builder melakukan autosave dengan debounce agar perubahan tidak hilang.
- Indikator status autosave dan waktu terakhir tersimpan ditampilkan di UI.
- Draft akan dipulihkan otomatis saat builder dibuka kembali jika tersedia.

### Konfirmasi Keluar (WillPopScope)

- Jika ada draft autosave, keluar dari builder menampilkan dialog konfirmasi.
- Tombol pada dialog:
  - `Batal`: tutup dialog dan tetap di builder.
  - `Tutup`: keluar dari builder tanpa menghapus draft.
  - `Discard & Keluar`: hapus draft autosave lalu keluar dari builder.

### Tombol "Discard Draft" Bersyarat

- Tombol `Discard Draft` hanya muncul jika `hasAutosaveDraft == true`.
- Klik tombol ini menghapus draft autosave dan menyembunyikan tombol.

### Reset Filter Template Saat Keluar

- Filter `query` dan `selectedCategories` pada picker template direset saat meninggalkan builder.
- Implementasi: panggil `viewModel.resetTemplateFilters()` di `onWillPop` sebelum melakukan `pop`.

### Referensi Kode

- `lib/ui/views/strategy_builder/strategy_builder_view.dart` → `WillPopScope` + `AlertDialog` untuk konfirmasi.
- `lib/ui/views/strategy_builder/strategy_builder_viewmodel.dart` → flag `hasAutosaveDraft`, `restoreDraftIfAvailable()`, dan `resetTemplateFilters()`.

### Best Practices

- Gunakan autosave untuk mencegah kehilangan data saat berpindah view.
- Selalu tampilkan konfirmasi saat ada state belum tersimpan (draft).
- Reset UI state sementara (filter/template) ketika pengguna meninggalkan layar untuk menghindari kebingungan saat kembali.

---

## 🧩 Periode Utama vs Periode Pembanding

Untuk rule dengan tipe nilai "Bandingkan indikator" (Indicator), kini builder mendukung dua input periode yang terpisah agar perhitungan engine akurat dan konsisten dengan strategi:

- Periode Utama (`mainPeriod`): periode untuk indikator kiri (indikator utama pada rule).
- Periode Pembanding (`period`): periode untuk indikator pembanding (kanan) yang diisi dalam blok "Compare Indicator".

### Kapan `mainPeriod` muncul

- Muncul ketika indikator kiri membutuhkan periode tunggal, seperti `EMA`, `SMA`, `RSI`, `ATR`, atau `Bollinger Bands`.
- Tidak muncul untuk indikator tanpa periode (mis. `Close`, `Open`, `High`, `Low`).
- Indikator multi-parameter (mis. `MACD`) tetap mengikuti konfigurasi yang tersedia dan tidak menggunakan `mainPeriod` terpisah.

### Contoh Penggunaan: EMA Ribbon

- Entry rule: `EMA(mainPeriod=8) > EMA(period=13)`.
- Dengan `mainPeriod` di sisi kiri dan `period` di sisi pembanding, engine menghitung kedua EMA sesuai periode yang dimaksud, menghindari asumsi periode default.

### Integrasi & Serialisasi

- UI Rule Builder menyimpan kedua nilai (`mainPeriod` dan `period`) di draft autosave dan saat menyimpan strategi.
- Backtest Engine menggunakan `mainPeriod` untuk precalculate indikator utama dan `period` untuk indikator pembanding.
- Template strategi seperti `ema_ribbon_stack` kini menyetel `mainPeriod` secara eksplisit sehingga hasil backtest dan pratinjau UI selaras.

### Tips Implementasi

- Saat membuat aturan perbandingan indikator, selalu isi `mainPeriod` untuk indikator kiri jika indikatornya ber-periode.
- Verifikasi di hasil backtest bahwa sinyal mengikuti periode yang Anda set (contoh: EMA 8 vs EMA 13 pada tren naik).
