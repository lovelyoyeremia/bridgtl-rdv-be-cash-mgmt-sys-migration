-- migrate:up
ALTER TABLE corporate 
DROP COLUMN IF EXISTS trx_limit_idr, 
DROP COLUMN IF EXISTS trx_limit_valas, 
DROP COLUMN IF EXISTS trx_limit_total, 
ADD COLUMN daily_limit NUMERIC, 
ADD COLUMN transaction_limit NUMERIC;

-- migrate:down
ALTER TABLE corporate 
DROP COLUMN IF EXISTS daily_limit, 
DROP COLUMN IF EXISTS transaction_limit, 
ADD COLUMN trx_limit_idr INT, 
ADD COLUMN trx_limit_valas INT, 
ADD COLUMN trx_limit_total INT;
