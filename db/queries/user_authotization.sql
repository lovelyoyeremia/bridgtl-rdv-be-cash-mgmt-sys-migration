-- name: InsertUserAuthorization :one
INSERT INTO
    user_authorization (
        "type",
        tran_type,
        old_data,
        new_data,
        status,
        description,
        corporate_id,
        maker_id,
        maker_ip
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
        $9
    ) RETURNING id;

-- name: UpdateUserAuthorization :exec
UPDATE user_authorization
SET
  "type" = COALESCE($1, "type"),
  tran_type = COALESCE($2, tran_type),
  old_data = COALESCE($3, old_data),
  new_data = COALESCE($4, new_data),
  status = COALESCE($5, status),
  description = COALESCE($6, description),
  corporate_id = COALESCE($7, corporate_id),
  maker_id = COALESCE($8, maker_id)
WHERE id = $9;

-- name: GetDetailApproval :one
SELECT
    ua.id as approval_id,
    ua.corporate_id,
    ua.tran_date,
    ua.old_data,
    ua.new_data,
    ua.status as user_authorization_status,
    ua.description,
    ua.type,
    ua.maker_id,
    ua.type as user_authorization_type,
    c.*,
    maker."name" as maker_name,
    ts.is_single_bifast_active,
    ts.is_single_rtgs_active,
    ts.is_single_transfer_online_active,
    ts.is_single_skn_active,
    ts.is_mass_bifast_active,
    ts.is_mass_rtgs_active,
    ts.is_mass_transfer_online_active,
    ts.is_mass_skn_active,
    ts.is_va_active,
    a.account_number as admin_fee_debit_account_number,
    a.account_name as admin_fee_debit_account_name,
    t.*,
    t.id as trx_id,
    src.account_number as src_acc_no,
    src.account_type as src_acc_type,
    (
        SELECT
            CASE
                WHEN COUNT(*) FILTER (WHERE status = 'REJECTED') > 0 THEN 'REJECTED'
                WHEN COUNT(*) FILTER (WHERE type = 'CHECKER' AND status != 'APPROVED') > 0 THEN 'WAITING-CHECKER'
                WHEN COUNT(*) FILTER (WHERE type = 'SIGNER' AND status != 'APPROVED') > 0 THEN 'WAITING-SIGNER'
                ELSE 'APPROVED'
            END
        FROM user_approval ua_sub
        WHERE ua_sub.user_authorization_id = ua.id
    ) AS approval_status
FROM
    user_authorization ua
    JOIN corporate c on c.id = ua.corporate_id 
    LEFT JOIN "user" maker on maker.id = ua.maker_id 
    LEFT JOIN transaction_setting ts on ts.corporate_id = c.id
    LEFT JOIN account a on a.id = c.admin_fee_debit_account_id
    LEFT JOIN transaction t on t.user_authorization_id = ua.id
    LEFT JOIN account src on src.id = t.account_id
where
    ua.id = $1;

-- name: DeleteApproval :one
DELETE FROM user_authorization WHERE id = $1
RETURNING id;

-- name: GetWaitingApproval :many
select
    distinct ua."type"
from
    user_authorization ua
where
    ua.corporate_id = $1
    and ua.status NOT IN ('REJECTED', 'APPROVED', 'FAILED');

-- name: UpdateUserAuthorizationForNewCorporate :one
UPDATE
    user_authorization
SET
    tran_type = COALESCE($2, tran_type),
    old_data = COALESCE($3, old_data),
    new_data = COALESCE($4, new_data),
    status = COALESCE($5, status),
    maker_id = COALESCE($6, maker_id)
WHERE
    corporate_id = $1
    and status = 'DRAFT'
    and type = 'ADD-CORPORATE'
RETURNING id;

-- name: GetLatestDraftApprovalAddCorporate :one
SELECT
    *
FROM
    user_authorization
WHERE
    corporate_id = @corporate_id
    and status = 'DRAFT'
    and type = 'ADD-CORPORATE'
ORDER BY
    tran_date DESC
LIMIT
    1;
