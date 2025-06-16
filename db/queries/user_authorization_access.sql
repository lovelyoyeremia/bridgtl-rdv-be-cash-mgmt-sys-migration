-- name: BulkInsertUserAuthorizationAccess :exec
INSERT INTO
    user_authorization_access (
        user_id,
        authorization_id,
        status,
        "type",
        authorization_ip,
        created_at
    )
SELECT
    unnest(@user_id :: uuid []),
    unnest(@authorization_id :: uuid []),
    unnest(@status :: text []),
    unnest(@type :: text []),
    unnest(@authorization_ip :: text []),
    now();

-- name: UpdateUserAuthorizationAccess :exec
UPDATE user_authorization_access
SET
  status = COALESCE($2, status),
  "type" = COALESCE($3, "type"),
  authorization_ip = COALESCE($4, authorization_ip)
WHERE user_id = $1 AND authorization_id = $5;

-- name: CountUserAuthorizationAccessActiveByCorporateId :one
SELECT 
  COUNT(*) FILTER (WHERE uaa."type" = 'MAKER') AS maker_count,
  COUNT(*) FILTER (WHERE uaa."type" = 'SIGNER') AS signer_count,
  COUNT(*) FILTER (WHERE uaa."type" = 'CHECKER') AS checker_count
FROM 
  user_authorization_access uaa
JOIN 
  "user" u ON u.id = uaa."user_id"
JOIN 
  corporate c ON c.id = u.corporate_id
WHERE 
  u.corporate_id = $1
  AND uaa.status = '1';
