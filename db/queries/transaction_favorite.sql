-- name: InsertTransactionFavorite :one
INSERT INTO
    public.transaction_favorite (
        "name",
        bank_id,
        "number",
        "transaction_type",
        alias,
        corporate_id,
        created_by
    )
VALUES
    (
        $1,
        $2,
        $3,
        $4,
        $5,
        $6,
        $7
    ) RETURNING *;

-- name: GetListTransactionFavorite :many
select
    tf.id,
    tf.name,
    tf.bank_id,
    tf.number,
    tf.transaction_type,
    tf.alias,
    tf.corporate_id,
    tf.created_at,
    tf.created_by,
    b.name as bank_name,
    b.code as bank_code,
    b.icon as bank_icon,
    b.type as bank_type,
    b.skn_code,
    b.rtgs_code,
    b.bi_fast_code,
    b.bi_fast_code_backup
from
    transaction_favorite tf
    join bank b on b.id = tf.bank_id
where
    tf.corporate_id = @corporate_id
    AND (COALESCE(@search, '') = '' OR tf.name ILIKE '%' || @search || '%')
order by
    tf.name desc;

-- name: DeleteTransactionFavorite :exec
DELETE FROM
    transaction_favorite
WHERE
    id = $1;

-- name: GetLatestTransactionFavorite :many
select
    tf.id,
    tf.name,
    tf.bank_id,
    tf.number,
    tf.transaction_type,
    tf.alias,
    tf.corporate_id,
    tf.created_at,
    tf.created_by,
    b.name as bank_name,
    b.code as bank_code,
    b.icon as bank_icon,
    b.type as bank_type,
    b.skn_code,
    b.rtgs_code,
    b.bi_fast_code,
    b.bi_fast_code_backup
from
    transaction_favorite tf
    join bank b on b.id = tf.bank_id
where
    tf.corporate_id = @corporate_id
order by
    tf.created_at desc
LIMIT 5;

-- name: CountTransactionFavorite :one
SELECT
    COUNT(tf.id)
FROM
    transaction_favorite tf
WHERE
    tf.corporate_id = @corporate_id;

-- name: IsExistTransactionFavId :one
SELECT EXISTS (
    SELECT 1
    FROM public.transaction_favorite
    WHERE id = @id
    AND corporate_id = @corporate_id
);