-- ============================================================================
-- PIPELINE DOMAIN (core.aifactory) — AI-agent pipeline iterations and stages,
-- independent of launch/test_item. See EPMRPP-118192.
-- ============================================================================

CREATE TABLE IF NOT EXISTS pipeline (
    id                   BIGSERIAL PRIMARY KEY,
    project_id           BIGINT NOT NULL REFERENCES project (id) ON DELETE CASCADE,
    name                 VARCHAR(256) NOT NULL,
    description          TEXT,
    skill                VARCHAR(256),
    auto_ready_enabled   BOOLEAN NOT NULL DEFAULT FALSE,
    auto_ready_threshold INTEGER,
    created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS unq_pipeline_project_name ON pipeline (project_id, name);

CREATE TABLE IF NOT EXISTS pipeline_iteration (
    id                    BIGSERIAL PRIMARY KEY,
    pipeline_id           BIGINT NOT NULL REFERENCES pipeline (id) ON DELETE CASCADE,
    iteration_number      INTEGER NOT NULL,
    status                VARCHAR(32) NOT NULL,
    quality_gate          VARCHAR(32),
    metrics               JSONB,
    trigger               VARCHAR(512),
    started_at            TIMESTAMP,
    finished_at           TIMESTAMP,
    rerun                 BOOLEAN NOT NULL DEFAULT FALSE,
    rerun_of_iteration_id BIGINT,
    created_by            BIGINT,
    created_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS unq_pipeline_iteration_number ON pipeline_iteration (pipeline_id, iteration_number);
CREATE INDEX IF NOT EXISTS idx_pipeline_iteration_pipeline_id ON pipeline_iteration (pipeline_id);

CREATE TABLE IF NOT EXISTS pipeline_stage (
    id              BIGSERIAL PRIMARY KEY,
    iteration_id    BIGINT NOT NULL REFERENCES pipeline_iteration (id) ON DELETE CASCADE,
    stage_key       VARCHAR(128) NOT NULL,
    name            VARCHAR(256),
    short_name      VARCHAR(64),
    sequence        INTEGER NOT NULL,
    agent           VARCHAR(256),
    status          VARCHAR(32) NOT NULL,
    metrics         JSONB,
    graders         JSONB,
    note            TEXT,
    ci_provider     VARCHAR(32),
    ci_repo         VARCHAR(512),
    ci_workflow_ref VARCHAR(512),
    ci_run_id       VARCHAR(128),
    ci_job_id       VARCHAR(128),
    ci_run_url      VARCHAR(1024),
    retryable       BOOLEAN NOT NULL DEFAULT FALSE,
    last_retried_at TIMESTAMP,
    last_retried_by BIGINT
);

CREATE INDEX IF NOT EXISTS idx_pipeline_stage_iteration_id ON pipeline_stage (iteration_id);

CREATE TABLE IF NOT EXISTS pipeline_stage_test_case (
    id           BIGSERIAL PRIMARY KEY,
    stage_id     BIGINT NOT NULL REFERENCES pipeline_stage (id) ON DELETE CASCADE,
    test_case_id BIGINT NOT NULL REFERENCES tms_test_case (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_pipeline_stage_test_case_stage_id ON pipeline_stage_test_case (stage_id);
CREATE INDEX IF NOT EXISTS idx_pipeline_stage_test_case_test_case_id ON pipeline_stage_test_case (test_case_id);

-- CI-trigger integration types (group 'AUTOMATION', added by migration 225).
-- Each provider is its own integration type row rather than one generic type
-- with a provider param, mirroring how other integration kinds are modeled.
INSERT INTO integration_type (enabled, name, creation_date, group_type, plugin_type, details)
VALUES (TRUE, 'github-actions', CURRENT_TIMESTAMP, 'AUTOMATION', 'BUILT_IN', '{"details": {"id": "github-actions", "name": "GitHub Actions"}}')
ON CONFLICT (name) DO NOTHING;

INSERT INTO integration_type (enabled, name, creation_date, group_type, plugin_type, details)
VALUES (TRUE, 'gitlab-ci', CURRENT_TIMESTAMP, 'AUTOMATION', 'BUILT_IN', '{"details": {"id": "gitlab-ci", "name": "GitLab CI"}}')
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- TMS LAYER B: origin/status lifecycle on tms_test_case
-- ============================================================================

ALTER TABLE tms_test_case
    ADD COLUMN IF NOT EXISTS origin VARCHAR(16) NOT NULL DEFAULT 'MANUAL',
    ADD COLUMN IF NOT EXISTS status VARCHAR(16) NOT NULL DEFAULT 'READY';

-- updated_at lets Layer B detect an AI quality score gone stale: a score is
-- obsolete once the version it graded was modified after evaluatedAt.
ALTER TABLE tms_test_case_version
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- ============================================================================
-- TMS QUALITY STANDARD (one per project, MVP — no versioning yet)
-- ============================================================================

CREATE TABLE IF NOT EXISTS tms_quality_standard (
    id          BIGSERIAL PRIMARY KEY,
    project_id  BIGINT NOT NULL REFERENCES project (id) ON DELETE CASCADE,
    name        VARCHAR(256) NOT NULL,
    description TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS unq_tms_quality_standard_project ON tms_quality_standard (project_id);

CREATE TABLE IF NOT EXISTS tms_quality_standard_criterion (
    id          BIGSERIAL PRIMARY KEY,
    standard_id BIGINT NOT NULL REFERENCES tms_quality_standard (id) ON DELETE CASCADE,
    name        VARCHAR(256) NOT NULL,
    max_points  INTEGER NOT NULL,
    sequence    INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_tms_quality_standard_criterion_standard_id ON tms_quality_standard_criterion (standard_id);

-- ============================================================================
-- Per-version AI quality score + generation metadata
-- (attach to tms_test_case_version, not tms_test_case: a score belongs to the
-- scenario content that earned it, and a new version naturally makes an old
-- score obsolete since it's no longer found for the current version.)
-- ============================================================================

CREATE TABLE IF NOT EXISTS tms_test_case_quality_score (
    id                    BIGSERIAL PRIMARY KEY,
    test_case_version_id  BIGINT NOT NULL REFERENCES tms_test_case_version (id) ON DELETE CASCADE,
    criterion_id          BIGINT NOT NULL REFERENCES tms_quality_standard_criterion (id) ON DELETE CASCADE,
    score                 INTEGER NOT NULL,
    evaluated_at          TIMESTAMP NOT NULL,
    pipeline_iteration_id BIGINT
);

CREATE INDEX IF NOT EXISTS idx_tms_test_case_quality_score_version_id ON tms_test_case_quality_score (test_case_version_id);

CREATE TABLE IF NOT EXISTS tms_test_case_generation_metadata (
    id                    BIGSERIAL PRIMARY KEY,
    test_case_version_id  BIGINT NOT NULL REFERENCES tms_test_case_version (id) ON DELETE CASCADE,
    tokens_in             INTEGER,
    tokens_out            INTEGER,
    model                 VARCHAR(128),
    skill                 VARCHAR(256),
    cost_usd              NUMERIC(12, 4)
);

CREATE UNIQUE INDEX IF NOT EXISTS unq_tms_test_case_generation_metadata_version ON tms_test_case_generation_metadata (test_case_version_id);
