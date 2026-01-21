-- ============================================
-- Migration 006: Create delete_user_account RPC function
-- ============================================
-- This migration creates the function to delete user account and all related data
-- Requirements: 8.2

-- Create the delete_user_account function
CREATE OR REPLACE FUNCTION delete_user_account(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  -- Delete quiz scores for the user
  DELETE FROM quiz_scores WHERE user_id = p_user_id;
  
  -- Delete user record from users table
  DELETE FROM users WHERE id = p_user_id;
  
  -- Note: Profile photo deletion from storage should be handled 
  -- by the application before calling this function, as storage
  -- operations require the Supabase client
  
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION delete_user_account(UUID) TO authenticated;

-- Add comment for documentation
COMMENT ON FUNCTION delete_user_account(UUID) IS 'Deletes all user data including quiz scores and user record. Profile photo should be deleted from storage before calling this function.';
