-- name: InsertLogin :one
INSERT INTO user_login (
  id,
  user_id,
  status,
  ip_address,
  location,
  device,
  description
) VALUES ( 
  $1,
  $2,
  $3,
  $4,
  $5,
  $6,
  $7
) RETURNING id;

-- name: UpdateLogout :exec
UPDATE user_login
SET 
  logout_date = NOW(),
  description = 'Logout Sukses',
  status = '1'
WHERE 
  status = '0'
  AND id = @id;

-- name: GetLastSession :many
SELECT * FROM user_login 
WHERE status = '1' AND user_id = $1
ORDER BY login_date 
LIMIT 3;
