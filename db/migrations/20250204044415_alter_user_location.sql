-- migrate:up
ALTER TABLE user_login
ADD COLUMN device VARCHAR(255),
ADD COLUMN location VARCHAR(255);

-- migrate:down
ALTER TABLE user_login
DROP COLUMN device,
DROP COLUMN location;

