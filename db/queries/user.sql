-- name: InsertUser :one
INSERT INTO
    public."user" (
    "corporate_id",
    "code",
    "name",
    "password",
    "created_by",
    "position",
    "no_telepon",
    "no_handphone",
    "email",
    "identity_type",
    "identity_no",
    "identity_expired",
    "identity_created_by",
    "pob",
    "dob",
    "address",
    "mother_name",
    "restrict_ip",
    "public_ip",
    "status",
    "password_list",
    "created_at"
    )
VALUES
(
        $1,
        $2,
        $3,
        $4,
        $5,
        $6,
        $7,
        $8,
        $9,
        $10,
        $11,
        $12,
        $13,
        $14,
        $15,
        $16,
        $17,
        $18,
        $19,
        $20,
        $21,
        now()
) RETURNING *;


-- name: IsUserAttributesExist :one
SELECT 
  EXISTS (SELECT 1 FROM "user" u WHERE u.email = @email AND u.corporate_id = @corporate_id) AS is_email_exist,
  EXISTS (SELECT 1 FROM "user" u WHERE u.no_handphone = @no_handphone AND u.corporate_id = @corporate_id) AS is_no_handphone_exist,
  EXISTS (SELECT 1 FROM "user" u WHERE u.no_telepon = @no_telepon AND u.corporate_id = @corporate_id) AS is_no_telepon_exist,
  EXISTS (SELECT 1 FROM "user" u WHERE u.identity_no = @identity_no AND u.corporate_id = @corporate_id) AS is_identity_no_exist;

-- name: ShowRoles :many
SELECT "type" FROM "user_authorization_access"
WHERE user_id = $1 AND status = '1'
LIMIT 3;

-- name: BulkInsertUser :many
INSERT INTO
    "user" (
        "id",
        "corporate_id",
        "code",
        "name",
        "password",
        "position",
        "no_telepon",
        "no_handphone",
        "email",
        "identity_type",
        "identity_no",
        "identity_expired",
        "identity_created_by",
        "pob",
        "dob",
        "address",
        "mother_name",
        "restrict_ip",
        "public_ip",
        "status",
        "password_list",
        "created_at",
        "created_by"
    )
SELECT
    unnest(@id :: uuid[]),
    unnest(@corporate_id :: uuid []),
    unnest(@code :: text []),
    unnest(@name :: text []),
    unnest(@password :: text []),
    unnest(@position :: text []),
    unnest(@no_telepon :: text []),
    unnest(@no_handphone :: text []),
    unnest(@email :: text []),
    unnest(@identity_type :: text []),
    unnest(@identity_no :: text []),
    unnest(@identity_expired :: date []),
    unnest(@identity_created_by :: text []),
    unnest(@pob :: text []),
    unnest(@dob :: date []),
    unnest(@address :: text []),
    unnest(@mother_name :: text []),
    unnest(@restrict_ip :: boolean []),
    unnest(@public_ip :: text []),
    'ACTIVE',
    unnest(@password_list :: text []),
    now(),
    unnest(@created_by :: uuid [])
RETURNING id, code;

-- name: GetDetailUser :one
SELECT 
  u.*, uu.name as created_by_name, 
  ua.id as authorization_id,
  ua.maker_id, uum.name as maker_name,
  ua.description,
  uaa.id as user_access_id,
  uaa."type" as role, 
  ua."type" as authorization_type,
  ua.status as authorization_status,
  ua.new_data,
  ua.old_data,
  c.name as corporate_name,
  c.code as corporate_code
FROM "user" u 
INNER JOIN "user" uu ON u.created_by = uu.id
LEFT JOIN user_authorization_access uaa ON uaa.user_id = u.id
LEFT JOIN user_authorization ua ON uaa.authorization_id = ua.id
INNER JOIN "user" uum ON ua.maker_id = uum.id
LEFT JOIN corporate c ON u.corporate_id = c.id
WHERE u.id = @user_id
LIMIT 1;

-- name: GetUserByID :one
SELECT * FROM "user" WHERE id = $1;

-- name: GetUserByRole :many
SELECT 
    u.*, 
    uu.name AS created_by_name, 
    ua.type AS role 
FROM 
    "user" u 
INNER JOIN 
    "user" uu ON u.created_by = uu.id
LEFT JOIN 
    user_authorization_access ua ON ua.user_id = u.id
LEFT JOIN 
    corporate c ON u.corporate_id = c.id
WHERE 
    (
        CASE 
            WHEN @role IN ('CHECKER', 'SIGNER') AND ua.type = 'SYSADMIN' THEN 1
            WHEN @role = 'CHECKER' AND ua.type = 'CHECKER' THEN 1
            WHEN @role = 'SIGNER' AND ua.type = 'SIGNER' THEN 1
            WHEN @role = 'MAKER' AND ua.type IN ('MAKER', 'ADMIN') THEN 1
            ELSE 0
        END
    ) = 1
    AND c.code = @corporate_code
    AND u.id <> @user_id
    AND ua.status = '1'
    AND u.status = 'ACTIVE';

-- name: ShowAllUserByCorporateId :many
select
    u.id,
    u.code,
    u."name",
    u.public_ip,
    u.restrict_ip,
    uaa."type"
from
    "user" u
    join user_authorization_access uaa on uaa.user_id = u.id
where
    u.corporate_id = @corp_id
    and uaa.status = @status;

-- name: ListUser :many
WITH approval_types AS (
    SELECT
        unnest(
            ARRAY [
        'ADD-USER',
        'EDIT-USER',
        'DELETE-USER'
    ]
        ) AS type
),
approval_statuses AS (
    SELECT
        unnest(ARRAY ['WAITING-CHECKER', 'WAITING-SIGNER']) AS status
),
user_last_seen AS (
    SELECT
        u.id AS user_id,
        MAX(
            CASE
                WHEN ut.last_seen_at IS NOT NULL
                    THEN ut.last_seen_at
                ELSE u.created_at
            END
        ) AS last_seen_at
    FROM "user" u
    LEFT JOIN user_track ut
    ON ut.user_id = u.id
    GROUP BY u.id
)
SELECT
  u.id,
  u.code,
  u."name",
  u.email,
  uaa."type",
  u.status,
  ua."type" as approval_type,
  ua.status as approval_status,
  uls.last_seen_at as last_seen_at
FROM "user" u
LEFT JOIN user_authorization_access uaa
ON uaa.user_id = u.id
LEFT JOIN user_authorization ua
ON uaa.authorization_id = ua.id
LEFT JOIN user_last_seen uls
ON uls.user_id = u.id
LEFT JOIN corporate c
ON u.corporate_id = c.id
WHERE 
  c.code = @corporate_code
  AND (u.id <> @session_user_id) 
  AND (
  NULLIF(@status, '') IS NULL
  AND (uaa."type" IS NOT NULL OR uaa."type" <> '')
  OR (
    LOWER(@status) = 'active'
    AND u.status = 'ACTIVE'
  )
  OR (
    LOWER(@status) = 'nonactive'
    AND u.status IN ('LOCKED', 'SUSPENDED')
  )
  OR (
    LOWER(@status) = 'inprogress'
    AND (
      ua.status IN (
        SELECT
          status
        FROM
          approval_statuses
      )
      AND ua.type IN (
        SELECT
          type
        FROM
          approval_types
      )
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
  )
)
ORDER BY uls.last_seen_at DESC
LIMIT $1
OFFSET $2;

-- name: ListUserCount :one
WITH approval_types AS (
    SELECT
        unnest(
            ARRAY [
        'ADD-USER',
        'EDIT-USER',
        'DELETE-USER'
    ]
        ) AS type
),
approval_statuses AS (
    SELECT
        unnest(ARRAY ['WAITING-CHECKER', 'WAITING-SIGNER']) AS status
),
user_last_seen AS (
    SELECT
        u.id AS user_id,
        MAX(
            CASE
                WHEN ut.last_seen_at IS NOT NULL
                    THEN ut.last_seen_at
                ELSE u.created_at
            END
        ) AS last_seen_at
    FROM "user" u
    LEFT JOIN user_track ut
    ON ut.user_id = u.id
    GROUP BY u.id
)
SELECT COUNT(*) FROM "user" u
LEFT JOIN user_authorization_access uaa
ON uaa.user_id = u.id
LEFT JOIN user_authorization ua
ON uaa.authorization_id = ua.id
LEFT JOIN user_last_seen uls
ON uls.user_id = u.id
LEFT JOIN corporate c
ON c.id = u.corporate_id
WHERE 
  c.code = @corporate_code
  AND (u.id <> @session_user_id) 
  AND (
  NULLIF(@status, '') IS NULL
  AND (uaa."type" IS NOT NULL OR uaa."type" <> '')
  OR (
    LOWER(@status) = 'active'
    AND u.status = 'ACTIVE'
  )
  OR (
    LOWER(@status) = 'nonactive'
    AND u.status IN ('LOCKED', 'SUSPENDED')
  )
  OR (
    LOWER(@status) = 'inprogress'
    AND (
      ua.status IN (
        SELECT
          status
        FROM
          approval_statuses
      )
      AND ua.type IN (
        SELECT
          type
        FROM
          approval_types
      )
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
  ) 
);

-- name: UpdateUserStatus :exec
UPDATE "user"
SET
  status = @status
WHERE id = @id;

-- name: UpdateUser :exec
UPDATE "user"
SET
    "name" = COALESCE($1, "name"),
    "position" = COALESCE($2, "position"),
    "no_telepon" = COALESCE($3, "no_telepon"),
    "no_handphone" = COALESCE($4, "no_handphone"),
    "email" = COALESCE($5, "email"),
    "identity_type" = COALESCE($6, "identity_type"),
    "identity_no" = COALESCE($7, "identity_no"),
    "identity_expired" = COALESCE($8, "identity_expired"),
    "identity_created_by" = COALESCE($9, "identity_created_by"),
    "pob" = COALESCE($10, "pob"),
    "dob" = COALESCE($11, "dob"),
    "address" = COALESCE($12, "address"),
    "mother_name" = COALESCE($13, "mother_name"),
    "restrict_ip" = COALESCE($14, "restrict_ip"),
    "public_ip" = COALESCE($15, "public_ip"),
    "status" = COALESCE($16, "status")
WHERE id = @id;

-- name: GetAdminAndSysAdminByCorpId :one
SELECT 
    ua1.id as admin_id,
    ua1.address AS admin_address,
    ua1.dob AS admin_dob,
    ua1.email AS admin_email,
    ua1.identity_created_by AS admin_identity_created_by,
    ua1.identity_expired AS admin_identity_expired,
    ua1.identity_no AS admin_identity_no,
    ua1.identity_type AS admin_identity_type,
    ua1.name AS admin_name,
    ua1.no_handphone AS admin_no_handphone,
    ua1.no_telepon AS admin_no_telepon,
    ua1.pob AS admin_pob,
    ua1.position AS admin_position,
    ua1.restrict_ip AS admin_restrict_ip,
    ua1.public_ip as admin_public_ip,
    ua1.role AS admin_role,
    ua2.id as sysadmin_id,
    ua2.address AS sysadmin_address,
    ua2.dob AS sysadmin_dob,
    ua2.email AS sysadmin_email,
    ua2.identity_created_by AS sysadmin_identity_created_by,
    ua2.identity_expired AS sysadmin_identity_expired,
    ua2.identity_no AS sysadmin_identity_no,
    ua2.identity_type AS sysadmin_identity_type,
    ua2.name AS sysadmin_name,
    ua2.no_handphone AS sysadmin_no_handphone,
    ua2.no_telepon AS sysadmin_no_telepon,
    ua2.pob AS sysadmin_pob,
    ua2.position AS sysadmin_position,
    ua2.restrict_ip AS sysadmin_restrict_ip,
    ua2.role AS sysadmin_role,
    ua2.public_ip as sysadmin_public_ip
FROM 
    (SELECT u.*, uaa.type AS role FROM user_authorization_access uaa
     JOIN "user" u ON u.id = uaa.user_id
     JOIN user_authorization ua ON ua.id = uaa.authorization_id
     WHERE ua.corporate_id = $1
     AND uaa.type = 'ADMIN'
     LIMIT 1) AS ua1
CROSS JOIN 
    (SELECT u.*, uaa.type AS role FROM user_authorization_access uaa
     JOIN "user" u ON u.id = uaa.user_id
     JOIN user_authorization ua ON ua.id = uaa.authorization_id
     WHERE ua.corporate_id = $1
     AND uaa.type = 'SYSADMIN'
     LIMIT 1) AS ua2;

-- name: IsUserRoleValid :one
SELECT (
  SELECT COUNT(DISTINCT user_id) 
  FROM user_authorization_access 
  WHERE user_id = ANY(@user_id :: uuid[]) 
  AND (type = @user_role OR type = 'SYSADMIN')
) = (
  SELECT COUNT(DISTINCT unnest_user_id) 
  FROM unnest(@user_id :: uuid[]) AS unnest_user_id
);

-- name: ListAdministratorByCorporateId :many
select
    u.*,
    uaa."type" as role,
    c.code as corporate_code,
    c."name" as corporate_name 
from
    "user" u
    join user_authorization_access uaa on uaa.user_id = u.id
    join corporate c on c.id = u.corporate_id 
where
    u.corporate_id = $1
    and uaa.status = '1'
    and uaa."type" in ('ADMIN', 'SYSADMIN');
