-- Create strategies table
CREATE TABLE IF NOT EXISTS strategies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  initial_capital DECIMAL NOT NULL DEFAULT 10000,
  risk_type TEXT NOT NULL, -- 'fixedLot', 'percentageRisk', 'atrBased'
  risk_value DECIMAL NOT NULL,
  stop_loss DECIMAL,
  take_profit DECIMAL,
  use_trailing_stop BOOLEAN NOT NULL DEFAULT false,
  trailing_stop_distance DECIMAL,
  entry_rules JSONB NOT NULL DEFAULT '[]',
  exit_rules JSONB NOT NULL DEFAULT '[]',
  is_template BOOLEAN NOT NULL DEFAULT false,
  is_favorite BOOLEAN NOT NULL DEFAULT false,
  is_public BOOLEAN NOT NULL DEFAULT false,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE strategies ENABLE ROW LEVEL SECURITY;

-- Create policies
-- Users can view their own strategies
CREATE POLICY "Users can view own strategies" ON strategies
  FOR SELECT USING (auth.uid() = user_id);

-- Users can view public strategies
CREATE POLICY "Users can view public strategies" ON strategies
  FOR SELECT USING (is_public = true);

-- Users can insert their own strategies
CREATE POLICY "Users can insert own strategies" ON strategies
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own strategies
CREATE POLICY "Users can update own strategies" ON strategies
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own strategies
CREATE POLICY "Users can delete own strategies" ON strategies
  FOR DELETE USING (auth.uid() = user_id);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_strategies_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_strategies_updated_at
BEFORE UPDATE ON strategies
FOR EACH ROW
EXECUTE FUNCTION update_strategies_updated_at();

-- Create index for faster queries
CREATE INDEX strategies_user_id_idx ON strategies(user_id);
CREATE INDEX strategies_is_public_idx ON strategies(is_public);
CREATE INDEX strategies_is_template_idx ON strategies(is_template);

-- Add comment to table
COMMENT ON TABLE strategies IS 'Trading strategies created by users';