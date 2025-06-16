-- migrate:up
CREATE TABLE IF NOT EXISTS public."faq" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "question" VARCHAR(300) NOT NULL,
    "answer" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT NOW(),
    "updated_at" TIMESTAMPTZ DEFAULT NOW()
);

-- migrate:down
DROP TABLE IF EXISTS public."faq";
