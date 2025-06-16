-- migrate:up
-- Index untuk tabel user_authorization
CREATE INDEX IF NOT EXISTS idx_user_authorization_status ON user_authorization(status);
CREATE INDEX IF NOT EXISTS idx_user_authorization_type ON user_authorization(type);
CREATE INDEX IF NOT EXISTS idx_user_authorization_corporate_id ON user_authorization(corporate_id);
CREATE INDEX IF NOT EXISTS idx_user_authorization_maker_id ON user_authorization(maker_id);
CREATE INDEX IF NOT EXISTS idx_user_authorization_checker_id ON user_authorization(checker_id);
CREATE INDEX IF NOT EXISTS idx_user_authorization_signer_id ON user_authorization(signer_id);
CREATE INDEX IF NOT EXISTS idx_user_authorization_tran_date ON user_authorization(tran_date);

-- Index untuk tabel corporate
CREATE INDEX IF NOT EXISTS idx_corporate_status ON corporate(status);
CREATE INDEX IF NOT EXISTS idx_corporate_created_at ON corporate(created_at);
CREATE INDEX IF NOT EXISTS idx_corporate_name ON corporate(name);

-- Index gabungan untuk kondisi yang sering digunakan bersama
CREATE INDEX IF NOT EXISTS idx_user_auth_status_type ON user_authorization(status, type);
CREATE INDEX IF NOT EXISTS idx_corporate_status_name ON corporate(status, name);

-- Index untuk pencarian partial text pada nama corporate
CREATE INDEX IF NOT EXISTS idx_corporate_name_gin ON corporate USING gin(name gin_trgm_ops);

-- migrate:down
-- Hapus index gabungan dan khusus
DROP INDEX IF EXISTS idx_corporate_name_gin;
DROP INDEX IF EXISTS idx_corporate_status_name;
DROP INDEX IF EXISTS idx_user_auth_status_type;

-- Hapus index pada tabel corporate
DROP INDEX IF EXISTS idx_corporate_name;
DROP INDEX IF EXISTS idx_corporate_created_at;
DROP INDEX IF EXISTS idx_corporate_status;

-- Hapus index pada tabel user_authorization
DROP INDEX IF EXISTS idx_user_authorization_tran_date;
DROP INDEX IF EXISTS idx_user_authorization_signer_id;
DROP INDEX IF EXISTS idx_user_authorization_checker_id;
DROP INDEX IF EXISTS idx_user_authorization_maker_id;
DROP INDEX IF EXISTS idx_user_authorization_corporate_id;
DROP INDEX IF EXISTS idx_user_authorization_type;
DROP INDEX IF EXISTS idx_user_authorization_status;

