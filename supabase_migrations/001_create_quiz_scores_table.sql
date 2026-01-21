-- ============================================
-- Migration 001: Create quiz_scores table
-- ============================================
-- This migration creates the quiz_scores table to store individual quiz attempts
-- Requirements: 1.1

-- Create the quiz_scores table
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

-- Add index for faster queries by user
CREATE INDEX IF NOT EXISTS idx_quiz_scores_user_id ON quiz_scores(user_id);

-- Add index for queries by category
CREATE INDEX IF NOT EXISTS idx_quiz_scores_category ON quiz_scores(category);

-- Enable Row Level Security
ALTER TABLE quiz_scores ENABLE ROW LEVEL SECURITY;

-- Policy: Users can insert their own scores
CREATE POLICY "Users can insert their own scores"
  ON quiz_scores FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can read their own scores
CREATE POLICY "Users can read their own scores"
  ON quiz_scores FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy: Allow reading all scores for leaderboard purposes (public read)
CREATE POLICY "Anyone can read scores for leaderboard"
  ON quiz_scores FOR SELECT
  TO authenticated
  USING (true);
