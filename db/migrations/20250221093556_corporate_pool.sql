-- migrate:up
CREATE TABLE IF NOT EXISTS corporate_group (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(50) NOT NULL,
	created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS corporate_pool (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    corporate_id UUID NOT NULL,
    group_id UUID NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    maintenance_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID DEFAULT NULL,
    CONSTRAINT fk_corporate_id FOREIGN KEY (corporate_id) REFERENCES corporate(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_group_id FOREIGN KEY (group_id) REFERENCES corporate_group(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_created_by FOREIGN KEY (created_by) REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- migrate:down
DROP TABLE IF EXISTS corporate_pool;
DROP TABLE IF EXISTS corporate_group;
