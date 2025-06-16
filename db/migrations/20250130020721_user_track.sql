-- migrate:up
CREATE TABLE IF NOT EXISTS user_track (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_login_id UUID UNIQUE NOT NULL,
    user_id UUID NOT NULL,
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    current_page VARCHAR(200) DEFAULT NULL,
    CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES "user" (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_user_login_id FOREIGN KEY (user_login_id) REFERENCES user_login (id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- migrate:down
DROP TABLE IF EXISTS user_track;
