-- migrate:up
CREATE TABLE IF NOT EXISTS  transaction_setting (
    id  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    corporate_id UUID REFERENCES corporate (id),
    is_single_bifast_active BOOLEAN NOT NULL DEFAULT FALSE,
    is_single_rtgs_active BOOLEAN NOT NULL DEFAULT FALSE,
    is_single_transfer_online_active BOOLEAN NOT NULL DEFAULT FALSE,
    is_single_skn_active BOOLEAN NOT NULL DEFAULT FALSE,
    is_mass_bifast_active BOOLEAN NOT NULL DEFAULT FALSE,
    is_mass_rtgs_active BOOLEAN NOT NULL DEFAULT FALSE,
    is_mass_transfer_online_active BOOLEAN NOT NULL DEFAULT FALSE,
    is_mass_skn_active BOOLEAN NOT NULL DEFAULT FALSE,
    is_va_active BOOLEAN NOT NULL DEFAULT FALSE,
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by UUID,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- migrate:down
DROP TABLE IF EXISTS transaction_setting;