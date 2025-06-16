-- name: InsertTransactionSetting :exec
INSERT INTO
    public.transaction_setting (
        corporate_id,
        is_single_bifast_active,
        is_single_rtgs_active,
        is_single_transfer_online_active,
        is_single_skn_active,
        is_mass_bifast_active,
        is_mass_rtgs_active,
        is_mass_transfer_online_active,
        is_mass_skn_active,
        is_va_active,
        created_at,
        updated_at
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
        now(),
        now()
    );

-- name: GetTransactionSettingByCorporateId :one
SELECT
    corporate_id,
    is_single_bifast_active,
    is_single_rtgs_active,
    is_single_transfer_online_active,
    is_single_skn_active,
    is_mass_bifast_active,
    is_mass_rtgs_active,
    is_mass_transfer_online_active,
    is_mass_skn_active,
    is_va_active,
    created_at,
    updated_at
FROM
    public.transaction_setting
WHERE
    corporate_id = $1
LIMIT 1;
