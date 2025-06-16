-- migrate:up
ALTER TABLE "user" ADD CONSTRAINT fk_corporate FOREIGN KEY (corporate_id) REFERENCES corporate (id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "user" ADD CONSTRAINT fk_created_by FOREIGN KEY (created_by) REFERENCES "user" (id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE user_authorization_access ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES "user" (id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE user_authorization_access ADD CONSTRAINT fk_authorization_id FOREIGN KEY (authorization_id) REFERENCES user_authorization (id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE user_authorization ADD CONSTRAINT fk_corporate_id FOREIGN KEY (corporate_id) REFERENCES corporate (id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE user_authorization ADD CONSTRAINT fk_maker_id FOREIGN KEY (maker_id) REFERENCES "user" (id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE user_authorization ADD CONSTRAINT fk_checker_id FOREIGN KEY (checker_id) REFERENCES "user" (id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE user_authorization ADD CONSTRAINT fk_signer_id FOREIGN KEY (signer_id) REFERENCES "user" (id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE user_authorization ADD CONSTRAINT fk_reject_id FOREIGN KEY (reject_id) REFERENCES "user" (id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE user_lock ADD CONSTRAINT fk_user_id_lock FOREIGN KEY (user_id) REFERENCES "user" (id) ON DELETE CASCADE ON UPDATE CASCADE;

-- migrate:down
ALTER TABLE user_lock DROP CONSTRAINT IF EXISTS fk_user_id_lock;

ALTER TABLE user_authorization DROP CONSTRAINT IF EXISTS fk_reject_id;
ALTER TABLE user_authorization DROP CONSTRAINT IF EXISTS fk_signer_id;
ALTER TABLE user_authorization DROP CONSTRAINT IF EXISTS fk_checker_id;
ALTER TABLE user_authorization DROP CONSTRAINT IF EXISTS fk_maker_id;
ALTER TABLE user_authorization DROP CONSTRAINT IF EXISTS fk_corporate_id;

ALTER TABLE user_authorization_access DROP CONSTRAINT IF EXISTS fk_authorization_id;
ALTER TABLE user_authorization_access DROP CONSTRAINT IF EXISTS fk_user_id;

ALTER TABLE "user" DROP CONSTRAINT IF EXISTS fk_created_by;
ALTER TABLE "user" DROP CONSTRAINT IF EXISTS fk_corporate;
