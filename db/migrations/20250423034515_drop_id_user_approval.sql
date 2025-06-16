-- migrate:up
ALTER TABLE 
  user_authorization
    DROP 
      COLUMN checker_id, 
    DROP 
      COLUMN signer_id, 
    DROP 
      COLUMN reject_id, 
    DROP 
      COLUMN checker_ip, 
    DROP 
      COLUMN signer_ip, 
    DROP 
      COLUMN reject_ip, 
    DROP 
      COLUMN sign_date, 
    DROP 
      COLUMN check_date, 
    DROP 
      COLUMN reject_date;

-- migrate:down
ALTER TABLE 
  user_authorization 
ADD 
  COLUMN checker_id UUID REFERENCES "user"(id), 
ADD 
  COLUMN signer_id UUID REFERENCES "user"(id), 
ADD 
  COLUMN reject_id UUID REFERENCES "user"(id), 
ADD 
  COLUMN checker_ip VARCHAR(20), 
ADD 
  COLUMN signer_ip VARCHAR(20), 
ADD 
  COLUMN reject_ip VARCHAR(20), 
ADD 
  COLUMN sign_date DATE, 
ADD 
  COLUMN check_date DATE, 
ADD 
  COLUMN reject_date DATE;

