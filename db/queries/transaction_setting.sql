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
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
        now(),
        now()
    );

