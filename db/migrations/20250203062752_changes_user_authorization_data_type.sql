-- migrate:up
ALTER TABLE
    user_authorization
ALTER COLUMN
    tran_date TYPE TIMESTAMPTZ USING tran_date :: TIMESTAMPTZ,
ALTER COLUMN
    check_date TYPE TIMESTAMPTZ USING check_date :: TIMESTAMPTZ,
ALTER COLUMN
    sign_date TYPE TIMESTAMPTZ USING sign_date :: TIMESTAMPTZ;

-- migrate:down
ALTER TABLE
    user_authorization
ALTER COLUMN
    tran_date TYPE DATE USING tran_date :: DATE,
ALTER COLUMN
    check_date TYPE DATE USING check_date :: DATE,
ALTER COLUMN
    sign_date TYPE DATE USING sign_date :: DATE;