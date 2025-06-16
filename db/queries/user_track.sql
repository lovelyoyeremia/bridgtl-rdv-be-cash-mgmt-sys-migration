-- name: InsertUpdateUserTrack :exec 
INSERT INTO user_track (
  user_login_id,
  user_id,
  current_page
) VALUES (
  $1,
  $2,
  $3
) ON CONFLICT (user_login_id)
DO UPDATE SET
  last_seen_at = NOW(),
  current_page = $3;

