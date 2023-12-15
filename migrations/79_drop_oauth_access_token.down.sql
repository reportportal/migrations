CREATE TABLE oauth_access_token (
    id                BIGSERIAL PRIMARY KEY,
    token_id          VARCHAR(255),
    token             BYTEA,
    authentication_id VARCHAR(255),
    username          VARCHAR(255),
    user_id           BIGINT REFERENCES users (id) ON DELETE CASCADE,
    client_id         VARCHAR(255),
    authentication    BYTEA,
    refresh_token     VARCHAR(255),
    CONSTRAINT users_access_token_unique UNIQUE (token_id, user_id)
);

CREATE INDEX oauth_at_user_idx
    ON oauth_access_token (user_id);