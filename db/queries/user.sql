-- name: InsertUser :one
INSERT INTO
    public."user" (
    "id",
    "corporate_id",
    "code",
    "name",
    "password",
    "created_by",
    "position",
    "no_telepon",
    "no_handphone",
    "email",
    "identity_type",
    "identity_no",
    "identity_expired",
    "identity_created_by",
    "pob",
    "dob",
    "address",
    "mother_name",
    "restrict_ip",
    "public_ip",
    "status",
    "password_list",
    "created_at"
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
        $10,
        $11,
        $12,
        $13,
        $14,
        $15,
        $16,
        $17,
        $18,
        $19,
        $20,
        $21,
        $22,
        now()
) RETURNING *;

