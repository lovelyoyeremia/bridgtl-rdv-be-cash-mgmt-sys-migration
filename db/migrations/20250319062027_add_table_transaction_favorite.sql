-- migrate:up
CREATE TABLE IF NOT EXISTS  transaction_favorite (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR NOT NULL,
    bank_id UUID NULL,
    number VARCHAR(100) NULL,
    transaction_type VARCHAR NOT NULL,
    alias VARCHAR(100),
    corporate_id UUID NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID,
    CONSTRAINT fk_bank FOREIGN KEY (bank_id) REFERENCES bank(id),
    CONSTRAINT fk_created_by FOREIGN KEY (created_by) REFERENCES "user"(id),
    CONSTRAINT fk_corporate FOREIGN KEY (corporate_id) REFERENCES corporate(id),
    CONSTRAINT unique_bank_number UNIQUE (bank_id, number)
);


-- migrate:down
DROP TABLE transaction_favorite;