-- migrate:up
ALTER TABLE
    user_authorization
ALTER COLUMN
    old_data TYPE JSONB USING (old_data :: jsonb);

ALTER TABLE
    user_authorization RENAME COLUMN data TO new_data;

ALTER TABLE
    user_authorization
ALTER COLUMN
    new_data TYPE JSONB USING (new_data :: jsonb);

-- migrate:down
ALTER TABLE
    user_authorization RENAME COLUMN new_data TO data;

ALTER TABLE
    user_authorization
ALTER COLUMN
    old_data TYPE TEXT USING (old_data :: text);

ALTER TABLE
    user_authorization
ALTER COLUMN
    data TYPE TEXT USING (data :: text);