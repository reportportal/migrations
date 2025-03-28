CREATE TABLE tms_attribute
(
    id  BIGSERIAL CONSTRAINT tms_attribute_pk PRIMARY KEY,
    key varchar(255) NOT NULL UNIQUE
);

CREATE TABLE tms_product_version
(
    id            BIGSERIAL CONSTRAINT tms_product_version_pk PRIMARY KEY,
    documentation varchar(255),
    version       varchar(255),
    project_id bigint NOT NULL
        CONSTRAINT tms_product_version_fk_project
            REFERENCES project
);

CREATE TABLE tms_dataset
(
    id BIGSERIAL CONSTRAINT tms_dataset_pk PRIMARY KEY,
    name varchar(255),
    project_id bigint NOT NULL
        CONSTRAINT tms_dataset_fk_project
            REFERENCES project
);

CREATE TABLE tms_dataset_data
(
    id BIGSERIAL CONSTRAINT tms_dataset_data_pk PRIMARY KEY,
    key varchar(255),
    value varchar(255),
    dataset_id bigint NOT NULL
        CONSTRAINT tms_dataset_attribute_fk_tms_dataset
            REFERENCES tms_dataset
);

CREATE TABLE tms_environment
(
    id BIGSERIAL CONSTRAINT tms_environment_pk PRIMARY KEY,
    name varchar(255),
    project_id bigint NOT NULL
        CONSTRAINT tms_environment_fk_project
            REFERENCES project
);

CREATE TABLE tms_environment_dataset
(
    id BIGSERIAL CONSTRAINT tms_environment_dataset_pk PRIMARY KEY,
    environment_id BIGINT NOT NULL
        CONSTRAINT tms_environment_dataset_fk_environment
            REFERENCES tms_environment,
    dataset_id BIGINT NOT NULL
        CONSTRAINT tms_environment_dataset_fk_dataset
            REFERENCES tms_dataset,
    dataset_type varchar(255) NOT NULL,
    CONSTRAINT tms_environment_dataset_unique UNIQUE (environment_id, dataset_id)
);

CREATE TABLE tms_test_plan
(
    id BIGSERIAL CONSTRAINT tms_test_plan_pk PRIMARY KEY,
    name varchar(255),
    description varchar(255),
    project_id bigint NOT NULL
        CONSTRAINT tms_test_plan_fk_project
            REFERENCES project,
    environment_id bigint NOT NULL
        CONSTRAINT tms_test_plan_fk_environment
            REFERENCES tms_environment,
    product_version_id bigint NOT NULL
        CONSTRAINT tms_test_plan_fk_product_version
            REFERENCES tms_product_version
);

CREATE TABLE tms_milestone
(
    id BIGSERIAL CONSTRAINT tms_milestone_pk PRIMARY KEY,
    name varchar(255),
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    type varchar(255),
    -- TODO many to many ?
    product_version_id bigint NOT NULL
        CONSTRAINT tms_milestone_fk_product_version
            REFERENCES tms_product_version,
    -- TODO many to many ?
    test_plan_id bigint
        CONSTRAINT tms_milestone_fk_test_plan
            REFERENCES tms_test_plan
);

CREATE TABLE tms_test_folder
(
    id          BIGSERIAL CONSTRAINT tms_test_folder_pk PRIMARY KEY,
    name        varchar(255),
    description varchar(255),
    parent_id   bigint
        CONSTRAINT tms_test_folder_fk_parent
            REFERENCES tms_test_folder,
    project_id bigint NOT NULL
        CONSTRAINT tms_test_folder_fk_project
            REFERENCES project
);

CREATE TABLE tms_test_plan_test_folder
(
    test_plan_id bigint
        CONSTRAINT tms_test_plan_test_folder_fk_test_plan
            REFERENCES tms_test_plan,
    test_folder_id bigint
        CONSTRAINT tms_test_plan_test_folder_fk_test_folder
            REFERENCES tms_test_folder,
    PRIMARY KEY (test_plan_id, test_folder_id)
);

CREATE TABLE tms_test_case
(
    id            BIGSERIAL CONSTRAINT tms_test_case_pk PRIMARY KEY,
    name          varchar(255),
    description   varchar(255),
    test_folder_id bigint NOT NULL
        CONSTRAINT tms_test_case_fk_test_folder
            REFERENCES tms_test_folder,
    dataset_id bigint
        CONSTRAINT tms_test_case_fk_dataset
            REFERENCES tms_dataset
);

CREATE TABLE tms_test_case_version
(
    id           BIGSERIAL CONSTRAINT tms_test_case_version_pk PRIMARY KEY,
    name         varchar(255),
    is_default   boolean,
    is_draft     boolean,
    test_case_id bigint
        CONSTRAINT tms_test_case_version_fk_test_case
            REFERENCES tms_test_case
);

CREATE TABLE tms_manual_scenario
(
    id                        BIGSERIAL CONSTRAINT tms_manual_scenario_pk PRIMARY KEY,
    execution_estimation_time integer,
    link_to_requirements      varchar(255),
    preconditions             varchar(255),
    test_case_version_id      bigint
        UNIQUE
        CONSTRAINT tms_manual_scenario_fk_test_case_version
            REFERENCES tms_test_case_version
);

CREATE TABLE tms_step
(
    id                 BIGSERIAL CONSTRAINT tms_step_pk PRIMARY KEY,
    instructions       varchar(255),
    expected_result    varchar(255),
    manual_scenario_id bigint
        CONSTRAINT tms_step_fk_manual_scenario
            REFERENCES tms_manual_scenario
);

CREATE TABLE tms_attachment
(
    id             BIGSERIAL CONSTRAINT tms_attachment_pk PRIMARY KEY,
    file_name      varchar(255),
    file_type      varchar(255),
    file_size      bigint,
    path_to_file   varchar(255),
    environment_id bigint
        CONSTRAINT tms_attachment_fk_environment
            REFERENCES tms_environment,
    step_id        bigint
        CONSTRAINT tms_attachment_fk_step
            REFERENCES tms_step
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
