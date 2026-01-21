-- ============================================
-- Migration 007: Create fun_facts table
-- ============================================
-- This migration creates the fun_facts table to store fun facts about Bangladesh
-- Requirements: 5.1, 5.2

-- Create the fun_facts table
CREATE TABLE IF NOT EXISTS fun_facts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  fact_text TEXT NOT NULL,
  category TEXT,
  source TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add index for category queries
CREATE INDEX IF NOT EXISTS idx_fun_facts_category ON fun_facts(category);

-- Enable Row Level Security
ALTER TABLE fun_facts ENABLE ROW LEVEL SECURITY;

-- Policy: All authenticated users can read fun facts
CREATE POLICY "Allow read access for authenticated users"
  ON fun_facts FOR SELECT
  TO authenticated
  USING (true);
