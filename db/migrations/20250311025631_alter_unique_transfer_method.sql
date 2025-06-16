-- migrate:up
ALTER TABLE transfer_method ADD CONSTRAINT unique_type UNIQUE (type);

-- migrate:down
ALTER TABLE transfer_method DROP CONSTRAINT unique_type;
