-- name: InsertUserAuthorization :one
INSERT INTO
    user_authorization (
        id,
        "type",
        tran_type,
        old_data,
        new_data,
        status,
        description,
        corporate_id,
        maker_id,
        maker_ip
    )
VALUES
    (
        $1,
        $2,
        $3,
        $4,
        $5,
        $6,
        $7,
        $8,
        $9,
        $10
    ) RETURNING id;

