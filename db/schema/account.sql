CREATE TABLE account (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    corporate_id UUID REFERENCES corporate (id),
    account_number VARCHAR(15) NOT NULL UNIQUE,
    account_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(100) NOT NULL,
    ownership VARCHAR(20),
    accessibility VARCHAR(100),
    currency CHAR(3),
    maturity VARCHAR(10),
    "break" CHAR(1),
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    is_active BOOL default true,
    user_authorization_id UUID REFERENCES user_authorization (id)
);