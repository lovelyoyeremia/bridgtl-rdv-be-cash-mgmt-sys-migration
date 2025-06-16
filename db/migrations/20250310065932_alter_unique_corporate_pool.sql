-- migrate:up
ALTER TABLE corporate_pool ADD CONSTRAINT unique_corporate_id UNIQUE (corporate_id);

-- migrate:down
ALTER TABLE corporate_pool DROP CONSTRAINT unique_corporate_id;
