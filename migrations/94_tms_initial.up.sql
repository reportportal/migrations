CREATE TABLE tms_attribute
(
    id  BIGSERIAL CONSTRAINT tms_attribute_pk PRIMARY KEY,
    key varchar(255) NOT NULL UNIQUE
);

CREATE TABLE tms_product_version
(
    id            BIGSERIAL CONSTRAINT tms_product_version_pk PRIMARY KEY,
    documentation varchar(255),
    version       varchar(255)
);

CREATE TABLE tms_environment
(
    end_date           timestamp,
    id                 BIGSERIAL CONSTRAINT tms_environment_pk PRIMARY KEY,
    product_version_id bigint NOT NULL
        CONSTRAINT tms_environment_fk_product_version
            REFERENCES tms_product_version,
    start_date         timestamp,
    test_plan_id       bigint,
    name               varchar(255),
    test_data          varchar(255),
    type               varchar(255)
);

CREATE TABLE tms_test_plan
(
    environment_id     bigint NOT NULL
        CONSTRAINT tms_test_plan_fk_environment
            REFERENCES tms_environment,
    id                 BIGSERIAL CONSTRAINT tms_test_plan_pk PRIMARY KEY,
    product_version_id bigint NOT NULL
        CONSTRAINT tms_test_plan_fk_product_version
            REFERENCES tms_product_version,
    description        varchar(255),
    name               varchar(255)
);

ALTER TABLE tms_environment
    ADD CONSTRAINT tms_environment_fk_test_plan
        FOREIGN KEY (test_plan_id) REFERENCES tms_test_plan;

CREATE TABLE tms_test_folder
(
    id          BIGSERIAL CONSTRAINT tms_test_folder_pk PRIMARY KEY,
    parent_id   bigint
        CONSTRAINT tms_test_folder_fk_parent
            REFERENCES tms_test_folder,
    project_id  bigint,
    description varchar(255),
    name        varchar(255)
);

CREATE TABLE tms_test_case
(
    id            BIGSERIAL CONSTRAINT tms_test_case_pk PRIMARY KEY,
    test_folder_id bigint NOT NULL
        CONSTRAINT tms_test_case_fk_test_folder
            REFERENCES tms_test_folder,
    description   varchar(255),
    name          varchar(255)
);

CREATE TABLE tms_test_case_version
(
    is_default   boolean,
    is_draft     boolean,
    id           BIGSERIAL CONSTRAINT tms_test_case_version_pk PRIMARY KEY,
    test_case_id bigint
        CONSTRAINT tms_test_case_version_fk_test_case
            REFERENCES tms_test_case,
    name         varchar(255)
);

CREATE TABLE tms_manual_scenario
(
    execution_estimation_time integer,
    id                        BIGSERIAL CONSTRAINT tms_manual_scenario_pk PRIMARY KEY,
    test_case_version_id      bigint
        UNIQUE
        CONSTRAINT tms_manual_scenario_fk_test_case_version
            REFERENCES tms_test_case_version,
    link_to_requirements      varchar(255),
    preconditions             varchar(255)
);

CREATE TABLE tms_step
(
    id                 BIGSERIAL CONSTRAINT tms_step_pk PRIMARY KEY,
    manual_scenario_id bigint
        CONSTRAINT tms_step_fk_manual_scenario
            REFERENCES tms_manual_scenario,
    expected_result    varchar(255),
    instructions       varchar(255)
);

CREATE TABLE tms_attachment
(
    environment_id bigint
        CONSTRAINT tms_attachment_fk_environment
            REFERENCES tms_environment,
    file_size      bigint,
    id             BIGSERIAL CONSTRAINT tms_attachment_pk PRIMARY KEY,
    step_id        bigint
        CONSTRAINT tms_attachment_fk_step
            REFERENCES tms_step,
    file_name      varchar(255),
    file_type      varchar(255),
    path_to_file   varchar(255)
);

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