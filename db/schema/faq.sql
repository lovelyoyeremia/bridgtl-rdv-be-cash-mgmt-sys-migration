CREATE TABLE "faq" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "faq_topic_id" UUID NULL,
    "faq_sub_topic_id" UUID NULL,
    "question" VARCHAR(300) NOT NULL,
    "answer" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT NOW(),
    "updated_at" TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_faq_topic_id FOREIGN KEY (faq_topic_id) REFERENCES faq_topic(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_faq_sub_topic_id FOREIGN KEY (faq_sub_topic_id) REFERENCES faq_sub_topic(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE faq_topic (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT NULL,
    "filepath" TEXT NULL,
    "created_at" TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE faq_sub_topic (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "name" VARCHAR(255) NOT NULL,
    "faq_topic_id" UUID NULL,
    CONSTRAINT fk_faq_topic_id FOREIGN KEY (faq_topic_id) REFERENCES faq_topic(id) ON DELETE CASCADE ON UPDATE CASCADE
);
