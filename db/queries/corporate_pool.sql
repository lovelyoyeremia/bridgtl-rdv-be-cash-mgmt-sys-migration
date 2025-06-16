-- name: InsertCorporateGroup :one
INSERT INTO corporate_group (
  name
) VALUES (
  $1
) RETURNING *;

-- name: InsertCorporatePool :one
INSERT INTO corporate_pool (
  corporate_id,
  group_id,
  maintenance_at,
  created_by
) VALUES (
  $1,
  $2,
  $3,
  $4
) RETURNING *;

-- name: UpdateCorporatePool :one
UPDATE corporate_pool
SET
  corporate_id = COALESCE(@corporate_id, corporate_id),
  group_id = COALESCE(@group_id, group_id),
  maintenance_at = NOW()
WHERE id = @id
RETURNING *;

-- name: GetListCorporateGroup :many
SELECT * FROM corporate_group
LIMIT $1
OFFSET $2;

-- name: GetListCorporateGroupCount :one
SELECT COUNT(*) FROM corporate_group;


-- name: ListCorporatePool :many
WITH combined_data AS (
    SELECT
        ua.id as approval_id,
        ua.new_data,
        ua.status,
        NULL as corporate_pool_id,
        ua.tran_date as created_at,
        ua.corporate_id,
        NULL as group_id
    FROM
        user_authorization ua
    WHERE
        ua.status <> 'APPROVED'
        AND ua.type IN ('ADD-CORPORATE-POOL', 'EDIT-CORPORATE-POOL')
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
    UNION ALL
    SELECT
        NULL as approval_id,
        NULL as new_data,
        'ACTIVE' as status,
        cp.id as corporate_pool_id,
        cp.created_at,
        cp.corporate_id,
        cp.group_id
    FROM
        corporate_pool cp
)
SELECT
    cd.*,
    c.name as corporate_name,
    cg.name as group_name,
    cg.created_at as group_created_at,
    c.updated_at as maintenance_at
FROM
    combined_data cd
    LEFT JOIN corporate_group cg ON cd.group_id = cg.id
    LEFT JOIN corporate c ON cd.corporate_id = c.id
ORDER BY
    cd.created_at DESC;

-- name: GetDetailCorporatePool :one
WITH combined_data AS (
    SELECT
        ua.id as approval_id,
        ua.new_data,
        ua.status,
        NULL as corporate_pool_id,
        ua.tran_date as created_at,
        ua.tran_date as maintenance_at,
        ua.corporate_id,
        NULL as group_id,
        ua.maker_id as created_by_id,
        ua.description
    FROM
        user_authorization ua
    WHERE
        ua.status <> 'APPROVED'
        AND ua.type IN ('ADD-CORPORATE-POOL', 'EDIT-CORPORATE-POOL')
        AND ua.id = @id
    UNION ALL
    SELECT
        NULL as approval_id,
        NULL as new_data,
        'ACTIVE' as status,
        cp.id as corporate_pool_id,
        cp.created_at,
        cp.maintenance_at,
        cp.corporate_id,
        cp.group_id,
        cp.created_by as created_by_id,
        NULL as description
    FROM
        corporate_pool cp
    WHERE cp.id = @id
)
SELECT
    cd.*,
    u.name as created_by_name,
    c.name as corporate_name,
    cg.name as group_name,
    cg.created_at as group_created_at
FROM
    combined_data cd
    LEFT JOIN "user" u ON cd.created_by_id = u.id
    LEFT JOIN corporate_group cg ON cd.group_id = cg.id
    LEFT JOIN corporate c ON cd.corporate_id = c.id
LIMIT 1;

-- name: IsGroupNameExist :one
SELECT EXISTS (
  SELECT 1 FROM corporate_group WHERE LOWER(name) = LOWER(@name)
);

-- name: IsCorporatePoolExist :one
SELECT EXISTS (
  SELECT 1 FROM corporate_pool WHERE corporate_id = $1
);


-- name: GetDetailCorporateGroup :one
SELECT * FROM corporate_group WHERE id = $1 LIMIT 1;
