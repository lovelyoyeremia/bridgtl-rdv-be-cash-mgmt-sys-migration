-- name: InsertUpdateUserLock :one
WITH updated_user_lock AS (
    INSERT INTO user_lock (user_id, count_attempt, status_lock)
    VALUES (@user_id, 1, 'T')
    ON CONFLICT (user_id)
    DO UPDATE SET 
        count_attempt = user_lock.count_attempt + 1,
        last_attempt = NOW(),
        status_lock = CASE 
                    WHEN user_lock.count_attempt + 1 >= 5 THEN 'P' 
                    ELSE 'T' 
                 END
    RETURNING user_id, count_attempt, status_lock
)
UPDATE "user"
SET status = CASE WHEN updated_user_lock.count_attempt >= 5 THEN 'LOCKED'::user_status ELSE 'ACTIVE'::user_status END
FROM updated_user_lock
WHERE "user".id = updated_user_lock.user_id
RETURNING "user".id, "user".status, updated_user_lock.count_attempt;
