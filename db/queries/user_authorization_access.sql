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

-- name: InsertUserAuthorizationAccess :exec
INSERT INTO
    user_authorization_access (
        user_id,
        authorization_id,
        status,
        "type",
        authorization_ip,
        created_at
    )
VALUES (
  $1,
  $2,
  $3,
  $4,
  $5,
  now()
);

