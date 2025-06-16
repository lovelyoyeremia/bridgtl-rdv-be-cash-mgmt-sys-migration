-- migrate:up
CREATE TABLE IF NOT EXISTS  transfer_method (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	name VARCHAR NOT NULL,
	status VARCHAR NOT NULL,
	transaction_limit INT4 NOT NULL DEFAULT 0,
	daily_limit INT4 NOT NULL DEFAULT 0,
    transaction_min_limit INT4 NOT NULL DEFAULT 0,
	type VARCHAR NULL,
	is_new_feature BOOL NOT NULL DEFAULT false,
	desc1 VARCHAR NULL,
	desc2 VARCHAR NULL,
	desc3 VARCHAR NULL,
	open_hour INT4 DEFAULT 0 NOT NULL,
	close_hour INT4 DEFAULT 23 NOT NULL,
	priority INT2 DEFAULT 0 NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- migrate:down
DROP TABLE transfer_method;

