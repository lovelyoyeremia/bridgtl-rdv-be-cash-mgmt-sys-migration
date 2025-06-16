-- name: InsertCorporate :one
INSERT INTO public.corporate (
    id,
    code,
    name,
    "role",
    business_group_type,
    business_sector,
    legal_status,
    establishment_place,
    license_type,
    license_number,
    license_issue_date,
    license_expiry_date,
    establishment_deed_number,
    establishment_deed_date,
    amendment_deed_number,
    amendment_deed_date,
    npwp,
    cif,
    address,
    address_postal_code,
    address_village,
    address_sub_district,
    address_city,
    address_province,
    phone_number,
    fax,
    email,
    additional_notes,
    daily_limit,
    transaction_limit,
    max_user_count,
    booking_office_code,
    initiator_personal_number,
    initiator_name,
    initiator_work_unit,
    status,
    abonemen_code,
    customer_number,
    approval_type,
    approval_checker_count,
    approval_signer_count,
    created_at,
    updated_at,
    business_entity_type
)
VALUES (
    $1,  $2,  $3,  $4,  $5,  $6,  $7,  $8,  $9,  $10,
    $11, $12, $13, $14, $15, $16, $17, $18, $19, $20,
    $21, $22, $23, $24, $25, $26, $27, $28, $29, $30,
    $31, $32, $33, $34, $35, $36, $37, $38, $39, $40,
    $41, now(), now(), $42
) RETURNING *;

-- name: GetDetailCorporate :one
SELECT
    c.*,
    ts.*,
    a.account_number as admin_fee_debit_account_number,
    a.account_name as admin_fee_debit_account_name,
    a.user_authorization_id
FROM
    corporate c
    LEFT JOIN transaction_setting ts on ts.corporate_id = c.id
    left join account a on c.admin_fee_debit_account_id = a.id 
WHERE
    c.id = $1;

-- name: GetDetailCorporateByCode :one
SELECT * FROM corporate WHERE code = $1;

-- name: UpdateCorporateAddress :exec
UPDATE
    corporate
SET
    address = $1,
    address_postal_code = $2,
    address_village = $3,
    address_sub_district = $4,
    address_city = $5,
    address_province = $6,
    phone_number = $7,
    fax = $8,
    email = $9,
    initiator_personal_number = $10,
    initiator_name = $11,
    initiator_work_unit = $12,
    updated_by = $13,
    updated_at = now(),
    status = $14
WHERE
    id = $15;

-- name: IsExistsCorporateId :one
SELECT
    EXISTS (
        SELECT
            1
        from
            corporate c
        where
            c.id = $1
    );

-- name: UpdateCorporateSetting :exec
UPDATE
    corporate
SET
    daily_limit = $1,
    transaction_limit = $2,
    max_user_count = $3,
    approval_type = $4,
    approval_checker_count = $5,
    approval_signer_count = $6,
    updated_by = $7,
    updated_at = now(),
    status = $8,
    admin_fee_debit_account_id= $9
WHERE
    id = $10;

-- name: UpdateCorporateStatus :exec
UPDATE
    corporate
SET
    updated_by = $1,
    updated_at = now(),
    status = $2
WHERE
    id = $3;

-- name: ListApprovalCorporate :many
WITH combined_data AS (
    SELECT
        c.id,
        ua.id AS approval_id,
        c.role,
        c.code,
        c.name,
        ua.status,
        ua.tran_date AS created_at,
        ua.type AS approval_type
    FROM
        user_authorization ua
        JOIN corporate c ON c.id = ua.corporate_id
    WHERE
        ua.status <> 'APPROVED'
        and c.status in ('ACTIVE', 'REVIEW')
        AND ua.type IN (
            'ADD-CORPORATE',
            'EDIT-CORPORATE-ADDRESS',
            'EDIT-CORPORATE-PROFILE',
            'EDIT-CORPORATE-ACCOUNT',
            'EDIT-CORPORATE-ADMIN',
            'EDIT-CORPORATE-SETTING'
        )
        AND (
            @role = 'admin'
            OR @role = 'maker'
            OR (
                @role IN ('checker', 'signer', 'sysadmin')
                AND EXISTS (
                    SELECT
                        1
                    FROM
                        user_approval uap
                    WHERE
                        uap.user_authorization_id = ua.id
                        AND uap.user_id = @user_id
                        AND (
                            (
                                @role = 'checker'
                                AND uap.type = 'CHECKER'
                            )
                            OR (
                                @role = 'signer'
                                AND uap.type = 'SIGNER'
                            )
                            OR (@role = 'sysadmin')
                        )
                )
            )
        )
    UNION
    ALL
    SELECT
        c.id,
        NULL AS approval_id,
        c.role,
        c.code,
        c.name,
        c.status AS status,
        c.created_at,
        c.status AS approval_type
    FROM
        corporate c
    WHERE
        c.status ILIKE 'DRAFT%'
        AND @role IN ('maker', 'admin')
)
SELECT
    id,
    approval_id,
    role,
    code,
    name,
    status,
    created_at,
    approval_type
FROM
    combined_data
WHERE
    (
        NULLIF(@search, '') IS NULL
        OR name ILIKE '%' || @search || '%'
    )
ORDER BY
    created_at DESC
LIMIT
    @page_limit OFFSET @page_offset;

-- name: CountListApprovalCorporate :one
WITH combined_data AS (
    SELECT
        c.id,
        ua.id AS approval_id,
        c.role,
        c.code,
        c.name,
        ua.status,
        ua.tran_date AS created_at,
        ua.type AS approval_type
    FROM
        user_authorization ua
        JOIN corporate c ON c.id = ua.corporate_id
    WHERE
        ua.status <> 'APPROVED'
        and c.status in ('ACTIVE', 'REVIEW')
        AND ua.type IN (
            'ADD-CORPORATE',
            'EDIT-CORPORATE-ADDRESS',
            'EDIT-CORPORATE-PROFILE',
            'EDIT-CORPORATE-ACCOUNT',
            'EDIT-CORPORATE-ADMIN',
            'EDIT-CORPORATE-SETTING'
        )
        AND (
            @role = 'admin'
            OR @role = 'maker'
            OR (
                @role IN ('checker', 'signer', 'sysadmin')
                AND EXISTS (
                    SELECT
                        1
                    FROM
                        user_approval uap
                    WHERE
                        uap.user_authorization_id = ua.id
                        AND uap.user_id = @user_id
                        AND (
                            (
                                @role = 'checker'
                                AND uap.type = 'CHECKER'
                            )
                            OR (
                                @role = 'signer'
                                AND uap.type = 'SIGNER'
                            )
                            OR (@role = 'sysadmin')
                        )
                )
            )
        )
    UNION
    ALL
    SELECT
        c.id,
        NULL AS approval_id,
        c.role,
        c.code,
        c.name,
        c.status AS status,
        c.created_at,
        c.status AS approval_type
    FROM
        corporate c
    WHERE
        c.status ILIKE 'DRAFT%'
        AND @role IN ('maker', 'admin')
)
SELECT
    COUNT(*) AS total_count
FROM
    combined_data
WHERE
    (
        NULLIF(@search, '') IS NULL
        OR name ILIKE '%' || @search || '%'
    );

-- name: UpdateCorporateProfile :exec
UPDATE
    corporate
SET
    name = COALESCE($1, name),
    business_group_type = COALESCE($2, business_group_type),
    business_sector = COALESCE($3, business_sector),
    legal_status = COALESCE($4, legal_status),
    establishment_place = COALESCE($5, establishment_place),
    license_type = COALESCE($6, license_type),
    license_number = COALESCE($7, license_number),
    license_issue_date = COALESCE($8, license_issue_date),
    license_expiry_date = COALESCE($9, license_expiry_date),
    establishment_deed_number = COALESCE($10, establishment_deed_number),
    establishment_deed_date = COALESCE($11, establishment_deed_date),
    amendment_deed_number = COALESCE($12, amendment_deed_number),
    amendment_deed_date = COALESCE($13, amendment_deed_date),
    npwp = COALESCE($14, npwp),
    cif = COALESCE($15, cif),
    address = COALESCE($16, address),
    address_postal_code = COALESCE($17, address_postal_code),
    address_village = COALESCE($18, address_village),
    address_sub_district = COALESCE($19, address_sub_district),
    address_city = COALESCE($20, address_city),
    address_province = COALESCE($21, address_province),
    phone_number = COALESCE($22, phone_number),
    fax = COALESCE($23, fax),
    email = COALESCE($24, email),
    updated_by = COALESCE($25, updated_by),
    updated_at = now(),
    business_entity_type = COALESCE($27, business_entity_type)
WHERE
    id = $26;

-- name: UpdateTransactionSetting :exec
UPDATE
    transaction_setting
SET
    is_single_bifast_active = $1,
    is_single_rtgs_active = $2,
    is_single_transfer_online_active = $3,
    is_single_skn_active = $4,
    is_mass_bifast_active = $5,
    is_mass_rtgs_active = $6,
    is_mass_transfer_online_active = $7,
    is_mass_skn_active = $8,
    is_va_active = $9,
    updated_at = now()
WHERE
    corporate_id = $10;

-- name: ListCorporate :many
SELECT
    c.id,
    c.role,
    c.code,
    c.name,
    c.status,
    c.updated_at
FROM
    corporate c
WHERE
    c.status = @status
    and (
        NULLIF(@search, '') IS NULL
        OR c.name ILIKE '%' || @search || '%'
    )
ORDER BY
    c.updated_at DESC
LIMIT
    @page_limit OFFSET @page_offset;

-- name: CountListCorporate :one
SELECT
    COUNT(c.id)
FROM
    corporate c
WHERE
    c.status = @status
    and (
        NULLIF(@search, '') IS NULL
        OR c.name ILIKE '%' || @search || '%'
    );

-- name: GetCorporateByIDActive :one
SELECT * FROM corporate 
WHERE id = $1 AND status = 'ACTIVE' 
LIMIT 1;

-- name: CheckCorporateExists :one
SELECT 
  (SELECT EXISTS (SELECT 1 FROM corporate c WHERE c.code = $1)) AS is_code_exist_new_corporate,
  (SELECT EXISTS (SELECT 1 FROM corporate c WHERE c.code = $1 AND c.id != $2)) AS is_code_exist_update_corporate,
  (SELECT EXISTS (SELECT 1 FROM corporate c WHERE c.cif = $3)) AS is_cif_exist_new_corporate,
  (SELECT EXISTS (SELECT 1 FROM corporate c WHERE c.cif = $3 AND c.id != $2)) AS is_cif_exist_update_corporate;
