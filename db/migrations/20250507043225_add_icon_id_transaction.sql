-- migrate:up
ALTER TABLE transaction 
ADD COLUMN icon_id UUID REFERENCES icon (id) ON UPDATE CASCADE ON DELETE CASCADE,
ADD COLUMN destination_address varchar(50);
-- migrate:down
ALTER TABLE transaction 
DROP COLUMN icon_id,
DROP COLUMN destination_address;