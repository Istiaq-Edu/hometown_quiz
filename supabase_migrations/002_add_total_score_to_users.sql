-- ============================================
-- Migration 002: Add total_score column to users table
-- ============================================
-- This migration adds the total_score column to track cumulative user scores
-- Requirements: 1.2

-- Add total_score column to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS total_score INTEGER NOT NULL DEFAULT 0;

-- Add index for leaderboard queries (ordering by total_score)
CREATE INDEX IF NOT EXISTS idx_users_total_score ON users(total_score DESC);

-- Add index for hometown leaderboard queries
CREATE INDEX IF NOT EXISTS idx_users_hometown_score ON users(hometown, total_score DESC);

-- Update RLS policy to allow reading total_score for leaderboard
-- First, drop existing select policy if it exists, then create new one
DROP POLICY IF EXISTS "Users can read own data" ON users;
DROP POLICY IF EXISTS "Anyone can read users for leaderboard" ON users;

-- Policy: Users can read their own full data
CREATE POLICY "Users can read own data"
  ON users FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Policy: Anyone authenticated can read basic user info for leaderboard
-- This allows reading id, name, hometown, and total_score for all users
CREATE POLICY "Anyone can read users for leaderboard"
  ON users FOR SELECT
  TO authenticated
  USING (true);
