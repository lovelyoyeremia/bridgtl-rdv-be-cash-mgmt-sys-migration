-- migrate:up
ALTER TABLE user_approval ADD COLUMN ip_address varchar(30);

-- migrate:down
ALTER TABLE user_approval DROP COLUMN ip_address;

