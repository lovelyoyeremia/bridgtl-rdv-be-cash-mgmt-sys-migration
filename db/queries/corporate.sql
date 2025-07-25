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

-- name: UpdateCorporateAdminFee :exec
UPDATE corporate
SET admin_fee_debit_account_id = sub.selected_account_id
FROM (
    SELECT DISTINCT ON (corporate_id)
           corporate_id,
           id AS selected_account_id
    FROM account
    ORDER BY corporate_id, RANDOM()
) sub
WHERE corporate.id = sub.corporate_id;
