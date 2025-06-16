-- migrate:up
CREATE TABLE IF NOT EXISTS sequence_transfer (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seq_no VARCHAR(20) NOT NULL,
    type VARCHAR(20) NOT NULL,
    amount NUMERIC(20,2) NOT NULL,
    src_acc_no VARCHAR(50) NOT NULL,
    src_acc_name VARCHAR(100) NOT NULL,
    dest_acc_no VARCHAR(50) NOT NULL,
    dest_acc_name VARCHAR(100) NOT NULL,
    bi_fast_purpose_type VARCHAR(50) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    cif_dest VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID NOT NULL,
    updated_by UUID NOT NULL
);
-- migrate:down

DROP TABLE IF EXISTS sequence_transfer;