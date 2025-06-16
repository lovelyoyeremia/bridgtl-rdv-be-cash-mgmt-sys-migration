CREATE TABLE user_approval (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_authorization_id UUID NOT NULL,
    user_id UUID NOT NULL,
    "type" VARCHAR(20) NOT NULL,
    "status" VARCHAR(20) NOT NULL,
    notes VARCHAR(100),
    ip_address VARCHAR(30),
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID,
    CONSTRAINT fk_user_authorization FOREIGN KEY (user_authorization_id) REFERENCES user_authorization(id),
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES "user"(id),
    CONSTRAINT fk_created_by FOREIGN KEY (created_by) REFERENCES "user"(id)
);
