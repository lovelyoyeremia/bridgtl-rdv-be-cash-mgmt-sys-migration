-- migrate:up
ALTER TABLE faq_topic 
ADD COLUMN filepath TEXT;

-- migrate:down
ALTER TABLE faq_topic
   DROP COLUMN filepath;
