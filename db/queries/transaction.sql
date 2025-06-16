-- name: FindAccountByUserCorporate :one
SELECT
  a.*,
  c.*
FROM
  "user" u
  LEFT JOIN corporate c ON c.id = u.corporate_id
  LEFT JOIN account a ON a.corporate_id = c.id
WHERE
  u.id = $1
  AND a.account_number = $2
  AND a.is_active = true;

-- name: FindAccount :one
SELECT
  *
FROM
  account
WHERE
  account_number = $1
  AND corporate_id = $2
  AND is_active = true;

-- name: FindCorporateByUserId :one
SELECT
  c.*
FROM
  "user" u
  LEFT JOIN corporate c ON c.id = u.corporate_id
WHERE
  u.id = $1;

-- name: CalculateDailyTransactionLimit :one
SELECT
  COALESCE(SUM(t.amount)::float8, 0) AS total
FROM
  "transaction" t
  LEFT JOIN corporate c ON c.id = t.corporate_id
WHERE
  t.trx_successed_at :: date = CURRENT_DATE
  AND c.id = @id
  AND t.status = 'SUCCESS';

-- name: InsertTransaction :exec
INSERT INTO
  "transaction" (
    corporate_id,
    account_id,
    dest_acc_no,
    dest_acc_name,
    amount,
    transaction_type,
    trrefn,
    sequence_journal,
    remarks,
    note,
    core_request_payload,
    core_response_payload,
    e_channel_request_payload,
    e_channel_response_payload,
    status,
    fee,
    status_code,
    seq_no,
    dest_bank_code,
    trx_successed_at,
    icon_menu,
    icon,
    icon_id,
    additional_data,
    destination_address,
    destination_saku_id,
    destination_saku_type,
    created_at,
    updated_at,
    user_authorization_id,
    purpose
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
    $11,
    $12,
    $13,
    $14,
    $15,
    $16,
    $17,
    $18,
    $19,
    $20,
    $21,
    $22,
    $23,
    $24,
    $25,
    $26,
    $27,
    $28,
    $29,
    $30,
    $31
  ) RETURNING *;

-- name: FindSequenceTransfer :one
SELECT
  *
FROM
  sequence_transfer
WHERE
  seq_no = $1
  AND src_acc_no = $2
  AND dest_acc_no = $3
  AND amount = $4;

-- name: InsertSequenceTransfer :exec
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
    $11,
    $12,
    $13,
    $14
  ) RETURNING *;

-- name: CheckAccountNumber :one
SELECT
  *
FROM
  account
WHERE
  account_number = $1
  AND is_active = true;

-- name: CheckIsFavorite :one
SELECT
  COUNT(id)
FROM
  transaction_favorite
WHERE
  "number" = $1
  AND bank_id = $2
  AND corporate_id = $3;

-- name: UpdateTransaction :exec
UPDATE
    public."transaction"
SET
    additional_data = COALESCE(@additional_data, additional_data),
    icon_menu = COALESCE(@icon_menu, icon_menu),
    icon = COALESCE(@icon, icon),
    trx_successed_at = COALESCE(@trx_successed_at, trx_successed_at),
    trrefn = COALESCE(@trrefn, trrefn),
    sequence_journal = COALESCE(@sequence_journal, sequence_journal),
    remarks = COALESCE(@remarks, remarks),
    core_request_payload = COALESCE(@core_request_payload, core_request_payload),
    core_response_payload = COALESCE(@core_response_payload, core_response_payload),
    e_channel_request_payload = COALESCE(@e_channel_request_payload, e_channel_request_payload),
    e_channel_response_payload = COALESCE(@e_channel_response_payload, e_channel_response_payload),
    status = COALESCE(@status, status),
    fee = COALESCE(@fee, fee),
    status_code = COALESCE(@status_code, status_code),
    seq_no = COALESCE(@seq_no, seq_no),
    failure_reason = @failure_reason
WHERE
    id = @trx_id;

-- name: ListTransaction :many
SELECT
    ua.id,
    (
    CASE 
      WHEN ua.status = 'APPROVED' 
        AND EXISTS (
          SELECT 1
          FROM user_approval uap
          WHERE uap.user_authorization_id = ua.id
            AND uap.status = 'PENDING'
        )
      THEN 'ON-PROCESS'
      ELSE ua.status
    END
  )::text AS status,
    maker.name as maker_name,
    maker.id as maker_id,
    ua.type,
    (
        SELECT src_bank.name
        FROM bank src_bank
        WHERE src_bank.code = '494'
    ) AS src_bank_name,
    t.trrefn,
    t.remarks,
    i.icon,
    t.transaction_type,
    ua.tran_date
FROM user_authorization ua
INNER JOIN "transaction" t ON t.user_authorization_id = ua.id
INNER JOIN corporate c ON t.corporate_id = c.id
INNER JOIN sequence_transfer st ON st.seq_no = t.seq_no
LEFT JOIN bank b ON b.code = t.dest_bank_code
LEFT JOIN icon i ON i.id = t.icon_id
JOIN "user" maker ON ua.maker_id = maker.id
WHERE t.transaction_type IN (
    'INTERNAL',
    'SKN',
    'RTGS',
    'ONLINE'
    'BIFAST'
)
AND c.code = @corporate_code
AND (sqlc.narg(approval_id)::uuid IS NULL OR ua.id = sqlc.narg(approval_id)::uuid)
AND (
  sqlc.slice('status')::text[] IS NULL

  OR (
    'ON_PROCESS' = ANY(sqlc.slice('status')::text[])
    AND ua.status = 'APPROVED'
    AND EXISTS (
      SELECT 1
      FROM user_approval uap
      WHERE uap.user_authorization_id = ua.id
      AND uap.status = 'PENDING'
    )
  )

  OR (
    'ON_PROCESS' != ALL(sqlc.slice('status')::text[])
    AND ua.status = ANY(sqlc.slice('status')::text[])
  )
)
  AND (
    sqlc.narg(search)::text IS NULL
    OR st.dest_acc_name ILIKE '%' || sqlc.narg(search) || '%'
    OR t.trrefn ILIKE '%' || sqlc.narg(search) || '%'
  )
  AND (
    COALESCE(ARRAY_LENGTH(sqlc.narg(checker_ids)::uuid[], 1), 0) = 0 
    OR EXISTS (
      SELECT 1 
      FROM user_approval uau
      WHERE uau.user_authorization_id = ua.id 
        AND uau.type = 'CHECKER'
        AND uau.user_id = ANY(sqlc.narg(checker_ids)::uuid[])
    )
  )
  AND (
    COALESCE(ARRAY_LENGTH(sqlc.narg(signer_ids)::uuid[], 1), 0) = 0 
    OR EXISTS (
      SELECT 1 
      FROM user_approval uau
      WHERE uau.user_authorization_id = ua.id 
        AND uau.type = 'SIGNER'
        AND uau.user_id = ANY(sqlc.narg(signer_ids)::uuid[])
    )
  )
  AND (
    COALESCE(ARRAY_LENGTH(sqlc.narg(maker_ids)::uuid[], 1), 0) = 0 
    OR EXISTS (
      SELECT 1 
      FROM user_approval uau
      WHERE uau.user_authorization_id = ua.id 
        AND uau.type = 'MAKER'
        AND uau.user_id = ANY(sqlc.narg(maker_ids)::uuid[])
    )
  )
  AND (sqlc.narg(start_date)::timestamp IS NULL OR ua.tran_date >= sqlc.narg(start_date))
  AND (sqlc.narg(end_date)::timestamp IS NULL OR ua.tran_date <= sqlc.narg(end_date))
ORDER BY ua.tran_date DESC
LIMIT sqlc.arg(page_limit) OFFSET sqlc.arg(page_offset);

-- name: CountTransaction :one
SELECT 
COUNT(DISTINCT ua.id)
FROM user_authorization ua
INNER JOIN "transaction" t ON t.user_authorization_id = ua.id
INNER JOIN corporate c ON t.corporate_id = c.id
INNER JOIN sequence_transfer st ON st.seq_no = t.seq_no
LEFT JOIN bank b ON b.code = t.dest_bank_code
WHERE t.transaction_type IN (
    'INTERNAL',
    'SKN',
    'RTGS',
    'ONLINE'
    'BIFAST'
)
AND c.code = @corporate_code
AND (sqlc.narg(approval_id)::uuid IS NULL OR ua.id = sqlc.narg(approval_id)::uuid)
AND (
  sqlc.slice('status')::text[] IS NULL

  OR (
    'ON_PROCESS' = ANY(sqlc.slice('status')::text[])
    AND ua.status = 'APPROVED'
    AND EXISTS (
      SELECT 1
      FROM user_approval uap
      WHERE uap.user_authorization_id = ua.id
      AND uap.status = 'PENDING'
    )
  )

  OR (
    'ON_PROCESS' != ALL(sqlc.slice('status')::text[])
    AND ua.status = ANY(sqlc.slice('status')::text[])
  )
)
  AND (
    sqlc.narg(search)::text IS NULL
    OR ua.id::text = sqlc.narg(search)
    OR st.dest_acc_name ILIKE '%' || sqlc.narg(search) || '%'
  )
  AND (
    COALESCE(ARRAY_LENGTH(sqlc.narg(checker_ids)::uuid[], 1), 0) = 0 
    OR EXISTS (
      SELECT 1 
      FROM user_approval uau
      WHERE uau.user_authorization_id = ua.id 
        AND uau.type = 'CHECKER'
        AND uau.user_id = ANY(sqlc.narg(checker_ids)::uuid[])
    )
  )
  AND (
    COALESCE(ARRAY_LENGTH(sqlc.narg(signer_ids)::uuid[], 1), 0) = 0 
    OR EXISTS (
      SELECT 1 
      FROM user_approval uau
      WHERE uau.user_authorization_id = ua.id 
        AND uau.type = 'SIGNER'
        AND uau.user_id = ANY(sqlc.narg(signer_ids)::uuid[])
    )
  )
  AND (
    COALESCE(ARRAY_LENGTH(sqlc.narg(maker_ids)::uuid[], 1), 0) = 0 
    OR EXISTS (
      SELECT 1 
      FROM user_approval uau
      WHERE uau.user_authorization_id = ua.id 
        AND uau.type = 'MAKER'
        AND uau.user_id = ANY(sqlc.narg(maker_ids)::uuid[])
    )
  )
  AND (sqlc.narg(start_date)::timestamp IS NULL OR ua.tran_date >= sqlc.narg(start_date))
  AND (sqlc.narg(end_date)::timestamp IS NULL OR ua.tran_date <= sqlc.narg(end_date));


-- name: GetDetailTransaction :one
SELECT 
    t.id,
    t.trrefn,
    (
    CASE 
      WHEN ua.status = 'APPROVED' 
        AND EXISTS (
          SELECT 1
          FROM user_approval uap
          WHERE uap.user_authorization_id = ua.id
            AND uap.status = 'PENDING'
        )
      THEN 'ON-PROCESS'
      ELSE ua.status
    END
  )::text AS status,
    t.remarks,
    t.amount,
	  t.fee,
    t.transaction_type,
    t.note,
    t.user_authorization_id,
  -- Subquery: src_bank_name
  (
		SELECT src_bank.name
		FROM bank src_bank
		WHERE src_bank.code = '494'
	) AS src_bank_name,
	maker.name as maker_name,
  maker.id as maker_id,
  st.dest_acc_name,
  st.dest_acc_no,
  st.src_acc_name,
  st.src_acc_no,
	acc.currency,
  dest_bank.name AS dest_bank_name,
  t.created_at
FROM "transaction" t
LEFT JOIN user_authorization ua ON ua.id = t.user_authorization_id
JOIN corporate c ON t.corporate_id = c.id
JOIN sequence_transfer st ON st.seq_no = t.seq_no
JOIN account acc ON t.account_id = acc.id
JOIN "user" maker ON ua.maker_id = maker.id
LEFT JOIN bank dest_bank ON dest_bank.code = t.dest_bank_code
WHERE t.id = @id;


-- name: GetTransactionByApprovalId :many
SELECT 
  t.id,
  t.remarks,
  t.amount,
  t.fee,
  t.user_authorization_id,
  ua.type,
  st.src_acc_name,
  st.src_acc_no,
  st.dest_acc_name,
  st.dest_acc_no,
  maker.name as maker_name,
  maker.id as maker_id,
  (
		SELECT src_bank.name
		FROM bank src_bank
		WHERE src_bank.code = '494'
	) AS src_bank_name,
  b.name as dest_bank_name,
  ua.status,
  t.note,
  acc.currency,
  t.trrefn,
  i.icon,
  t.destination_address,
  t.created_at
FROM "transaction" t
JOIN sequence_transfer st ON st.seq_no = t.seq_no
LEFT JOIN bank b ON b.code = t.dest_bank_code
JOIN user_authorization ua ON t.user_authorization_id = ua.id
JOIN account acc ON t.account_id = acc.id
JOIN "user" maker ON ua.maker_id = maker.id
LEFT JOIN icon i ON i.id = t.icon_id
WHERE t.user_authorization_id = @user_authorization_id;

-- name: GetTransactionByTrrfn :many
SELECT
  t.id,
  t.trrefn,
  ua.status,
  t.remarks,
  t.amount,
	t.fee,
  t.transaction_type,
  t.note,
  t.user_authorization_id,
  t.icon_id,
  -- Subquery: src_bank_name
  (
		SELECT src_bank.name
		FROM bank src_bank
		WHERE src_bank.code = '494'
	) AS src_bank_name,
	maker.name as maker_name,
  maker.id as maker_id,
  st.dest_acc_name,
  st.dest_acc_no,
  st.src_acc_name,
  st.src_acc_no,
	acc.currency,
  dest_bank.name AS dest_bank_name,
  t.created_at
FROM "transaction" t
LEFT JOIN user_authorization ua ON ua.id = t.user_authorization_id
JOIN corporate c ON t.corporate_id = c.id
JOIN sequence_transfer st ON st.seq_no = t.seq_no
JOIN account acc ON t.account_id = acc.id
JOIN "user" maker ON ua.maker_id = maker.id
LEFT JOIN bank dest_bank ON dest_bank.code = t.dest_bank_code
WHERE t.trrefn = ANY(sqlc.narg(trrfns)::text []);

-- name: GetCorporateLatestTransaction :many
SELECT *
FROM (
    SELECT DISTINCT ON (tf.dest_acc_name, tf.dest_acc_no)
        tf.id,
        tf.dest_acc_name,
        tf.dest_bank_code,
        tf.dest_acc_no,
        tf.transaction_type,
        tf.corporate_id,
        tf.created_at,
        tf.trx_successed_at,
        b.name AS bank_name,
        b.code AS bank_code,
        b.icon AS bank_icon,
        b.type AS bank_type,
        b.skn_code,
        b.rtgs_code,
        b.bi_fast_code,
        b.bi_fast_code_backup,
        b.id AS bank_id
    FROM
        transaction tf
        JOIN bank b ON b.code = tf.dest_bank_code 
    WHERE
        tf.corporate_id = @corporate_id
        AND tf.transaction_type = ANY(sqlc.narg(transaction_type)::text [])
        AND (
            COALESCE(@search, '') = ''
            OR tf.dest_acc_name ILIKE '%' || @search || '%'
            OR tf.dest_acc_no ILIKE '%' || @search || '%'
        )
    ORDER BY
        tf.dest_acc_name, tf.dest_acc_no, tf.created_at DESC
) AS sub
ORDER BY sub.created_at DESC
LIMIT 10;

-- name: BulkInsertTransaction :exec
INSERT INTO "transaction" (
  corporate_id,
  account_id,
  dest_acc_no,
  dest_acc_name,
  amount,
  transaction_type,
  trrefn,
  sequence_journal,
  remarks,
  note,
  core_request_payload,
  core_response_payload,
  e_channel_request_payload,
  e_channel_response_payload,
  status,
  fee,
  status_code,
  seq_no,
  dest_bank_code,
  trx_successed_at,
  icon_menu,
  icon,
  icon_id,
  additional_data,
  destination_address,
  destination_saku_id,
  destination_saku_type,
  created_at,
  updated_at,
  user_authorization_id,
  purpose
)
SELECT 
  unnest(@corporate_id::uuid[]),             -- corporate_id
  unnest(@account_id::uuid[]),             -- account_id
  unnest(@dest_acc_no::text[]),             -- dest_acc_no
  unnest(@dest_acc_name::text[]),             -- dest_acc_name
  unnest(@amount::numeric[]),          -- amount
  unnest(@transaction_type::text[]),             -- transaction_type
  unnest(@trrefn::text[]),             -- trrefn
  unnest(@sequence_journal::text[]),             -- sequence_journal
  unnest(@remarks::text[]),             -- remarks
  unnest(@note::text[]),            -- note
  unnest(@core_request_payload::jsonb[]),           -- core_request_payload
  unnest(@core_response_payload::jsonb[]),           -- core_response_payload
  unnest(@e_channel_request_payload::jsonb[]),           -- e_channel_request_payload
  unnest(@e_channel_response_payload::jsonb[]),           -- e_channel_response_payload
  unnest(@status::text[]),            -- status
  unnest(@fee::numeric[]),         -- fee
  unnest(@status_code::text[]),            -- status_code
  unnest(@seq_no::text[]),            -- seq_no
  unnest(@dest_bank_code::text[]),            -- dest_bank_code
  unnest(@trx_successed_at::timestamptz[]),     -- trx_successed_at
  unnest(@icon_menu::text[]),            -- icon_menu
  unnest(@icon::text[]),            -- icon
  unnest(@icon_id::uuid[]),            -- icon_id
  unnest(@additional_data::text[]),            -- additional_data
  unnest(@destination_address::text[]),            -- destination_address
  unnest(@destination_saku_id::uuid[]),            -- destination_saku_id
  unnest(@destination_saku_type::text[]),            -- destination_saku_type
  unnest(@created_at::timestamptz[]),     -- created_at
  unnest(@updated_at::timestamptz[]),     -- updated_at
  unnest(@user_authorization_id::uuid[]),            -- user_authorization_id
  unnest(@purpose::text[])             -- purpose
;

-- name: GetMassTransferTransaction :many
select
    t.*,
    a.account_number as src_acc_no,
    b.*
from
    "transaction" t
    join account a on a.id = t.account_id
    join bank b on b.code = t.dest_bank_code
where
    t.user_authorization_id = @approval_id;

-- name: GetTotalTrxTodayGroupByType :many
SELECT 
  transaction_type,
  SUM(amount) AS total_amount
FROM 
  transaction
WHERE 
  DATE(created_at) = CURRENT_DATE
  AND status = 'SUCCESS'
GROUP BY 
  transaction_type;

-- name: CountDataByStatus :many
SELECT 
  COUNT(CASE WHEN ua.status = 'WAITING-CHECKER' THEN ua.id END) AS review,
  COUNT(CASE WHEN ua.status = 'WAITING-SIGNER' THEN ua.id END) AS approval,
  COUNT(CASE 
           WHEN t.status = 'APPROVED' 
             AND EXISTS (
               SELECT 1
               FROM user_approval uap
               WHERE uap.user_authorization_id = ua.id
                 AND uap.status = 'PENDING'
             )
         THEN ua.id 
       END) AS processed
FROM user_authorization ua
INNER JOIN "transaction" t ON t.user_authorization_id = ua.id
INNER JOIN corporate c ON t.corporate_id = c.id
INNER JOIN sequence_transfer st ON st.seq_no = t.seq_no
LEFT JOIN bank b ON b.code = t.dest_bank_code
WHERE t.transaction_type IN (
    'INTERNAL',
    'SKN',
    'RTGS',
    'ONLINE'
    'BIFAST'
)
AND c.code = @corporate_code
AND (sqlc.narg(approval_id)::uuid IS NULL OR ua.id = sqlc.narg(approval_id)::uuid)
AND (
  sqlc.slice('status')::text[] IS NULL

  OR (
    'ON_PROCESS' = ANY(sqlc.slice('status')::text[])
    AND ua.status = 'APPROVED'
    AND EXISTS (
      SELECT 1
      FROM user_approval uap
      WHERE uap.user_authorization_id = ua.id
      AND uap.status = 'PENDING'
    )
  )

  OR (
    'ON_PROCESS' != ALL(sqlc.slice('status')::text[])
    AND ua.status = ANY(sqlc.slice('status')::text[])
  )
)
  AND (
    sqlc.narg(search)::text IS NULL
    OR ua.id::text = sqlc.narg(search)
    OR st.dest_acc_name ILIKE '%' || sqlc.narg(search) || '%'
  )
  AND (
    COALESCE(ARRAY_LENGTH(sqlc.narg(checker_ids)::uuid[], 1), 0) = 0 
    OR EXISTS (
      SELECT 1 
      FROM user_approval uau
      WHERE uau.user_authorization_id = ua.id 
        AND uau.type = 'CHECKER'
        AND uau.user_id = ANY(sqlc.narg(checker_ids)::uuid[])
    )
  )
  AND (
    COALESCE(ARRAY_LENGTH(sqlc.narg(signer_ids)::uuid[], 1), 0) = 0 
    OR EXISTS (
      SELECT 1 
      FROM user_approval uau
      WHERE uau.user_authorization_id = ua.id 
        AND uau.type = 'SIGNER'
        AND uau.user_id = ANY(sqlc.narg(signer_ids)::uuid[])
    )
  )
  AND (
    COALESCE(ARRAY_LENGTH(sqlc.narg(maker_ids)::uuid[], 1), 0) = 0 
    OR EXISTS (
      SELECT 1 
      FROM user_approval uau
      WHERE uau.user_authorization_id = ua.id 
        AND uau.type = 'MAKER'
        AND uau.user_id = ANY(sqlc.narg(maker_ids)::uuid[])
    )
  )
  AND (sqlc.narg(start_date)::timestamp IS NULL OR ua.tran_date >= sqlc.narg(start_date))
  AND (sqlc.narg(end_date)::timestamp IS NULL OR ua.tran_date <= sqlc.narg(end_date));


-- name: CalculateDailyLimitByTransferMethod :many
SELECT
  t.transaction_type,
  COALESCE(SUM(t.amount)::float8, 0) AS total
FROM
  "transaction" t
  LEFT JOIN corporate c ON c.id = t.corporate_id
WHERE
  t.trx_successed_at :: date = CURRENT_DATE
  AND c.id = @id
  AND t.status = 'SUCCESS'
GROUP BY t.transaction_type;