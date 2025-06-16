-- name: GetIconByType :one
SELECT *
FROM icon
WHERE regexp_replace(type, '.*:', '') = sqlc.arg(type)
  AND 
   EXISTS (
  SELECT 1
  FROM unnest(sqlc.arg(name)::text[]) AS name
  WHERE icon.name ILIKE '%' || name || '%'
)
LIMIT 1; 

-- name: GetIconByID :one
SELECT *
FROM icon WHERE id = $1 LIMIT 1;