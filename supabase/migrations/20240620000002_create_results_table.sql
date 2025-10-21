-- Create results table
CREATE TABLE IF NOT EXISTS results (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  strategy_id UUID NOT NULL REFERENCES strategies(id) ON DELETE CASCADE,
  symbol TEXT NOT NULL,
  timeframe TEXT NOT NULL,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,
  initial_capital DECIMAL NOT NULL,
  final_capital DECIMAL NOT NULL,
  total_profit_loss DECIMAL NOT NULL,
  profit_factor DECIMAL,
  win_rate DECIMAL,
  total_trades INTEGER NOT NULL,
  winning_trades INTEGER NOT NULL,
  losing_trades INTEGER NOT NULL,
  max_drawdown DECIMAL,
  max_drawdown_percentage DECIMAL,
  sharpe_ratio DECIMAL,
  trades JSONB NOT NULL DEFAULT '[]',
  equity_curve JSONB NOT NULL DEFAULT '[]',
  monthly_returns JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE results ENABLE ROW LEVEL SECURITY;

-- Create policies
-- Users can view their own results
CREATE POLICY "Users can view own results" ON results
  FOR SELECT USING (auth.uid() = user_id);

-- Users can view results of public strategies
CREATE POLICY "Users can view results of public strategies" ON results
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM strategies s 
      WHERE s.id = results.strategy_id 
      AND s.is_public = true
    )
  );

-- Users can insert their own results
CREATE POLICY "Users can insert own results" ON results
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can delete their own results
CREATE POLICY "Users can delete own results" ON results
  FOR DELETE USING (auth.uid() = user_id);

-- Create indexes for faster queries
CREATE INDEX results_user_id_idx ON results(user_id);
CREATE INDEX results_strategy_id_idx ON results(strategy_id);
CREATE INDEX results_symbol_idx ON results(symbol);
CREATE INDEX results_created_at_idx ON results(created_at);

-- Add comment to table
COMMENT ON TABLE results IS 'Backtest results for trading strategies';