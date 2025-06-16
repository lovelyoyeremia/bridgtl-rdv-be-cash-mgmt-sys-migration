-- migrate:up
ALTER TABLE account ADD COLUMN user_authorization_id UUID REFERENCES user_authorization (id);

-- migrate:down
ALTER TABLE account DROP COLUMN user_authorization_id;