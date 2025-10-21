-- =====================================================
-- Row Level Security (RLS) Policies untuk BacktestX
-- =====================================================
-- File: 002_rls_policies.sql
-- Deskripsi: Security policies untuk akses data per-user
-- Author: BacktestX Team
-- Created: 2025-01-20

-- =====================================================
-- 1. ENABLE RLS pada semua tabel
-- =====================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strategies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.backtest_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.strategy_shares ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 2. PROFILES POLICIES
-- =====================================================
-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Users can insert their own profile (saat signup)
CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- =====================================================
-- 3. STRATEGIES POLICIES
-- =====================================================
-- Users can view their own strategies
CREATE POLICY "Users can view own strategies" ON public.strategies
    FOR SELECT USING (auth.uid() = user_id);

-- Users can view public strategies (templates)
CREATE POLICY "Users can view public strategies" ON public.strategies
    FOR SELECT USING (is_public = true);

-- Users can view shared strategies
CREATE POLICY "Users can view shared strategies" ON public.strategies
    FOR SELECT USING (
        id IN (
            SELECT strategy_id FROM public.strategy_shares 
            WHERE shared_with = auth.uid() 
            AND (expires_at IS NULL OR expires_at > NOW())
        )
    );

-- Users can insert their own strategies
CREATE POLICY "Users can insert own strategies" ON public.strategies
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own strategies
CREATE POLICY "Users can update own strategies" ON public.strategies
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own strategies
CREATE POLICY "Users can delete own strategies" ON public.strategies
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 4. BACKTEST_RESULTS POLICIES
-- =====================================================
-- Users can view their own backtest results
CREATE POLICY "Users can view own backtest results" ON public.backtest_results
    FOR SELECT USING (auth.uid() = user_id);

-- Users can view backtest results for shared strategies (read-only)
CREATE POLICY "Users can view shared strategy results" ON public.backtest_results
    FOR SELECT USING (
        strategy_id IN (
            SELECT strategy_id FROM public.strategy_shares 
            WHERE shared_with = auth.uid() 
            AND share_type IN ('view', 'copy', 'collaborate')
            AND (expires_at IS NULL OR expires_at > NOW())
        )
    );

-- Users can insert their own backtest results
CREATE POLICY "Users can insert own backtest results" ON public.backtest_results
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own backtest results
CREATE POLICY "Users can update own backtest results" ON public.backtest_results
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own backtest results
CREATE POLICY "Users can delete own backtest results" ON public.backtest_results
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 5. STRATEGY_SHARES POLICIES
-- =====================================================
-- Users can view shares they created
CREATE POLICY "Users can view own shares" ON public.strategy_shares
    FOR SELECT USING (auth.uid() = shared_by);

-- Users can view shares directed to them
CREATE POLICY "Users can view received shares" ON public.strategy_shares
    FOR SELECT USING (auth.uid() = shared_with);

-- Users can create shares for their own strategies
CREATE POLICY "Users can create shares for own strategies" ON public.strategy_shares
    FOR INSERT WITH CHECK (
        auth.uid() = shared_by 
        AND strategy_id IN (
            SELECT id FROM public.strategies WHERE user_id = auth.uid()
        )
    );

-- Users can update shares they created
CREATE POLICY "Users can update own shares" ON public.strategy_shares
    FOR UPDATE USING (auth.uid() = shared_by);

-- Users can delete shares they created
CREATE POLICY "Users can delete own shares" ON public.strategy_shares
    FOR DELETE USING (auth.uid() = shared_by);

-- =====================================================
-- 6. FUNCTIONS untuk helper queries
-- =====================================================
-- Function untuk cek apakah user punya akses ke strategy
CREATE OR REPLACE FUNCTION public.user_has_strategy_access(strategy_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.strategies 
        WHERE id = strategy_uuid 
        AND (
            user_id = auth.uid() 
            OR is_public = true
            OR id IN (
                SELECT strategy_id FROM public.strategy_shares 
                WHERE shared_with = auth.uid() 
                AND (expires_at IS NULL OR expires_at > NOW())
            )
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function untuk get user's strategy count (untuk quota checking)
CREATE OR REPLACE FUNCTION public.get_user_strategy_count()
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*) FROM public.strategies 
        WHERE user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function untuk get user's backtest count (untuk quota checking)
CREATE OR REPLACE FUNCTION public.get_user_backtest_count()
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*) FROM public.backtest_results 
        WHERE user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;