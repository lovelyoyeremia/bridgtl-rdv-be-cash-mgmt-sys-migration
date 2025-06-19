-- name: InsertAccount :exec
INSERT INTO
    account (
        corporate_id,
        account_number,
        account_name,
        account_type,
        ownership,
        accessibility,
        currency,
        maturity,
        break,
        is_active,
        user_authorization_id
    )
VALUES (
    @corporate_id,
    @account_number,
    @account_name,
    @account_type,
    @ownership,
    @accessibility,
    @currency,
    @maturity,
    @break,
    @is_active,
    @user_authorization_id
);

-- name: CountAccountByCorporateId :one
select
    count(*)
from
    account a
where
    a.corporate_id = @corporate_id
    and is_active;

-- name: ListAccountByCorporateId :many
WITH base_query AS (
    select
        a.*,
        c."name"
    from
        account a
        join corporate c on c.id = a.corporate_id
    where
        corporate_id = @corporate_id
        AND (
            CASE
                WHEN @account_type :: text = '' THEN true
                WHEN @account_type :: text = 'GIRO' THEN account_type = 'GIRO'
                WHEN @account_type :: text = 'OTHER' THEN account_type != 'GIRO'
                ELSE true
            END
        )
        AND (
            a.is_active = @is_active
            OR a.id = (
                SELECT c.admin_fee_debit_account_id
                FROM corporate c
                WHERE c.id = @corporate_id
            )
        )
        AND (COALESCE(@search, '') = '' OR a.account_number ILIKE '%' || @search || '%' OR a.account_name ILIKE '%' || @search || '%')
)
SELECT
    *
FROM
    base_query
ORDER BY
    id DESC
LIMIT
    CASE
        WHEN @show_all :: boolean = true THEN NULL
        ELSE @page_limit :: bigint
    END OFFSET CASE
        WHEN @show_all :: boolean = true THEN 0
        ELSE @page_offset :: bigint
    END;

-- name: CountListAccountByCorporateId :one
WITH base_query AS (
    SELECT
        a.*,
        c."name"
    FROM
        account a
        JOIN corporate c ON c.id = a.corporate_id
    WHERE
        corporate_id = @corporate_id
        AND (
            CASE
                WHEN @account_type::text = '' THEN true
                WHEN @account_type::text = 'GIRO' THEN account_type = 'GIRO'
                WHEN @account_type::text = 'OTHER' THEN account_type != 'GIRO'
                ELSE true
            END
        )
        AND (
            a.is_active = @is_active
            OR a.id = (
                SELECT c.admin_fee_debit_account_id
                FROM corporate c
                WHERE c.id = @corporate_id
            )
        )
        AND (COALESCE(@search, '') = '' OR a.account_number ILIKE '%' || @search || '%' OR a.account_name ILIKE '%' || @search || '%')
)
SELECT COUNT(*) AS total_count
FROM base_query;


-- name: IsExistsAccountId :one
SELECT
    EXISTS (
        SELECT
            1
        from
            account a
        where
            a.id = @id
            and a.corporate_id = @corporate_id
            and is_active
    );

-- name: DeleteAccountByCorporateId :exec
DELETE FROM
    account a
where
    a.corporate_id = @corporate_id
    and a.is_active = @is_active
    and a.id != (
        select
            c.admin_fee_debit_account_id
        from
            corporate c
        where
            c.id = @corporate_id
    );

-- name: UpdateAccountStatusByCorporateId :exec
UPDATE
    account a
SET
    is_active = @is_active,
    updated_at = NOW()
WHERE
    a.user_authorization_id = @user_authorization_id
    and a.account_number <> (
        select
            a.account_number
        from
            corporate c
            join account a on a.id = c.admin_fee_debit_account_id
        where
            c.id = @corporate_id
    );

-- name: IsExistsAccount :one
SELECT
    EXISTS (
        SELECT
            1
        from
            account a
        where
            a.account_number = $1
            and a.corporate_id = $2
            and a.is_active = true
    );

-- name: ListTmpAccountByUserAuthorizationId :many
WITH base_query AS (
    select
        a.id, a.user_authorization_id, a.corporate_id, a.account_number, a.account_name, a.account_type, a.ownership, a.accessibility, a.currency, a.maturity, a.break, a.created_by, a.created_at, a.updated_by, a.updated_at,
        c."name"
    from
        account a
        join corporate c on c.id = a.corporate_id
        join user_authorization ua on ua.id = a.user_authorization_id
    where
        a.user_authorization_id = @user_authorization_id
        AND (
            CASE
                WHEN @account_type :: text = '' THEN true
                WHEN @account_type :: text = 'GIRO' THEN account_type = 'GIRO'
                WHEN @account_type :: text = 'OTHER' THEN account_type != 'GIRO'
                ELSE true
            END
        )
)
SELECT
    id, user_authorization_id, corporate_id, account_number, account_name, account_type, ownership, accessibility, currency, maturity, break, created_by, created_at, updated_by, updated_at, name
FROM
    base_query
ORDER BY
    id DESC
LIMIT
    CASE
        WHEN @show_all :: boolean = true THEN NULL
        ELSE @page_limit :: bigint
    END OFFSET CASE
        WHEN @show_all :: boolean = true THEN 0
        ELSE @page_offset :: bigint
    END;

-- name: CountListTmpAccountByUserAuthorizationId :one
WITH base_query AS (
    SELECT
        a.id, a.user_authorization_id, a.corporate_id, a.account_number, a.account_name, a.account_type, a.ownership, a.accessibility, a.currency, a.maturity, a.break, a.created_by, a.created_at, a.updated_by, a.updated_at,
        c."name"
    FROM
        account a
        join corporate c on c.id = a.corporate_id
        join user_authorization ua on ua.id = a.user_authorization_id
    WHERE
        user_authorization_id = @user_authorization_id
        AND (
            CASE
                WHEN @account_type::text = '' THEN true
                WHEN @account_type::text = 'GIRO' THEN account_type = 'GIRO'
                WHEN @account_type::text = 'OTHER' THEN account_type != 'GIRO'
                ELSE true
            END
        )
)
SELECT COUNT(*) AS total_count
FROM base_query;

-- name: DeactivatedAccount :exec
UPDATE
    account a
SET
    is_active = false,
    updated_at = NOW()
WHERE
    a.is_active = true
    and a.corporate_id = @corporate_id
    and a.account_number <> (
        select
            a.account_number
        from
            corporate c
            join account a on a.id = c.admin_fee_debit_account_id
        where
            c.id = @corporate_id
    );

-- name: ActivatedAccount :exec
UPDATE
    account a
SET
    is_active = true,
    updated_at = NOW()
WHERE
    a.user_authorization_id = @user_authorization_id
    and a.account_number <> (
        select
            a.account_number
        from
            corporate c
            join account a on a.id = c.admin_fee_debit_account_id
        where
            c.id = @corporate_id
    );

-- name: DeleteAllAccountByCorporateId :exec
DELETE FROM
    account a
where
    a.corporate_id = @corporate_id
    and a.is_active = @is_active;

-- name: GetAccountById :one
select
    a.*, c.*
from
    account a
left join corporate c on a.corporate_id = c.id
where
    a.corporate_id = @corporate_id
    and a.id = @account_id
    and is_active;
