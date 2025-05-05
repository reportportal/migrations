UPDATE
    users
SET metadata = jsonb_set(metadata,
                         '{metadata,last_login}', to_jsonb(
                                 round(cast(metadata -> 'metadata' ->> 'last_login' AS NUMERIC))),
                         false)
WHERE metadata -> 'metadata' ->> 'last_login' IS NOT NULL;
