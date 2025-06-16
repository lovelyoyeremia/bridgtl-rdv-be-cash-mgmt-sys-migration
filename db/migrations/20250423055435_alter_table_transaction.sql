-- migrate:up
ALTER TABLE transaction ADD COLUMN user_authorization_id UUID REFERENCES user_authorization (id)  ON UPDATE CASCADE ON DELETE CASCADE;

-- migrate:down
ALTER TABLE transaction DROP COLUMN user_authorization_id;