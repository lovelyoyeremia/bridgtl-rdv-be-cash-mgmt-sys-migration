-- migrate:up
CREATE TABLE IF NOT EXISTS user_login (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    login_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    logout_date TIMESTAMPTZ DEFAULT NULL,
    status VARCHAR(3) DEFAULT NULL,
    ip_address VARCHAR(20) DEFAULT NULL,
    description VARCHAR(200) DEFAULT NULL
);

-- migrate:down
DROP TABLE IF EXISTS user_login;
