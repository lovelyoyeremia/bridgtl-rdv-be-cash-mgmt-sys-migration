-- migrate:up
ALTER TABLE
    corporate
ADD
    COLUMN business_entity_type varchar(50);

-- migrate:down
ALTER TABLE
    corporate DROP COLUMN business_entity_type;