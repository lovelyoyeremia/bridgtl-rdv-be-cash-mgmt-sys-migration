-- migrate:up
CREATE TABLE IF NOT EXISTS corporate (
    id  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(10) NOT NULL, -- owner / client
    business_group_type VARCHAR(20), -- kelompok usaha
    business_sector VARCHAR(50), -- bidang usaha
    legal_status VARCHAR(20), -- jenis perusahaan
    establishment_place VARCHAR(20), -- tempat pendirian
    license_type VARCHAR(20), -- jenis dokumen legalitas
    license_number VARCHAR(50), -- nomor dokumen legalitas
    license_issue_date DATE, -- tgl diterbitkan dokumen legalitas
    license_expiry_date DATE, -- tgl kedaluarsa dokumen legalitas
    establishment_deed_number VARCHAR(50), -- nomor akta pendirian
    establishment_deed_date DATE,  -- tgl akta pendirian
    amendment_deed_number VARCHAR(50),  -- nomor akta perubahan
    amendment_deed_date DATE,  -- tgl akta pendirian
    npwp VARCHAR(20),
    cif VARCHAR(20),
    address TEXT,
    address_postal_code VARCHAR(6), -- kode pos
    address_village VARCHAR(40) NOT NULL, -- desa / kelurahan
    address_sub_district VARCHAR(40), -- kecamatan 
    address_city VARCHAR(40), -- kabupaten / kota
    address_province VARCHAR(40), -- provinsi
    phone_number VARCHAR(20),
    fax VARCHAR(20),
    email VARCHAR(50),
    additional_notes TEXT,
    trx_limit_idr INT,
    trx_limit_valas INT,
    trx_limit_total INT,
    max_user_count SMALLINT,
    booking_office_code VARCHAR(40),
    initiator_personal_number VARCHAR(40), -- pn pemrakarsa
    initiator_name VARCHAR(15), -- nama pemrakarsa
    initiator_work_unit VARCHAR(100), -- unit kerja pemrakarsa
    status VARCHAR(20),
    abonemen_code VARCHAR(30),
    customer_number VARCHAR(10),
    approval_type VARCHAR(10) DEFAULT 'SINGLE',
    approval_checker_count SMALLINT DEFAULT 1 NOT NULL,
    approval_signer_count SMALLINT DEFAULT 1 NOT NULL,
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by UUID,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- migrate:down
DROP TABLE IF EXISTS corporate;

