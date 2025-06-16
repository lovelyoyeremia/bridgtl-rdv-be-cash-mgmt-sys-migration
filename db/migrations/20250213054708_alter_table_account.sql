-- migrate:up
ALTER TABLE
    account
ADD
    COLUMN is_active BOOL default true;

-- migrate:down
ALTER TABLE
    account DROP COLUMN is_active;