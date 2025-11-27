CREATE TABLE tms_attribute
(
    id  BIGSERIAL
        CONSTRAINT tms_attribute_pk PRIMARY KEY,
    key varchar(255) NOT NULL UNIQUE,
    search_vector tsvector
);

CREATE FUNCTION update_tms_attribute_search_vector()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector := to_tsvector('simple', COALESCE(NEW.key, ''));
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tms_attribute_search_vector_trigger
    BEFORE INSERT OR UPDATE ON tms_attribute
                         FOR EACH ROW EXECUTE FUNCTION update_tms_attribute_search_vector();

CREATE INDEX idx_tms_attribute_search_vector ON tms_attribute USING gin (search_vector);

CREATE TABLE tms_product_version
(
    id            BIGSERIAL
        CONSTRAINT tms_product_version_pk PRIMARY KEY,
    documentation varchar(255),
    version       varchar(255),
    project_id    bigint NOT NULL
        CONSTRAINT tms_product_version_fk_project
            REFERENCES project
);

CREATE TYPE tms_dataset_type AS ENUM ('ENVIRONMENTAL', 'PARAMETRIZED');

CREATE TABLE tms_dataset
(
    id         BIGSERIAL
        CONSTRAINT tms_dataset_pk PRIMARY KEY,
    name       varchar(255),
    project_id bigint NOT NULL
        CONSTRAINT tms_dataset_fk_project
            REFERENCES project
);

CREATE TABLE tms_dataset_data
(
    id         BIGSERIAL
        CONSTRAINT tms_dataset_data_pk PRIMARY KEY,
    key        varchar(255),
    value      varchar(255),
    dataset_id bigint NOT NULL
        CONSTRAINT tms_dataset_attribute_fk_tms_dataset
            REFERENCES tms_dataset
);

CREATE TABLE tms_environment
(
    id         BIGSERIAL
        CONSTRAINT tms_environment_pk PRIMARY KEY,
    name       varchar(255),
    project_id bigint NOT NULL
        CONSTRAINT tms_environment_fk_project
            REFERENCES project
);

CREATE TABLE tms_environment_dataset
(
    id             BIGSERIAL
        CONSTRAINT tms_environment_dataset_pk PRIMARY KEY,
    environment_id BIGINT           NOT NULL
        CONSTRAINT tms_environment_dataset_fk_environment
            REFERENCES tms_environment,
    dataset_id     BIGINT           NOT NULL
        CONSTRAINT tms_environment_dataset_fk_dataset
            REFERENCES tms_dataset,
    dataset_type   tms_dataset_type NOT NULL,
    CONSTRAINT tms_environment_dataset_unique UNIQUE (environment_id, dataset_id)
);

CREATE TABLE tms_test_plan
(
    id                 BIGSERIAL
        CONSTRAINT tms_test_plan_pk PRIMARY KEY,
    name               varchar(255),
    description        varchar(255),
    created_at         TIMESTAMP DEFAULT now() NOT NULL,
    updated_at         TIMESTAMP DEFAULT now() NOT NULL,
    search_vector      tsvector,
    project_id         bigint NOT NULL
        CONSTRAINT tms_test_plan_fk_project
            REFERENCES project,
    environment_id     bigint
        CONSTRAINT tms_test_plan_fk_environment
            REFERENCES tms_environment,
    product_version_id bigint
        CONSTRAINT tms_test_plan_fk_product_version
            REFERENCES tms_product_version
);

CREATE FUNCTION update_tms_test_plan_search_vector()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector := to_tsvector('simple',
        COALESCE(NEW.name, '') || ' ' ||
        COALESCE(NEW.description, ''));
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tms_test_plan_search_vector_trigger
    BEFORE INSERT OR UPDATE ON tms_test_plan
                         FOR EACH ROW EXECUTE FUNCTION update_tms_test_plan_search_vector();

CREATE INDEX idx_tms_test_plan_search_vector ON tms_test_plan USING gin (search_vector);

CREATE TABLE tms_milestone
(
    id                 BIGSERIAL
        CONSTRAINT tms_milestone_pk PRIMARY KEY,
    name               varchar(255),
    start_date         TIMESTAMP,
    end_date           TIMESTAMP,
    type               varchar(255),
    -- TODO many to many ?
    product_version_id bigint NOT NULL
        CONSTRAINT tms_milestone_fk_product_version
            REFERENCES tms_product_version,
    -- TODO many to many ?
    test_plan_id       bigint
        CONSTRAINT tms_milestone_fk_test_plan
            REFERENCES tms_test_plan
);

CREATE TABLE tms_test_folder
(
    id          BIGSERIAL
        CONSTRAINT tms_test_folder_pk PRIMARY KEY,
    name        varchar(255) NOT NULL,
    description varchar(255),
    parent_id   bigint
        CONSTRAINT tms_test_folder_fk_parent
            REFERENCES tms_test_folder,
    project_id  bigint NOT NULL
        CONSTRAINT tms_test_folder_fk_project
            REFERENCES project
);

CREATE INDEX idx_tms_test_folder_project_id ON tms_test_folder (project_id, id);

CREATE TABLE tms_test_folder_test_item
(
    id BIGSERIAL PRIMARY KEY,
    name        varchar(255),
    description varchar(255),
    test_folder_id bigint NOT NULL,
    launch_id      bigint NOT NULL,
    test_item_id   bigint NOT NULL
        CONSTRAINT tms_test_folder_test_item_fk_test_item
            REFERENCES test_item
);

CREATE INDEX idx_tms_test_folder_test_item_test_folder_id ON tms_test_folder_test_item (test_folder_id);
CREATE INDEX idx_tms_test_folder_test_item_test_item_id ON tms_test_folder_test_item (test_item_id);

CREATE TABLE tms_test_case
(
    id             BIGSERIAL
        CONSTRAINT tms_test_case_pk PRIMARY KEY,
    created_at     TIMESTAMP DEFAULT now() NOT NULL,
    updated_at     TIMESTAMP DEFAULT now() NOT NULL,
    name           varchar(255),
    description    varchar(255),
    priority       varchar(255),
    search_vector  tsvector,
    external_id    varchar(255),
    test_folder_id bigint NOT NULL
        CONSTRAINT tms_test_case_fk_test_folder
            REFERENCES tms_test_folder,
    dataset_id     bigint
        CONSTRAINT tms_test_case_fk_dataset
            REFERENCES tms_dataset,
    CONSTRAINT tms_test_case_name_folder_unique UNIQUE (name, test_folder_id)
);

CREATE TABLE tms_test_plan_test_case
(
    test_plan_id   bigint
        CONSTRAINT tms_test_plan_test_case_fk_test_plan
            REFERENCES tms_test_plan,
    test_case_id bigint
        CONSTRAINT tms_test_plan_test_case_fk_test_case
            REFERENCES tms_test_case,
    PRIMARY KEY (test_plan_id, test_case_id)
);

CREATE INDEX idx_tms_test_plan_test_case_test_plan_id ON tms_test_plan_test_case (test_plan_id);
CREATE INDEX idx_tms_test_plan_test_case_test_case_id ON tms_test_plan_test_case (test_case_id);

CREATE FUNCTION update_tms_test_case_search_vector()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector := to_tsvector('simple',
        COALESCE(NEW.name, '') || ' ' ||
        COALESCE(NEW.description, '') || ' ' ||
        COALESCE(NEW.priority, ''));
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tms_test_case_search_vector_trigger
    BEFORE INSERT OR UPDATE ON tms_test_case
                         FOR EACH ROW EXECUTE FUNCTION update_tms_test_case_search_vector();

CREATE INDEX idx_tms_test_case_search_vector ON tms_test_case USING gin (search_vector);

CREATE TABLE tms_test_case_version
(
    id           BIGSERIAL
        CONSTRAINT tms_test_case_version_pk PRIMARY KEY,
    name         varchar(255),
    is_default   boolean,
    is_draft     boolean,
    test_case_id bigint NOT NULL
        CONSTRAINT tms_test_case_version_fk_test_case
            REFERENCES tms_test_case
);

CREATE UNIQUE INDEX idx_tms_test_case_version_default
    ON tms_test_case_version (test_case_id)
    WHERE is_default = true;

CREATE TYPE tms_manual_scenario_type AS ENUM ('TEXT', 'STEPS');

CREATE TABLE tms_manual_scenario
(
    id                        BIGSERIAL
        CONSTRAINT tms_manual_scenario_pk PRIMARY KEY,
    execution_estimation_time integer,
    link_to_requirements      varchar(255),
    test_case_version_id      bigint
        UNIQUE
        CONSTRAINT tms_manual_scenario_fk_test_case_version
            REFERENCES tms_test_case_version,
    type                      tms_manual_scenario_type NOT NULL
);

CREATE TABLE tms_manual_scenario_preconditions
(
    id                 BIGSERIAL
        CONSTRAINT tms_manual_scenario_preconditions_pk PRIMARY KEY,
    manual_scenario_id bigint NOT NULL UNIQUE
        CONSTRAINT tms_manual_scenario_preconditions_fk_manual_scenario
            REFERENCES tms_manual_scenario,
    value              varchar(255)
);

CREATE UNIQUE INDEX idx_tms_manual_scenario_preconditions_scenario_unique
    ON tms_manual_scenario_preconditions(manual_scenario_id);

CREATE TABLE tms_text_manual_scenario
(
    manual_scenario_id bigint NOT NULL
        CONSTRAINT tms_text_manual_scenario_pk PRIMARY KEY
        CONSTRAINT tms_text_manual_scenario_fk_manual_scenario
            REFERENCES tms_manual_scenario,
    instructions       varchar(255),
    expected_result    varchar(255)
);

CREATE TABLE tms_steps_manual_scenario
(
    manual_scenario_id bigint NOT NULL
        CONSTRAINT tms_steps_manual_scenario_pk PRIMARY KEY
        CONSTRAINT tms_steps_manual_scenario_fk_manual_scenario
            REFERENCES tms_manual_scenario
);

CREATE INDEX idx_tms_manual_scenario_type ON tms_manual_scenario (type);

CREATE TABLE tms_step
(
    id                       BIGSERIAL
        CONSTRAINT tms_step_pk PRIMARY KEY,
    instructions             varchar(255),
    expected_result          varchar(255),
    steps_manual_scenario_id bigint
        CONSTRAINT tms_step_fk_steps_manual_scenario
            REFERENCES tms_steps_manual_scenario
);

CREATE TABLE tms_step_execution
(
    id BIGSERIAL PRIMARY KEY,
    test_case_execution_id bigint NOT NULL,
    test_item_id   bigint NOT NULL
        CONSTRAINT tms_step_execution_test_item_fk_test_item
            REFERENCES test_item,
    launch_id      bigint NOT NULL,
    tms_step_id     bigint NOT NULL
);

CREATE INDEX idx_tms_step_execution_test_case ON tms_step_execution(test_case_execution_id);
CREATE INDEX idx_tms_step_execution_test_item ON tms_step_execution(test_item_id);
CREATE INDEX idx_tms_step_execution_launch ON tms_step_execution(launch_id);
CREATE INDEX idx_tms_step_execution_tms_step ON tms_step_execution(tms_step_id);

CREATE TABLE tms_attachment
(
    id           BIGSERIAL
        CONSTRAINT tms_attachment_pk PRIMARY KEY,
    file_name    varchar(255) NOT NULL,
    file_type    varchar(255),
    file_size    bigint,
    path_to_file varchar(255) NOT NULL,
    created_at   TIMESTAMP,
    expires_at   TIMESTAMP,
    environment_id                   bigint
        CONSTRAINT tms_attachment_fk_environment
            REFERENCES tms_environment
);

CREATE INDEX idx_tms_attachment_expires_at ON tms_attachment(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX idx_tms_attachment_path ON tms_attachment(path_to_file);

CREATE TABLE tms_step_attachment
(
    step_id       bigint NOT NULL
        CONSTRAINT tms_step_attachment_fk_step
            REFERENCES tms_step,
    attachment_id bigint NOT NULL
        CONSTRAINT tms_step_attachment_fk_attachment
            REFERENCES tms_attachment,
    created_at    TIMESTAMP DEFAULT now() NOT NULL,
    PRIMARY KEY (step_id, attachment_id)
);

CREATE INDEX idx_tms_step_attachment_step_id ON tms_step_attachment(step_id);
CREATE INDEX idx_tms_step_attachment_attachment_id ON tms_step_attachment(attachment_id);

CREATE TABLE tms_text_manual_scenario_attachment
(
    text_manual_scenario_id bigint NOT NULL
        CONSTRAINT tms_text_manual_scenario_attachment_fk_scenario
            REFERENCES tms_text_manual_scenario,
    attachment_id           bigint NOT NULL
        CONSTRAINT tms_text_manual_scenario_attachment_fk_attachment
            REFERENCES tms_attachment,
    created_at              TIMESTAMP DEFAULT now() NOT NULL,
    PRIMARY KEY (text_manual_scenario_id, attachment_id)
);

CREATE INDEX idx_tms_text_manual_scenario_attachment_scenario_id ON tms_text_manual_scenario_attachment(text_manual_scenario_id);
CREATE INDEX idx_tms_text_manual_scenario_attachment_attachment_id ON tms_text_manual_scenario_attachment(attachment_id);

CREATE TABLE tms_manual_scenario_preconditions_attachment
(
    preconditions_id bigint NOT NULL
        CONSTRAINT tms_manual_scenario_preconditions_attachment_fk_preconditions
            REFERENCES tms_manual_scenario_preconditions,
    attachment_id    bigint NOT NULL
        CONSTRAINT tms_manual_scenario_preconditions_attachment_fk_attachment
            REFERENCES tms_attachment,
    created_at       TIMESTAMP DEFAULT now() NOT NULL,
    PRIMARY KEY (preconditions_id, attachment_id)
);

CREATE INDEX idx_preconditions_attachment_preconditions_id ON tms_manual_scenario_preconditions_attachment(preconditions_id);
CREATE INDEX idx_preconditions_attachment_attachment_id ON tms_manual_scenario_preconditions_attachment(attachment_id);

CREATE TABLE tms_manual_scenario_attribute
(
    attribute_id       bigint NOT NULL
        CONSTRAINT tms_manual_scenario_attribute_fk_attribute
            REFERENCES tms_attribute,
    manual_scenario_id bigint NOT NULL
        CONSTRAINT tms_manual_scenario_attribute_fk_manual_scenario
            REFERENCES tms_manual_scenario,
    value              varchar(255),
    PRIMARY KEY (attribute_id, manual_scenario_id)
);

CREATE TABLE tms_test_case_attribute
(
    attribute_id bigint NOT NULL
        CONSTRAINT tms_test_case_attribute_fk_attribute
            REFERENCES tms_attribute,
    test_case_id bigint NOT NULL
        CONSTRAINT tms_test_case_attribute_fk_test_case
            REFERENCES tms_test_case,
    value        varchar(255),
    PRIMARY KEY (attribute_id, test_case_id)
);

CREATE TABLE tms_test_plan_attribute
(
    attribute_id bigint NOT NULL
        CONSTRAINT tms_test_plan_attribute_fk_attribute
            REFERENCES tms_attribute,
    test_plan_id bigint NOT NULL
        CONSTRAINT tms_test_plan_attribute_fk_test_plan
            REFERENCES tms_test_plan,
    value        varchar(255),
    PRIMARY KEY (attribute_id, test_plan_id)
);

CREATE TABLE tms_test_case_execution
(
    id                    BIGSERIAL
        CONSTRAINT tms_test_case_execution_pk PRIMARY KEY,
    test_item_id          bigint UNIQUE
        CONSTRAINT tms_test_case_execution_fk_test_item
            REFERENCES test_item,
    test_case_id          bigint NOT NULL,
    launch_id             bigint NOT NULL,
    test_case_version_id  bigint NOT NULL,
    test_case_snapshot    jsonb NOT NULL
);

CREATE INDEX idx_tms_test_case_execution_test_case_id ON tms_test_case_execution (test_case_id);
CREATE INDEX idx_tms_test_case_execution_test_item_id ON tms_test_case_execution (test_item_id);
CREATE INDEX idx_tms_test_case_execution_launch_id ON tms_test_case_execution (launch_id);
CREATE INDEX idx_tms_test_case_execution_version_id ON tms_test_case_execution (test_case_version_id);
CREATE INDEX idx_tms_test_case_execution_launch_case ON tms_test_case_execution (launch_id, test_case_id);
CREATE INDEX idx_tms_test_case_execution_snapshot ON tms_test_case_execution USING gin (test_case_snapshot);

CREATE TABLE tms_test_case_execution_comment
(
    id           BIGSERIAL
        CONSTRAINT tms_test_case_execution_comment_pk PRIMARY KEY,
    execution_id bigint NOT NULL UNIQUE
        CONSTRAINT tms_test_case_execution_comment_fk_execution
            REFERENCES tms_test_case_execution,
    comment      text,
    bts_ticket_id bigint
);

CREATE INDEX idx_tms_test_case_execution_comment_execution_id ON tms_test_case_execution_comment (execution_id);

CREATE TABLE tms_test_case_execution_comment_attachment
(
    execution_comment_id bigint NOT NULL
        CONSTRAINT tms_test_case_execution_comment_attachment_fk_comment
            REFERENCES tms_test_case_execution_comment,
    attachment_id        bigint NOT NULL
        CONSTRAINT tms_test_case_execution_comment_attachment_fk_attachment
            REFERENCES tms_attachment,
    created_at           TIMESTAMP DEFAULT now() NOT NULL,
    PRIMARY KEY (execution_comment_id, attachment_id)
);

CREATE INDEX idx_tms_execution_comment_attachment_comment_id ON tms_test_case_execution_comment_attachment(execution_comment_id);
CREATE INDEX idx_tms_execution_comment_attachment_attachment_id ON tms_test_case_execution_comment_attachment(attachment_id);

CREATE TYPE LAUNCH_TYPE_ENUM AS ENUM ('AUTOMATION', 'MANUAL');
ALTER TABLE launch
    ADD COLUMN launch_type LAUNCH_TYPE_ENUM;
ALTER TABLE launch
    ALTER COLUMN launch_type SET DEFAULT 'AUTOMATION';
UPDATE launch
SET launch_type = 'AUTOMATION';

ALTER TABLE launch
    ADD COLUMN test_plan_id bigint;

ALTER TYPE filter_condition_enum ADD VALUE IF NOT EXISTS 'FULL_TEXT_SEARCH';
