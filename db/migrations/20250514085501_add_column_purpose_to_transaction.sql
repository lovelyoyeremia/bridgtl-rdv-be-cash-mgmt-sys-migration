-- migrate:up
ALTER TABLE transaction 
ADD COLUMN purpose varchar(100) DEFAULT NULL;
-- migrate:down
ALTER TABLE transaction 
DROP COLUMN purpose;