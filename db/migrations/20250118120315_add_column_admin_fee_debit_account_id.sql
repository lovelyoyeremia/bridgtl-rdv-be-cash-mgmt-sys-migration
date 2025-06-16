-- migrate:up
ALTER TABLE
    corporate
ADD
    COLUMN admin_fee_debit_account_id UUID REFERENCES account (id);

-- migrate:down
ALTER TABLE
    corporate DROP COLUMN IF EXISTS admin_fee_debit_account_id;