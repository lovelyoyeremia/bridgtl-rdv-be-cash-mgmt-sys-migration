-- migrate:up
CREATE TABLE IF NOT EXISTS user_lock (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    last_attempt TIMESTAMPTZ DEFAULT NOW(),
    count_attempt INT DEFAULT NULL,
    status_lock VARCHAR(1) DEFAULT NULL
);

-- migrate:down
DROP TABLE IF EXISTS user_lock;
