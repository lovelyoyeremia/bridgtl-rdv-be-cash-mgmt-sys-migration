-- migrate:up
ALTER TABLE transfer_method ADD COLUMN fee INT4 NOT NULL DEFAULT 0;

-- migrate:down
ALTER TABLE transfer_method DROP COLUMN fee;
