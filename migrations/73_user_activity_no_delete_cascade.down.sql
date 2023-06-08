ALTER TABLE public.activity
    DROP CONSTRAINT IF EXISTS activity_user_id_fkey;

ALTER TABLE public.activity
    ADD FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE NO ACTION ON DELETE CASCADE;