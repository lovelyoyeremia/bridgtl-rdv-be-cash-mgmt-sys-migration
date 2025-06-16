-- name: ListTransferMethod :many
select
    *
from
    transfer_method tm
where
    tm."type" in ('BIFAST', 'SKN', 'RTGS', 'ONLINE', 'INTERNAL')
order by
    tm.priority;

-- name: GetTransferMethodByType :one
SELECT * FROM transfer_method
WHERE "type" = @type;