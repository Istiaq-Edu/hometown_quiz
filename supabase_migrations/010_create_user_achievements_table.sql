-- ============================================
-- Migration 010: Create user_achievements table
-- ============================================
-- This table tracks achievements unlocked by users.

CREATE TABLE IF NOT EXISTS user_achievements (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  achievement_id TEXT NOT NULL,
  unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (user_id, achievement_id)
);

-- Add index for fast lookup of a user's achievements
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);

-- Enable Row Level Security
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

-- Policy: Users can see their own achievements
CREATE POLICY "Users can view their own achievements"
  ON user_achievements FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy: Service role or functions can insert achievements
-- No direct insert policy for users to prevent cheating, 
-- though in this app's current state (no custom server) we might need 
-- a policy for authenticated users if we handle logic on client side.
-- For now, let's allow authenticated users to insert to keep it simple 
-- for a client-side logic implementation.
CREATE POLICY "Users can insert their own achievements"
  ON user_achievements FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Comment for documentation
COMMENT ON TABLE user_achievements IS 'Tracks achievements unlocked by users in the Hometown Quiz app.';
