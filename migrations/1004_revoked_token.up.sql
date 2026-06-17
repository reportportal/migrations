CREATE TABLE IF NOT EXISTS public.revoked_token (
  id            BIGSERIAL    PRIMARY KEY,
  jti           VARCHAR(36),
  subject       VARCHAR(128),
  revoke_before TIMESTAMPTZ,
  expires_at    TIMESTAMPTZ  NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_revoked_token_jti
  ON public.revoked_token (jti)
  WHERE jti IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_revoked_token_subject_revoke_before
  ON public.revoked_token (subject, revoke_before)
  WHERE subject IS NOT NULL;
