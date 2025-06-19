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

