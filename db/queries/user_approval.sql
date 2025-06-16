-- name: BulkInsertUserApproval :exec
INSERT INTO
    user_approval (
        user_authorization_id,
        user_id,
        status,
        type,
        created_by
    )
SELECT
    unnest(@user_authorization_id :: uuid []),
    unnest(@user_id :: uuid []),
    unnest(@status :: text []),
    unnest(@type :: text []),
    unnest(@created_by :: uuid []);

-- name: GetUserApprovalByApprovalId :many
select
    a.user_authorization_id as user_authorization_id,
    a.status as approval_status,
    a.type as approval_type,
    a.notes,
    a.user_id,
    a.reviewed_at,
    u.*
from
    user_approval a
    join "user" u on u.id = a.user_id
where
    a.user_authorization_id = @user_authorization_id
order by a.created_at DESC;

-- name: GetUserApprovalByUserIdAndApprovalId :one
select
    a.status as approval_status,
    a.type as approval_type,
    a.notes,
    a.user_id,
    a.reviewed_at,
    u.*
from
    user_approval a
    join "user" u on u.id = a.user_id
where
    a.user_authorization_id = @user_authorization_id AND a.user_id = @user_id;

-- name: GetUserApprovalByType :many
select
    a.status as approval_status,
    a.type as approval_type,
    a.notes,
    a.user_id,
    a.reviewed_at,
    u.*
from
    user_approval a
    join "user" u on u.id = a.user_id
where
    a.user_authorization_id = @user_authorization_id AND a.type = @user_type;

-- name: UpdateStatusUserApproval :one
UPDATE
    user_approval ua
SET
    status = @status,
    reviewed_at = NOW(),
    notes = @notes
WHERE
    user_authorization_id = @user_authorization_id
    and user_id = @user_id
    and status in ('PENDING', 'REJECTED')
    and "type" = @user_type
RETURNING *;

-- name: RejectApproval :one
WITH updated_auth AS (
  UPDATE user_authorization
  SET 
    new_data = CASE 
            WHEN "type" = 'EDIT-USER' THEN COALESCE(old_data, new_data)
            ELSE new_data
            END,
    old_data = NULL,
    status = 'REJECTED'
  WHERE user_authorization.id = @authorization_id
  RETURNING id
)
UPDATE user_approval
SET
  status = 'REJECTED',
  reviewed_at = NOW(),
  user_id = @reject_id,
  notes = @notes
FROM updated_auth WHERE user_approval.user_authorization_id = updated_auth.id AND user_approval.user_id = @user_id
RETURNING updated_auth.id;

-- name: GetUserApprovalByApprovalIdAndPendingStatus :many
select
    a.status as approval_status,
    a.type as approval_type,
    a.notes,
    a.user_id,
    a.reviewed_at,
    u.*
from
    user_approval a
    join "user" u on u.id = a.user_id
where
    a.user_authorization_id = @user_authorization_id AND a.status = 'PENDING';

-- name: GetStatusUserAuthorization :one
SELECT
    CASE
        WHEN COUNT(*) FILTER (WHERE status = 'REJECTED') > 0 THEN 'REJECTED'
        WHEN COUNT(*) FILTER (WHERE type = 'CHECKER' AND status != 'APPROVED') > 0 THEN 'WAITING-CHECKER'
        WHEN COUNT(*) FILTER (WHERE type = 'SIGNER' AND status != 'APPROVED') > 0 THEN 'WAITING-SIGNER'
        ELSE 'APPROVED'
    END
FROM user_approval ua_sub
WHERE ua_sub.user_authorization_id = @approval_id;

-- name: IsCorporateApprovalExist :one
SELECT EXISTS (
  SELECT 1 FROM user_authorization_access uaa 
  LEFT JOIN (
    SELECT u.id as user_id, c.code as corporate_code FROM "user" u
    LEFT JOIN corporate c ON u.corporate_id = c.id
    WHERE c.code = @corporate_code
  ) cp ON uaa.user_id = cp.user_id
  WHERE uaa."type" = ANY(sqlc.slice('user_approval_type')::text[])
  and uaa.user_id = @user_id
  AND uaa.status = '1' AND cp.corporate_code <> 'AGRO' -- filter approval can't use internal corporate code
);

-- name: UpdateUserApproval :exec
INSERT INTO user_approval (
  user_id,
  user_authorization_id,
  type,
  status,
  created_by
) SELECT @user_id, @user_authorization_id, @type, @status, @created_by WHERE EXISTS (
  SELECT 1 FROM user_approval u
  WHERE u.user_authorization_id = @user_authorization_id
);

