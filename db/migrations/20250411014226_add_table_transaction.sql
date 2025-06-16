-- migrate:up
CREATE TABLE IF NOT EXISTS transaction (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    corporate_id UUID NOT NULL REFERENCES corporate(id) ON UPDATE CASCADE ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES account(id) ON UPDATE CASCADE ON DELETE CASCADE, 
    dest_acc_no VARCHAR(50),
    dest_acc_name VARCHAR(100),
    amount NUMERIC(20,2),
    transaction_type VARCHAR(50),
    trrefn VARCHAR(50),
    sequence_journal VARCHAR(50),
    remarks TEXT,
    note TEXT,
    core_request_payload jsonb,
    core_response_payload jsonb,
    e_channel_request_payload jsonb,
    e_channel_response_payload jsonb,
    status VARCHAR(20),
    fee NUMERIC(20,2),
    status_code VARCHAR(20),
    seq_no VARCHAR(50),
    dest_bank_code VARCHAR(50),
    trx_successed_at TIMESTAMPTZ,
    icon_menu VARCHAR(50),
    icon    VARCHAR(50),
    additional_data TEXT,
    destination_saku_id UUID,
    destination_saku_type VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- migrate:down
DROP TABLE IF EXISTS transaction;
