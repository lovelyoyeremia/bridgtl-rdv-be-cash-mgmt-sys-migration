-- migrate:up
CREATE TABLE IF NOT EXISTS "user_authorization_access" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID NOT NULL,
    "authorization_id" UUID,
    "status" VARCHAR(3) DEFAULT '0',
    "type" VARCHAR(20) NOT NULL,
    "authorization_ip" VARCHAR(20),
    "created_at" TIMESTAMPTZ DEFAULT NOW()
);

-- migrate:down
DROP TABLE IF EXISTS "user_authorization_access"
