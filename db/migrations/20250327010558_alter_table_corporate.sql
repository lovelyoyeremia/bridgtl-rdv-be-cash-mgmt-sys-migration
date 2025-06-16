-- migrate:up
ALTER TABLE "user" 
ALTER COLUMN identity_expired TYPE DATE 
USING identity_expired::DATE;



-- migrate:down
ALTER TABLE "user" 
ALTER COLUMN identity_expired TYPE TIMESTAMPTZ 
USING identity_expired::TIMESTAMPTZ;
