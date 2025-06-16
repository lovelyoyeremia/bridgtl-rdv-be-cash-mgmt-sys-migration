-- name: GetSummaryApproval :one
SELECT
    COUNT(CASE WHEN ua.status = 'WAITING-CHECKER' THEN 1 END) AS total_ongoing,
    COUNT(CASE WHEN ua.status = 'WAITING-SIGNER' THEN 1 END) AS total_needed,
    COUNT(CASE WHEN ua.status = 'REJECTED' THEN 1 END) AS total_rejected
FROM user_authorization ua
LEFT JOIN corporate c ON ua.corporate_id = c.id
WHERE c.code = @corporate_code;

-- name: GetApprovalCorporateList :many
SELECT 
  c.id as corporate_id,
  c.name as corporate_name, 
  ua.id as approval_id,
  ua.tran_date as created_at, 
  ua.status as status, 
  ua."type" as approval_type
FROM user_authorization ua 
LEFT JOIN corporate c
ON ua.corporate_id = c.id
WHERE ua.status <> 'APPROVED' AND ua.type IN (
  'ADD-CORPORATE',
  'EDIT-CORPORATE-ADDRESS',
  'EDIT-CORPORATE-PROFILE',
  'EDIT-CORPORATE-ACCOUNT',
  'EDIT-CORPORATE-ADMIN',
  'EDIT-CORPORATE-SETTING'
  )
  AND ( 
      (@session_role = 'MAKER' OR @session_role = 'ADMIN')
      OR (@session_role = 'SYSADMIN' AND @session_user_id IN (
          SELECT up.user_id FROM user_approval up WHERE up.user_authorization_id = ua.id
      ) AND ua.status <> 'REJECTED') 
      OR (@session_role = 'CHECKER' AND @session_user_id IN (
          SELECT up.user_id FROM user_approval up WHERE up.type = 'CHECKER' AND up.user_authorization_id = ua.id
      ) AND ua.status = 'WAITING-CHECKER') 
      OR (@session_role = 'SIGNER' AND @session_user_id IN (
          SELECT up.user_id FROM user_approval up WHERE up.type = 'SIGNER' AND up.user_authorization_id = ua.id
      ) AND ua.status = 'WAITING-SIGNER')
   )
LIMIT $1
OFFSET $2;

-- name: GetApprovalCorporateListCount :one
SELECT 
  COUNT(*)
FROM user_authorization ua 
LEFT JOIN corporate c
ON ua.corporate_id = c.id
WHERE ua.status <> 'APPROVED' 
  AND ua.type IN (
  'ADD-CORPORATE',
  'EDIT-CORPORATE-ADDRESS',
  'EDIT-CORPORATE-PROFILE',
  'EDIT-CORPORATE-ACCOUNT',
  'EDIT-CORPORATE-ADMIN',
  'EDIT-CORPORATE-SETTING'
  ) AND ( 
      (@session_role = 'MAKER' OR @session_role = 'ADMIN')
      OR (@session_role = 'SYSADMIN' AND @session_user_id IN (
          SELECT up.user_id FROM user_approval up WHERE up.user_authorization_id = ua.id
      ) AND ua.status <> 'REJECTED') 
      OR (@session_role = 'CHECKER' AND @session_user_id IN (
          SELECT up.user_id FROM user_approval up WHERE up.type = 'CHECKER' AND up.user_authorization_id = ua.id
      ) AND ua.status = 'WAITING-CHECKER') 
      OR (@session_role = 'SIGNER' AND @session_user_id IN (
          SELECT up.user_id FROM user_approval up WHERE up.type = 'SIGNER' AND up.user_authorization_id = ua.id
      ) AND ua.status = 'WAITING-SIGNER')
   );

-- name: GetApprovalUserList :many
SELECT 
  u.id as user_id,
  u.name as user_name, 
  uaa."type" as role,
  ua.id as approval_id,
  ua."tran_date" as created_at, 
  ua.status as status, 
  ua."type" as approval_type
FROM user_authorization_access uaa
LEFT JOIN user_authorization ua
ON uaa.authorization_id = ua.id
LEFT JOIN "user" u 
ON uaa.user_id = u.id
LEFT JOIN corporate c
ON u.corporate_id = c.id
WHERE
  ua.status <> 'APPROVED'
  AND( 
      (@session_role = 'MAKER' OR @session_role = 'ADMIN')
      OR (@session_role = 'SYSADMIN' AND @session_user_id IN (
          SELECT up.user_id FROM user_approval up WHERE up.user_authorization_id = ua.id
      ) AND ua.status <> 'REJECTED') 
      OR (@session_role = 'CHECKER' AND @session_user_id IN (
          SELECT up.user_id FROM user_approval up WHERE up.type = 'CHECKER' AND up.user_authorization_id = ua.id
      ) AND ua.status = 'WAITING-CHECKER') 
      OR (@session_role = 'SIGNER' AND @session_user_id IN (
          SELECT up.user_id FROM user_approval up WHERE up.type = 'SIGNER' AND up.user_authorization_id = ua.id
      ) AND ua.status = 'WAITING-SIGNER')
    )
   AND c.code = @corporate_code
LIMIT $1
OFFSET $2;

-- name: GetApprovalUserListCount :one
SELECT 
  COUNT(*) 
FROM user_authorization_access uaa
LEFT JOIN user_authorization ua
ON uaa.authorization_id = ua.id
LEFT JOIN "user" u 
ON uaa.user_id = u.id
LEFT JOIN corporate c
ON u.corporate_id = c.id
WHERE
  ua.status <> 'APPROVED'
  AND( 
      (@session_role = 'MAKER' OR @session_role = 'ADMIN')
      OR (@session_role = 'SYSADMIN' AND @session_user_id IN (
          SELECT up.user_id FROM user_approval up WHERE up.user_authorization_id = ua.id
      ) AND ua.status <> 'REJECTED') 
      OR (@session_role = 'CHECKER' AND @session_user_id IN (
          SELECT up.user_id FROM user_approval up WHERE up.type = 'CHECKER' AND up.user_authorization_id = ua.id
      ) AND ua.status = 'WAITING-CHECKER') 
      OR (@session_role = 'SIGNER' AND @session_user_id IN (
          SELECT up.user_id FROM user_approval up WHERE up.type = 'SIGNER' AND up.user_authorization_id = ua.id
      ) AND ua.status = 'WAITING-SIGNER')
    )
   AND c.code = @corporate_code;


-- name: IsCorporateCheckerExist :one
SELECT EXISTS (
  SELECT 1 FROM user_authorization_access uaa 
  LEFT JOIN (
    SELECT u.id as user_id, c.code as corporate_code FROM "user" u
    LEFT JOIN corporate c ON u.corporate_id = c.id
    WHERE c.code = $1
  ) cp ON uaa.user_id = cp.user_id
  WHERE uaa."type" = 'CHECKER' AND uaa.status = '1' AND cp.corporate_code <> ''
);
