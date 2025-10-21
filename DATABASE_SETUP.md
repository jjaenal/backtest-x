# 🗄️ Database Setup Guide - BacktestX

Panduan lengkap untuk setup dan konfigurasi database Supabase untuk BacktestX.

## 📋 Overview

BacktestX menggunakan **Supabase** sebagai backend database dengan fitur:
- ✅ **Authentication** - User management dengan email/password dan OAuth
- ✅ **Row Level Security (RLS)** - Data isolation per user
- ✅ **Real-time subscriptions** - Live updates (opsional)
- ✅ **Edge Functions** - Serverless functions (future)

## 🏗️ Database Schema

### 1. **profiles** - User Profiles
```sql
- id (UUID, PK) → auth.users(id)
- email (TEXT, NOT NULL)
- full_name (TEXT)
- avatar_url (TEXT)
- subscription_tier (TEXT) → 'free', 'pro', 'enterprise'
- preferences (JSONB) → User settings
- created_at, updated_at (TIMESTAMP)
```

### 2. **strategies** - Trading Strategies
```sql
- id (UUID, PK)
- user_id (UUID, FK) → profiles(id)
- name (TEXT, NOT NULL)
- description (TEXT)
- initial_capital (DECIMAL)
- risk_management (JSONB) → Risk settings
- entry_rules (JSONB) → Array of entry conditions
- exit_rules (JSONB) → Array of exit conditions
- is_public (BOOLEAN) → Template strategies
- is_template (BOOLEAN)
- tags (TEXT[]) → Strategy categorization
- created_at, updated_at (TIMESTAMP)
```

### 3. **backtest_results** - Backtest Results
```sql
- id (UUID, PK)
- user_id (UUID, FK) → profiles(id)
- strategy_id (UUID, FK) → strategies(id)
- market_data_id (TEXT) → Dataset identifier
- symbol, timeframe (TEXT)
- start_date, end_date (TIMESTAMP)
- Performance metrics (total_trades, win_rate, pnl, etc.)
- summary_details (JSONB) → Detailed metrics
- trades_data (JSONB) → Individual trades
- equity_curve (JSONB) → Equity progression
- created_at, updated_at (TIMESTAMP)
```

### 4. **strategy_shares** - Strategy Sharing (Opsional)
```sql
- id (UUID, PK)
- strategy_id (UUID, FK) → strategies(id)
- shared_by (UUID, FK) → profiles(id)
- shared_with (UUID, FK) → profiles(id)
- share_type (TEXT) → 'view', 'copy', 'collaborate'
- expires_at (TIMESTAMP)
- created_at (TIMESTAMP)
```

## 🚀 Setup Instructions

### 1. **Supabase Project Setup**

1. Buat project baru di [Supabase Dashboard](https://supabase.com/dashboard)
2. Copy **Project URL** dan **anon key**
3. Update environment variables:

```bash
# Development
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### 2. **Database Migration**

Jalankan SQL migrations di Supabase SQL Editor:

```bash
# 1. Initial Schema
supabase/migrations/001_initial_schema.sql

# 2. RLS Policies
supabase/migrations/002_rls_policies.sql
```

**Atau via Supabase CLI:**
```bash
# Install Supabase CLI
npm install -g supabase

# Login dan link project
supabase login
supabase link --project-ref your-project-ref

# Apply migrations
supabase db push
```

### 3. **Authentication Setup**

Di Supabase Dashboard → Authentication:

1. **Email Settings**
   - Enable email confirmations
   - Configure SMTP (production)

2. **OAuth Providers** (opsional)
   - Google: Configure OAuth credentials
   - GitHub, Apple: Setup sesuai kebutuhan

3. **URL Configuration**
   - Site URL: `https://your-domain.com`
   - Redirect URLs: 
     - `https://your-domain.com/auth/callback`
     - `io.supabase.flutter://login-callback` (mobile)

### 4. **Row Level Security (RLS)**

RLS policies sudah dikonfigurasi untuk:
- ✅ Users hanya bisa akses data mereka sendiri
- ✅ Public strategies bisa diakses semua user
- ✅ Shared strategies sesuai permissions
- ✅ Quota management per subscription tier

## 💻 Development Usage

### 1. **DatabaseService Integration**

```dart
// Get instance
final dbService = DatabaseService();

// User profile operations
final profile = await dbService.getCurrentUserProfile();
await dbService.upsertUserProfile(updatedProfile);

// Strategy operations
final strategies = await dbService.getUserStrategies();
final newStrategy = await dbService.createStrategy(strategy);

// Backtest results
final results = await dbService.getStrategyBacktestResults(strategyId);
await dbService.saveBacktestResult(backtestResult);
```

### 2. **Quota Management**

```dart
// Check limits berdasarkan subscription tier
final profile = await dbService.getCurrentUserProfile();
final maxStrategies = profile?.subscriptionTier.maxStrategies ?? 5;
final maxResults = profile?.subscriptionTier.maxBacktestResults ?? 20;

// Limits per tier:
// FREE: 5 strategies, 20 results
// PRO: 50 strategies, 500 results  
// ENTERPRISE: Unlimited
```

### 3. **Error Handling**

```dart
try {
  await dbService.createStrategy(strategy);
} catch (e) {
  if (e.toString().contains('Strategy limit reached')) {
    // Show upgrade prompt
  } else {
    // Handle other errors
  }
}
```

## 🔒 Security Features

### 1. **Row Level Security (RLS)**
- Semua tabel protected dengan RLS policies
- Users hanya bisa akses data mereka sendiri
- Public strategies accessible untuk semua

### 2. **Data Validation**
- JSON schema validation di client-side
- Database constraints untuk data integrity
- Input sanitization

### 3. **Access Control**
- Helper functions untuk permission checking
- Quota enforcement per subscription tier
- Audit trail via timestamps

## 📊 Performance Optimization

### 1. **Database Indexes**
```sql
-- Query optimization indexes
CREATE INDEX idx_strategies_user_id ON strategies(user_id);
CREATE INDEX idx_backtest_results_strategy_id ON backtest_results(strategy_id);
CREATE INDEX idx_backtest_results_user_symbol_timeframe ON backtest_results(user_id, symbol, timeframe);
```

### 2. **Query Patterns**
- Use `select()` untuk specify columns yang dibutuhkan
- Implement pagination untuk large datasets
- Cache frequently accessed data

### 3. **JSON Data**
- Strategy rules dan backtest data disimpan sebagai JSONB
- Efficient untuk complex nested data
- Queryable dengan PostgreSQL JSON operators

## 🧪 Testing

### 1. **Local Development**
```bash
# Start local Supabase (opsional)
supabase start

# Run tests dengan local DB
flutter test
```

### 2. **Sample Data**
```sql
-- Insert sample profile untuk testing
INSERT INTO profiles (id, email, full_name) 
VALUES ('00000000-0000-0000-0000-000000000000', 'demo@backtestx.com', 'Demo User');
```

## 🚀 Production Deployment

### 1. **Environment Variables**
```bash
# Production
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-production-anon-key
```

### 2. **Backup Strategy**
- Supabase automatic daily backups
- Export critical data regularly
- Monitor database performance

### 3. **Monitoring**
- Setup alerts untuk quota limits
- Monitor RLS policy performance
- Track user growth dan usage patterns

## 📚 Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Client](https://pub.dev/packages/supabase_flutter)
- [PostgreSQL JSON Functions](https://www.postgresql.org/docs/current/functions-json.html)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

---

**📝 Note**: File ini akan diupdate seiring development. Untuk pertanyaan atau issues, check TODO.md atau buat issue baru.