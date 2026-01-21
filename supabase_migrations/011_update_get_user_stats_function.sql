-- ============================================
-- Migration 011: Update get_user_stats RPC function
-- ============================================
-- Adds 'distinct_categories' and 'total_time_bonus' to the stats.

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
    'time_bonuses', COALESCE(SUM(time_bonus), 0),
    'distinct_categories', COUNT(DISTINCT category)
  ) INTO result
  FROM quiz_scores
  WHERE user_id = p_user_id;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Re-grant execute permission
GRANT EXECUTE ON FUNCTION get_user_stats(UUID) TO authenticated;
