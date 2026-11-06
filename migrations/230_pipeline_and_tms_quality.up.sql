-- ============================================================================
-- PIPELINE DOMAIN (core.aifactory) — generic pipeline -> iteration -> stage (tree) -> result,
-- independent of launch/test_item. See EPMRPP-118192.
--
-- Facts about a pipeline / iteration / stage / attempt are typed attributes: a JSONB array of
--   {key, value, type: META|TAG|NONE, valueType: TEXT|NUMBER|SCORE|MONEY|DURATION|DATE|LINK|STATUS,
--    label?, description?, url?, order?, direction?, rollup?, comparisonKey?}
-- A status is stored as reported (free text) next to a normalized status_category. What a stage produced
-- is described by attributes and result tables (sections); the raw output a stage reported is kept as received.
-- ============================================================================

CREATE TABLE IF NOT EXISTS pipeline (
    id                   BIGSERIAL PRIMARY KEY,
    project_id           BIGINT NOT NULL REFERENCES project (id) ON DELETE CASCADE,
    name                 VARCHAR(256) NOT NULL,
    type                 VARCHAR(64),
    description          TEXT,
    -- typed facts about the pipeline itself, e.g. its repository
    attributes           JSONB,
    -- settings that behaviour plugged into the pipeline reads, kept as one JSON object,
    -- e.g. {"autoReady": {"enabled": true, "threshold": 90}} for test case Auto-Ready
    settings             JSONB,
    created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS unq_pipeline_project_name ON pipeline (project_id, name);

CREATE TABLE IF NOT EXISTS pipeline_iteration (
    id                    BIGSERIAL PRIMARY KEY,
    pipeline_id           BIGINT NOT NULL REFERENCES pipeline (id) ON DELETE CASCADE,
    iteration_number      INTEGER NOT NULL,
    status                VARCHAR(64) NOT NULL,
    status_category       VARCHAR(16) NOT NULL,
    attributes            JSONB,
    -- derived from attributes on write: lower-cased values for the list search, and one
    -- chr(1) key chr(2) value chr(1) token per attribute for the exact attribute filter
    search_text           TEXT,
    attribute_index       TEXT,
    started_at            TIMESTAMP,
    finished_at           TIMESTAMP,
    rerun                 BOOLEAN NOT NULL DEFAULT FALSE,
    rerun_of_iteration_id BIGINT,
    created_by            BIGINT,
    created_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- idempotent ingest: a retry with the same key and payload gets the iteration created the first
    -- time; the same key with another payload is a conflict. The hash is the SHA-256 hex digest of the
    -- canonical request body.
    idempotency_key       VARCHAR(128),
    idempotency_hash      VARCHAR(64)
);

CREATE UNIQUE INDEX IF NOT EXISTS unq_pipeline_iteration_number ON pipeline_iteration (pipeline_id, iteration_number);
CREATE INDEX IF NOT EXISTS idx_pipeline_iteration_pipeline_id ON pipeline_iteration (pipeline_id);
CREATE UNIQUE INDEX IF NOT EXISTS unq_pipeline_iteration_idempotency_key
    ON pipeline_iteration (pipeline_id, idempotency_key)
    WHERE idempotency_key IS NOT NULL;

-- A stage may nest other stages (a span-like tree), so any business process can be modelled.
-- parent_stage_id and path are maintained in application code, no DB trigger, like test_item.path.
CREATE TABLE IF NOT EXISTS pipeline_stage (
    id                       BIGSERIAL PRIMARY KEY,
    iteration_id             BIGINT NOT NULL REFERENCES pipeline_iteration (id) ON DELETE CASCADE,
    stage_key                VARCHAR(128) NOT NULL,
    name                     VARCHAR(256),
    sequence                 INTEGER NOT NULL,
    -- 1-based number of the stage's current run; finished runs are kept in pipeline_stage_attempt
    attempt                  INTEGER NOT NULL DEFAULT 1,
    parent_stage_id          BIGINT REFERENCES pipeline_stage (id) ON DELETE CASCADE,
    path                     LTREE,
    status                   VARCHAR(64) NOT NULL,
    status_category          VARCHAR(16) NOT NULL,
    -- PIPELINE: reported by the pipeline (e.g. Create, Grade, Upload);
    -- REPORTPORTAL: created and kept up to date by ReportPortal (e.g. a Review stage counting Ready test cases)
    owned_by                 VARCHAR(16) NOT NULL DEFAULT 'PIPELINE',
    affects_iteration_status BOOLEAN NOT NULL DEFAULT TRUE,
    attributes               JSONB,
    -- named result tables {key, title, columns, rows}
    sections                 JSONB,
    -- short text for the stage chip, e.g. "4 cases" or "79"
    summary                  VARCHAR(128),
    -- what the stage is doing or waiting for right now
    message                  VARCHAR(512),
    -- links out of the stage, e.g. [{"type": "RUN", "label": "#78911", "url": "https://ci/job/78911"}] or
    -- [{"type": "ENTITY_LIST", "label": "Open review queue", "target": {"entityType": "TEST_CASE_LIST", "entityId": "iteration=4"}}];
    -- the link to the run is derived from execution and is not stored here
    links                    JSONB,
    -- things elsewhere in ReportPortal the stage worked on or produced, collected from the cell targets of its sections,
    -- e.g. [{"entityType": "TEST_CASE", "entityId": "TC-12"}]
    related_entities         JSONB,
    -- the raw output the stage reported, kept as received (e.g. the grader's output on a Grade stage), and the
    -- name of the schema it had to follow (e.g. 'grade')
    raw_output               JSONB,
    raw_output_schema_name   VARCHAR(128),
    result_type              VARCHAR(64),
    result_ref               VARCHAR(255),
    started_at               TIMESTAMP,
    finished_at              TIMESTAMP,
    -- where and how the stage ran, e.g. {"executorType": "GITHUB_ACTIONS", "externalRunId": "78911",
    -- "runUrl": "https://...", "retryable": true, "retryParameters": {"repo": "org/repo", "workflowRef": "ai.yml"}}
    execution                JSONB,
    last_retried_at          TIMESTAMP,
    last_retried_by          BIGINT
);

CREATE INDEX IF NOT EXISTS idx_pipeline_stage_iteration_id ON pipeline_stage (iteration_id);
CREATE INDEX IF NOT EXISTS idx_pipeline_stage_parent_stage_id ON pipeline_stage (parent_stage_id);
CREATE INDEX IF NOT EXISTS idx_pipeline_stage_path ON pipeline_stage USING GIST (path);

-- Finished runs of a stage, keyed by (iteration, stage_key) rather than by stage id.
CREATE TABLE IF NOT EXISTS pipeline_stage_attempt (
    id              BIGSERIAL PRIMARY KEY,
    iteration_id    BIGINT        NOT NULL REFERENCES pipeline_iteration (id) ON DELETE CASCADE,
    stage_key       VARCHAR(128)  NOT NULL,
    attempt         INTEGER       NOT NULL,
    status          VARCHAR(64)   NOT NULL,
    status_category VARCHAR(16)   NOT NULL,
    started_at      TIMESTAMP     NULL,
    finished_at     TIMESTAMP     NULL,
    execution       JSONB         NULL,
    result_type     VARCHAR(64)   NULL,
    result_ref      VARCHAR(255)  NULL,
    attributes      JSONB         NULL,
    sections        JSONB         NULL,
    recorded_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS unq_pipeline_stage_attempt
    ON pipeline_stage_attempt (iteration_id, stage_key, attempt);

CREATE TABLE IF NOT EXISTS pipeline_stage_test_case (
    id           BIGSERIAL PRIMARY KEY,
    stage_id     BIGINT NOT NULL REFERENCES pipeline_stage (id) ON DELETE CASCADE,
    test_case_id BIGINT NOT NULL REFERENCES tms_test_case (id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_pipeline_stage_test_case_stage_id ON pipeline_stage_test_case (stage_id);
CREATE INDEX IF NOT EXISTS idx_pipeline_stage_test_case_test_case_id ON pipeline_stage_test_case (test_case_id);

-- CI-trigger integration types (group 'AUTOMATION', added by migration 228).
-- Each provider is its own integration type row rather than one generic type
-- with a provider param, mirroring how other integration kinds are modeled.
--
-- Explicit, high ids: a later migration (V001007__integration_type, versioned
-- high so it runs after everything else) seeds 'rally'/'jira'/'signup' via
-- plain auto-increment and other tests hardcode the resulting ids. Letting
-- these two rows consume the next auto-increment values would shift that
-- migration's ids out from under those tests; explicit out-of-range ids avoid
-- the collision without touching the sequence other inserts rely on.
INSERT INTO integration_type (id, enabled, name, creation_date, group_type, plugin_type, details)
VALUES (9000, TRUE, 'github-actions', CURRENT_TIMESTAMP, 'AUTOMATION', 'BUILT_IN', '{"details": {"id": "github-actions", "name": "GitHub Actions"}}')
ON CONFLICT (name) DO NOTHING;

INSERT INTO integration_type (id, enabled, name, creation_date, group_type, plugin_type, details)
VALUES (9001, TRUE, 'gitlab-ci', CURRENT_TIMESTAMP, 'AUTOMATION', 'BUILT_IN', '{"details": {"id": "gitlab-ci", "name": "GitLab CI"}}')
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
    id            BIGSERIAL PRIMARY KEY,
    standard_id   BIGINT NOT NULL REFERENCES tms_quality_standard (id) ON DELETE CASCADE,
    name          VARCHAR(256) NOT NULL,
    max_points    INTEGER NOT NULL,
    sequence      INTEGER NOT NULL,
    -- optional stable key, so graders can report scores by a name that survives renames
    criterion_key VARCHAR(64) NULL
);

CREATE INDEX IF NOT EXISTS idx_tms_quality_standard_criterion_standard_id ON tms_quality_standard_criterion (standard_id);

CREATE UNIQUE INDEX IF NOT EXISTS unq_tms_quality_standard_criterion_key
    ON tms_quality_standard_criterion (standard_id, criterion_key)
    WHERE criterion_key IS NOT NULL;

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
