-- ============================================
-- Migration 003: Add photo_url column to users table
-- ============================================
-- This migration adds the photo_url column for profile photos
-- Requirements: 2.2, 2.3

-- Add photo_url column to users table (nullable text)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS photo_url TEXT;

-- Add comment for documentation
COMMENT ON COLUMN users.photo_url IS 'URL to user profile photo stored in Supabase Storage';
