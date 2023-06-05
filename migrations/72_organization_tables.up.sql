CREATE TABLE organization
(
    id bigserial PRIMARY KEY,
    name text NOT NULL
);

CREATE TABLE organization_attribute
(
    id bigserial PRIMARY KEY,
    key varchar(256) NOT NULL,
    value varchar(256) NOT NULL,
    system boolean,
    organization_id bigint,
    FOREIGN KEY (organization_id)
        REFERENCES organization(id)
);
