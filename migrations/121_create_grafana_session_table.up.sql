CREATE TABLE grafana_session (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS grafana_session_subject_idx ON grafana_session (subject);
CREATE INDEX IF NOT EXISTS grafana_session_expires_at_idx ON grafana_session (expires_at);
