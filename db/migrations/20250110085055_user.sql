-- migrate:up
CREATE TYPE user_status AS ENUM ('AUTHORIZED', 'ACTIVE', 'LOCKED', 'SUSPENDED');
CREATE TABLE IF NOT EXISTS "user" (
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
    "identity_expired" TIMESTAMPTZ DEFAULT NULL,
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

-- migrate:down
DROP TABLE IF EXISTS "user";
DROP TYPE IF EXISTS user_status;
