-- =====================================================
-- Supabase Database Schema untuk BacktestX
-- =====================================================
-- File: 001_initial_schema.sql
-- Deskripsi: Schema awal untuk user profiles, strategies, dan backtest results
-- Author: BacktestX Team
-- Created: 2025-01-20

-- =====================================================
-- 1. PROFILES TABLE
-- =====================================================
-- Extends Supabase auth.users dengan data profil tambahan
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    subscription_tier TEXT DEFAULT 'free' CHECK (subscription_tier IN ('free', 'pro', 'enterprise')),
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index untuk performa query
CREATE INDEX idx_profiles_email ON public.profiles(email);
CREATE INDEX idx_profiles_subscription_tier ON public.profiles(subscription_tier);

-- =====================================================
-- 2. STRATEGIES TABLE  
-- =====================================================
-- Menyimpan strategy yang dibuat user
CREATE TABLE public.strategies (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    initial_capital DECIMAL(15,2) NOT NULL DEFAULT 10000.00,
    
    -- Risk Management (JSON untuk fleksibilitas)
    risk_management JSONB NOT NULL DEFAULT '{
        "riskType": "percentageRisk",
        "riskValue": 2.0,
        "stopLoss": null,
        "takeProfit": null,
        "useTrailingStop": false,
        "trailingStopDistance": null
    }',
    
    -- Strategy Rules (JSON array untuk entry/exit rules)
    entry_rules JSONB NOT NULL DEFAULT '[]',
    exit_rules JSONB NOT NULL DEFAULT '[]',
    
    -- Metadata
    is_public BOOLEAN DEFAULT FALSE,
    is_template BOOLEAN DEFAULT FALSE,
    tags TEXT[] DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes untuk performa
CREATE INDEX idx_strategies_user_id ON public.strategies(user_id);
CREATE INDEX idx_strategies_is_public ON public.strategies(is_public);
CREATE INDEX idx_strategies_is_template ON public.strategies(is_template);
CREATE INDEX idx_strategies_tags ON public.strategies USING GIN(tags);
CREATE INDEX idx_strategies_created_at ON public.strategies(created_at DESC);

-- =====================================================
-- 3. BACKTEST_RESULTS TABLE
-- =====================================================
-- Menyimpan hasil backtest dari strategies
CREATE TABLE public.backtest_results (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    strategy_id UUID REFERENCES public.strategies(id) ON DELETE CASCADE NOT NULL,
    
    -- Metadata backtest
    market_data_id TEXT NOT NULL, -- Identifier untuk dataset yang digunakan
    symbol TEXT NOT NULL,
    timeframe TEXT NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- Summary metrics (untuk query cepat tanpa parse JSON)
    total_trades INTEGER NOT NULL DEFAULT 0,
    winning_trades INTEGER NOT NULL DEFAULT 0,
    losing_trades INTEGER NOT NULL DEFAULT 0,
    win_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    total_pnl DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    total_pnl_percentage DECIMAL(8,4) NOT NULL DEFAULT 0.00,
    profit_factor DECIMAL(8,4) DEFAULT 0.00,
    max_drawdown DECIMAL(15,2) DEFAULT 0.00,
    max_drawdown_percentage DECIMAL(8,4) DEFAULT 0.00,
    sharpe_ratio DECIMAL(8,4) DEFAULT 0.00,
    
    -- Detailed data (JSON untuk fleksibilitas)
    summary_details JSONB NOT NULL DEFAULT '{}',
    trades_data JSONB NOT NULL DEFAULT '[]',
    equity_curve JSONB NOT NULL DEFAULT '[]',
    
    -- Metadata
    execution_time_ms INTEGER,
    notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes untuk performa query
CREATE INDEX idx_backtest_results_user_id ON public.backtest_results(user_id);
CREATE INDEX idx_backtest_results_strategy_id ON public.backtest_results(strategy_id);
CREATE INDEX idx_backtest_results_symbol ON public.backtest_results(symbol);
CREATE INDEX idx_backtest_results_timeframe ON public.backtest_results(timeframe);
CREATE INDEX idx_backtest_results_created_at ON public.backtest_results(created_at DESC);
CREATE INDEX idx_backtest_results_win_rate ON public.backtest_results(win_rate DESC);
CREATE INDEX idx_backtest_results_total_pnl ON public.backtest_results(total_pnl DESC);

-- Composite index untuk filtering
CREATE INDEX idx_backtest_results_user_symbol_timeframe 
ON public.backtest_results(user_id, symbol, timeframe);

-- =====================================================
-- 4. STRATEGY_SHARES TABLE (Opsional - untuk sharing)
-- =====================================================
-- Untuk berbagi strategy antar user
CREATE TABLE public.strategy_shares (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    strategy_id UUID REFERENCES public.strategies(id) ON DELETE CASCADE NOT NULL,
    shared_by UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    shared_with UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    share_type TEXT DEFAULT 'view' CHECK (share_type IN ('view', 'copy', 'collaborate')),
    expires_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_strategy_shares_strategy_id ON public.strategy_shares(strategy_id);
CREATE INDEX idx_strategy_shares_shared_with ON public.strategy_shares(shared_with);
CREATE UNIQUE INDEX idx_strategy_shares_unique 
ON public.strategy_shares(strategy_id, shared_by, shared_with);

-- =====================================================
-- 5. TRIGGERS untuk updated_at
-- =====================================================
-- Function untuk auto-update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers
CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON public.profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_strategies_updated_at 
    BEFORE UPDATE ON public.strategies 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_backtest_results_updated_at 
    BEFORE UPDATE ON public.backtest_results 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 6. SAMPLE DATA (Development)
-- =====================================================
-- Insert sample profile (akan di-replace dengan real user)
-- INSERT INTO public.profiles (id, email, full_name) 
-- VALUES ('00000000-0000-0000-0000-000000000000', 'demo@backtestx.com', 'Demo User');