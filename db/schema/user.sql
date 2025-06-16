CREATE TYPE user_status AS ENUM ('AUTHORIZED', 'ACTIVE', 'LOCKED', 'SUSPENDED');

CREATE TABLE "user" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "corporate_id" UUID NOT NULL,
    "code" VARCHAR(20) NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "password" TEXT NOT NULL,
    "created_by" UUID DEFAULT NULL,
    "created_at" TIMESTAMPTZ DEFAULT NOW(),
    "position" VARCHAR(30) DEFAULT NULL,
    "no_telepon" VARCHAR(20) DEFAULT NULL,
    "no_handphone" VARCHAR(20) DEFAULT NULL,
    "email" VARCHAR(40) DEFAULT NULL,
    "identity_type" VARCHAR(10) DEFAULT NULL,
    "identity_no" VARCHAR(40) DEFAULT NULL,
    "identity_expired" DATE DEFAULT NULL,
    "identity_created_by" VARCHAR(20) DEFAULT NULL,
    "pob" VARCHAR(20) DEFAULT NULL,
    "dob" DATE DEFAULT NULL,
    "address" VARCHAR(200) DEFAULT NULL,
    "mother_name" VARCHAR(40) DEFAULT NULL,
    "restrict_ip" BOOL DEFAULT FALSE,
    "public_ip" VARCHAR(300) DEFAULT NULL,
    "status" user_status DEFAULT NULL,
    "password_list" VARCHAR(200) DEFAULT NULL,
    "last_date_cp" TIMESTAMPTZ DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS "user_authorization_access" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID NOT NULL,
    "authorization_id" UUID,
    "status" VARCHAR(3) DEFAULT '0',
    "type" VARCHAR(20) NOT NULL,
    "authorization_ip" VARCHAR(20),
    "created_at" TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_authorization (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "type" VARCHAR(50),
    tran_type VARCHAR(10),
    corporate_id UUID,
    maker_id UUID,
    maker_ip VARCHAR(20),
    tran_date TIMESTAMPTZ DEFAULT NOW(),
    old_data jsonb,
    new_data jsonb,
    status VARCHAR(20),
    description VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS user_lock (
    user_id UUID NOT NULL,
    last_attempt TIMESTAMPTZ DEFAULT NOW(),
    count_attempt INT DEFAULT NULL,
    status_lock VARCHAR(1) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS user_login (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    login_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    logout_date TIMESTAMPTZ DEFAULT NULL,
    status VARCHAR(3) DEFAULT NULL,
    ip_address VARCHAR(20) DEFAULT NULL,
    device VARCHAR(255) DEFAULT NULL,
    location VARCHAR(255) DEFAULT NULL,
    description VARCHAR(200) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS user_track (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_login_id UUID NOT NULL,
    user_id UUID NOT NULL,
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    current_page VARCHAR(200) DEFAULT NULL
);

