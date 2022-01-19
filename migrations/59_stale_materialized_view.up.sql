CREATE TABLE stale_materialized_view
(
    id            BIGSERIAL PRIMARY KEY,
    name          TEXT UNIQUE NOT NULL,
    creation_date TIMESTAMP   NOT NULL
);

CREATE INDEX stale_mv_creation_date_idx ON stale_materialized_view (creation_date);