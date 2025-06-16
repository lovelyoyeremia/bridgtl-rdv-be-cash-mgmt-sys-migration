-- migrate:up
ALTER TABLE user_approval
ADD CONSTRAINT user_approval_user_id_unique
UNIQUE (user_authorization_id, user_id);


-- migrate:down
ALTER TABLE user_approval
   DROP CONSTRAINT user_approval_user_id_unique;
