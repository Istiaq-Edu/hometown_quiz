-- ============================================
-- Migration 005: Create get_user_stats RPC function
-- ============================================
-- This migration creates the function to aggregate quiz statistics
-- Requirements: 3.2, 3.3, 3.4, 3.5

-- Create the get_user_stats function
CREATE OR REPLACE FUNCTION get_user_stats(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'quizzes_played', COUNT(*),
    'highest_score', COALESCE(MAX(score), 0),
    'total_correct', COALESCE(SUM(correct_answers), 0),
    'total_questions', COALESCE(SUM(total_questions), 0),
    'time_bonuses', COALESCE(SUM(time_bonus), 0)
  ) INTO result
  FROM quiz_scores
  WHERE user_id = p_user_id;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_user_stats(UUID) TO authenticated;

-- Add comment for documentation
COMMENT ON FUNCTION get_user_stats(UUID) IS 'Returns aggregated quiz statistics for a user including quizzes played, highest score, total correct answers, total questions, and time bonuses';
