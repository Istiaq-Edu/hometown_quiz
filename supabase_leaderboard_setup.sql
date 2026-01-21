-- ============================================
-- LEADERBOARD & SCORE STORAGE SETUP
-- ============================================
-- Run this SQL in your Supabase SQL Editor to set up
-- the leaderboard and score storage system.
--
-- Prerequisites:
-- - You must have already set up the 'users' table (see supabase_questions_setup.sql)
-- - Users must be authenticated to save and view scores
--
-- This script will:
-- 1. Create the quiz_scores table for storing individual quiz attempts
-- 2. Add total_score column to users table for cumulative scores
-- 3. Set up Row Level Security policies
-- 4. Create a function to atomically save scores and update totals
-- ============================================

-- ============================================
-- STEP 1: Create quiz_scores table
-- ============================================
-- Stores individual quiz attempt records
-- Requirements: 1.1

CREATE TABLE IF NOT EXISTS quiz_scores (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  category TEXT NOT NULL,
  score INTEGER NOT NULL,
  time_bonus INTEGER NOT NULL DEFAULT 0,
  correct_answers INTEGER NOT NULL,
  total_questions INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_quiz_scores_user_id ON quiz_scores(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_scores_category ON quiz_scores(category);

-- Enable Row Level Security
ALTER TABLE quiz_scores ENABLE ROW LEVEL SECURITY;

-- Policy: Users can insert their own scores
CREATE POLICY "Users can insert their own scores"
  ON quiz_scores FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Policy: Anyone authenticated can read scores (for leaderboard)
CREATE POLICY "Anyone can read scores for leaderboard"
  ON quiz_scores FOR SELECT
  TO authenticated
  USING (true);

-- ============================================
-- STEP 2: Add total_score to users table
-- ============================================
-- Adds cumulative score tracking to user profiles
-- Requirements: 1.2

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS total_score INTEGER NOT NULL DEFAULT 0;

-- Add indexes for leaderboard queries
CREATE INDEX IF NOT EXISTS idx_users_total_score ON users(total_score DESC);
CREATE INDEX IF NOT EXISTS idx_users_hometown_score ON users(hometown, total_score DESC);

-- Update RLS policies for leaderboard access
DROP POLICY IF EXISTS "Users can read own data" ON users;
DROP POLICY IF EXISTS "Anyone can read users for leaderboard" ON users;

-- Policy: Anyone authenticated can read user data for leaderboard
CREATE POLICY "Anyone can read users for leaderboard"
  ON users FOR SELECT
  TO authenticated
  USING (true);

-- ============================================
-- STEP 3: Create function to save score atomically
-- ============================================
-- This function saves a quiz score and updates the user's total_score
-- in a single transaction to ensure data consistency
-- Requirements: 1.1, 1.2

CREATE OR REPLACE FUNCTION save_quiz_score(
  p_user_id UUID,
  p_category TEXT,
  p_score INTEGER,
  p_time_bonus INTEGER,
  p_correct_answers INTEGER,
  p_total_questions INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_total_score INTEGER;
  v_quiz_score_id UUID;
BEGIN
  -- Insert the quiz score record
  INSERT INTO quiz_scores (user_id, category, score, time_bonus, correct_answers, total_questions)
  VALUES (p_user_id, p_category, p_score, p_time_bonus, p_correct_answers, p_total_questions)
  RETURNING id INTO v_quiz_score_id;

  -- Update the user's total_score
  -- Note: p_score already includes time bonus points (11 pts for fast answers vs 10 pts for normal)
  -- p_time_bonus is tracked separately for informational purposes only
  UPDATE users
  SET total_score = total_score + p_score
  WHERE id = p_user_id
  RETURNING total_score INTO v_total_score;

  -- Return success with the new total
  RETURN json_build_object(
    'success', true,
    'quiz_score_id', v_quiz_score_id,
    'new_total_score', v_total_score
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$;

-- ============================================
-- STEP 4: Create function to get user rank
-- ============================================
-- This function calculates a user's rank in the leaderboard
-- Requirements: 3.1, 3.2

CREATE OR REPLACE FUNCTION get_user_rank(
  p_user_id UUID,
  p_hometown TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_rank INTEGER;
  v_total_score INTEGER;
  v_name TEXT;
BEGIN
  -- Get user's total score and name
  SELECT total_score, name INTO v_total_score, v_name
  FROM users
  WHERE id = p_user_id;

  IF p_hometown IS NULL THEN
    -- Global rank: count users with higher scores
    SELECT COUNT(*) + 1 INTO v_rank
    FROM users
    WHERE total_score > v_total_score;
  ELSE
    -- Hometown rank: count users from same hometown with higher scores
    SELECT COUNT(*) + 1 INTO v_rank
    FROM users
    WHERE hometown = p_hometown AND total_score > v_total_score;
  END IF;

  RETURN json_build_object(
    'rank', v_rank,
    'name', v_name,
    'total_score', v_total_score
  );
END;
$$;

-- ============================================
-- DONE! Leaderboard system is ready
-- ============================================
-- 
-- Usage from Flutter:
--
-- 1. Save a quiz score:
--    await supabase.rpc('save_quiz_score', params: {
--      'p_user_id': userId,
--      'p_category': 'Places & History',
--      'p_score': 80,
--      'p_time_bonus': 10,
--      'p_correct_answers': 8,
--      'p_total_questions': 10
--    });
--
-- 2. Get global leaderboard:
--    await supabase
--      .from('users')
--      .select('id, name, hometown, total_score')
--      .order('total_score', ascending: false)
--      .limit(50);
--
-- 3. Get hometown leaderboard:
--    await supabase
--      .from('users')
--      .select('id, name, hometown, total_score')
--      .eq('hometown', 'Dhaka')
--      .order('total_score', ascending: false)
--      .limit(50);
--
-- 4. Get user rank:
--    await supabase.rpc('get_user_rank', params: {
--      'p_user_id': userId,
--      'p_hometown': null  // or 'Dhaka' for hometown rank
--    });
