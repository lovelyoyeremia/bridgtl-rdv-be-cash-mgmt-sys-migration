CREATE TABLE transaction_favorite (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR NOT NULL,
    bank_id UUID NULL REFERENCES "bank"(id),
    number VARCHAR(100) NULL,
    transaction_type VARCHAR NOT NULL,
    alias VARCHAR(100),
    corporate_id UUID NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID
);