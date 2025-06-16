-- name: BulkInsertFaq :many
INSERT INTO public."faq" (
  "question",
  "answer",
  "faq_topic_id",
  "faq_sub_topic_id"
) VALUES ( 
  unnest(@question :: text []),
  unnest(@answer :: text []),
  unnest(@faq_topic_id :: uuid []),
  unnest(@faq_sub_topic_id :: uuid [])
) RETURNING id;

-- name: BulkInsertFaqTopic :many
INSERT INTO public."faq_topic" (
  "id",
  "name",
  "description"
) VALUES ( 
  unnest(@id :: uuid []),
  unnest(@name :: text []),
  unnest(@description :: text [])
) RETURNING id;

-- name: BulkInsertFaqSubTopic :many
INSERT INTO public."faq_sub_topic" (
  "name",
  "faq_topic_id"
) VALUES ( 
  unnest(@name :: text []),
  unnest(@faq_topic_id :: uuid [])
) RETURNING id;

-- name: ListFaq :many
SELECT f.*, fs.name FROM public."faq" f
LEFT JOIN faq_sub_topic fs ON f.faq_sub_topic_id = fs.id
ORDER BY created_at DESC
LIMIT $1
OFFSET $2;

-- name: CountListFaq :one
SELECT COUNT(*) FROM public."faq";

-- name: DeleteFaq :one
DELETE FROM public."faq" WHERE id = $1
RETURNING *;

-- name: UpdateFaq :one
UPDATE public."faq"
SET
  question = $1,
  answer = $2
WHERE id = $3
RETURNING id;

-- name: ListFaqTopic :many
SELECT ft.*, fa.name as sub_topic_name, fa.id as sub_topic_id FROM faq_topic ft
LEFT JOIN faq_sub_topic fa ON ft.id = fa.faq_topic_id
LEFT JOIN faq f ON ft.id = f.faq_topic_id
WHERE
  NULLIF(@search, '') IS NULL
  OR LOWER(ft.name) ILIKE '%' || LOWER(@search) || '%'
  OR LOWER(f.question) ILIKE '%' || LOWER(@search) || '%'
  OR LOWER(f.answer) ILIKE '%' || LOWER(@search) || '%'
  OR LOWER(ft.description) ILIKE '%' || LOWER(@search) || '%'
ORDER BY ft.created_at ASC;

-- name: CountListFaqTopic :one
SELECT COUNT(*) FROM faq_topic;

-- name: DetailFaqTopic :one
SELECT * FROM faq_topic WHERE id = $1;

-- name: ListFaqByTopic :many
SELECT f.*, ft.name, ft.description, fst.name as sub_topic_name
FROM faq f
LEFT JOIN faq_topic ft ON f.faq_topic_id = ft.id
LEFT JOIN faq_sub_topic fst ON f.faq_sub_topic_id = fst.id
WHERE f.faq_topic_id = @faq_topic_id;

-- name: UpdateFaqTopic :one
UPDATE faq_topic
  SET 
    name = @name,
    description = @description,
    filepath = @filepath
  WHERE id = @id
RETURNING id;

