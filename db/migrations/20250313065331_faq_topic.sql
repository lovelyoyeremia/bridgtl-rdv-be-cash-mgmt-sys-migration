-- migrate:up
CREATE TABLE IF NOT EXISTS faq_topic (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT NULL,
    "created_at" TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS faq_sub_topic (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "name" VARCHAR(255) NOT NULL,
    "faq_topic_id" UUID NULL,
    CONSTRAINT fk_faq_topic_id FOREIGN KEY (faq_topic_id) REFERENCES faq_topic(id) ON DELETE CASCADE ON UPDATE CASCADE
);
ALTER TABLE faq ADD COLUMN faq_topic_id UUID NULL, ADD CONSTRAINT fk_faq_topic_id FOREIGN KEY (faq_topic_id) REFERENCES faq_topic (id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE faq ADD COLUMN faq_sub_topic_id UUID NULL, ADD CONSTRAINT fk_faq_sub_topic_id FOREIGN KEY (faq_sub_topic_id) REFERENCES faq_sub_topic (id) ON DELETE CASCADE ON UPDATE CASCADE;

-- migrate:down
ALTER TABLE faq 
  DROP CONSTRAINT IF EXISTS fk_faq_topic_id, 
  DROP CONSTRAINT IF EXISTS fk_faq_sub_topic_id, 
  DROP COLUMN IF EXISTS faq_topic_id,
  DROP COLUMN IF EXISTS faq_sub_topic_id;
ALTER TABLE faq_sub_topic DROP CONSTRAINT IF EXISTS fk_faq_topic_id;
DROP TABLE IF EXISTS faq_topic;
DROP TABLE IF EXISTS faq_sub_topic;

