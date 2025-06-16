-- migrate:up
CREATE TABLE IF NOT EXISTS  bank (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	name varchar NULL,
	code varchar NULL,
	icon varchar NULL,
	type varchar NULL,
	skn_code varchar NULL,
	rtgs_code varchar NULL,
    bi_fast_code varchar NULL,
	bi_fast_code_backup varchar NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
	sorting INT4
);

-- migrate:down
DROP TABLE bank;
