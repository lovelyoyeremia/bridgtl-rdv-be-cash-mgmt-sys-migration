-- name: GetNextSequenceNumber :one
SELECT
    LPAD(nextval('_sequence_serial_seq') :: TEXT, 6, '0') AS seq_no;

-- name: BulkInsertSequenceTransfer :exec
INSERT INTO
    "sequence_transfer" (
        seq_no,
        type,
        amount,
        src_acc_no,
        dest_acc_no,
        src_acc_name,
        dest_acc_name,
        bi_fast_purpose_type,
        transaction_type,
        cif_dest,
        created_at,
        updated_at,
        created_by,
        updated_by
    )
SELECT
    unnest($1 :: text []),
    unnest($2 :: text []),
    unnest($3 :: numeric []),
    unnest($4 :: text []),
    unnest($5 :: text []),
    unnest($6 :: text []),
    unnest($7 :: text []),
    unnest($8 :: text []),
    unnest($9 :: text []),
    unnest($10 :: text []),
    unnest($11 :: timestamptz []),
    unnest($12 :: timestamptz []),
    unnest($13 :: uuid []),
    unnest($14 :: uuid []);