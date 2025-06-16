-- migrate:up
ALTER TABLE transaction ADD COLUMN failure_reason VARCHAR(255);

-- migrate:down
ALTER TABLE transaction DROP COLUMN failure_reason;