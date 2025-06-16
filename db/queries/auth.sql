-- name: GetUserByCode :one
SELECT u.id as user_id, c.id as corporate_id, u.code as user_code, u.restrict_ip, u.public_ip, c.code as corporate_code, u.password, u.status, c."role" 
FROM "user" u
LEFT JOIN public."corporate" c
ON u.corporate_id = c.id
WHERE u.code = @user_code AND c.code = @corporate_code
LIMIT 1;

-- name: GetUserByCorporateIDAndEmail :one
SELECT u.id as user_id, u.name as user_name, u.code as user_code,
  u.no_handphone, u.password as password, c.code as corporate_code, 
  c.legal_status, c.business_sector,c.name as corporate_name, 
  u.email as email, u.status 
FROM "user" u 
LEFT JOIN public."corporate" c 
ON u.corporate_id = c.id 
WHERE (u.email = @email OR u.no_handphone = @no_handphone) AND c.code = @corporate_code
LIMIT 1;

-- name: UpdateUserPassword :exec
UPDATE "user"
SET 
  password = $1,
  last_date_cp = now()
WHERE email = $2;

-- name: GetUserByPhoneNumber :one
SELECT * FROM "user" u WHERE no_handphone = $1;
