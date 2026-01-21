-- ============================================
-- Migration 009: Add UPDATE policy for users table
-- ============================================
-- This migration adds RLS policy to allow users to update their own profile
-- Requirements: 4.2, 5.2 (Update name and hometown)

-- Drop existing update policy if it exists
DROP POLICY IF EXISTS "Users can update own data" ON users;

-- Policy: Users can update their own data
CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
