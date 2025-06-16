-- migrate:up
CREATE TABLE IF NOT EXISTS  user_approval (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_authorization_id UUID NOT NULL,
    user_id UUID NOT NULL,
    "type" VARCHAR(20) NOT NULL,
    "status" VARCHAR(20) NOT NULL,
    notes VARCHAR(100),
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID,
    CONSTRAINT fk_user_authorization FOREIGN KEY (user_authorization_id) REFERENCES user_authorization(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_created_by FOREIGN KEY (created_by) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- migrate:down
DROP TABLE IF EXISTS user_approval;
