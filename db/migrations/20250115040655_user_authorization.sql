-- migrate:up
CREATE TABLE IF NOT EXISTS user_authorization (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "type" VARCHAR(50),
    tran_type VARCHAR(10),
    corporate_id UUID,
    maker_id UUID,
    checker_id UUID,
    signer_id UUID,
    maker_ip VARCHAR(20),
    checker_ip VARCHAR(20),
    signer_ip VARCHAR(20),
    tran_date DATE DEFAULT NOW(),
    check_date DATE,
    sign_date DATE,
    reject_id UUID,
    reject_ip VARCHAR(20),
    reject_date TIMESTAMPTZ,
    old_data TEXT,
    data TEXT,
    status VARCHAR(20),
    description VARCHAR(200)
);


-- migrate:down
DROP TABLE IF EXISTS user_authorization;
