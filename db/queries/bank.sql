
-- name: ListBank :many
select
    *
from
    bank b
where
    b.code <> ''
    or b.code is not null
order by
    b.sorting asc;

-- name: FindBank :one
SELECT  * FROM bank WHERE id = $1;

-- name: FindBankByCode :one
SELECT * FROM bank WHERE code = $1;