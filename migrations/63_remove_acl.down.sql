CREATE TABLE acl_sid (
    id        BIGSERIAL    NOT NULL PRIMARY KEY,
    principal BOOLEAN      NOT NULL,
    sid       VARCHAR(128) NOT NULL REFERENCES users (login) ON DELETE CASCADE,
    CONSTRAINT unique_uk_1 UNIQUE (sid, principal)
);

CREATE INDEX acl_sid_idx
    ON acl_sid (sid);

CREATE TABLE acl_class (
    id            BIGSERIAL    NOT NULL PRIMARY KEY,
    class         VARCHAR(128) NOT NULL,
    class_id_type VARCHAR(128),
    CONSTRAINT unique_uk_2 UNIQUE (class)
);

CREATE TABLE acl_object_identity (
    id                 BIGSERIAL PRIMARY KEY,
    object_id_class    BIGINT      NOT NULL,
    object_id_identity VARCHAR(36) NOT NULL,
    parent_object      BIGINT,
    owner_sid          BIGINT,
    entries_inheriting BOOLEAN     NOT NULL,
    CONSTRAINT unique_uk_3 UNIQUE (object_id_class, object_id_identity),
    CONSTRAINT foreign_fk_1 FOREIGN KEY (parent_object) REFERENCES acl_object_identity (id),
    CONSTRAINT foreign_fk_2 FOREIGN KEY (object_id_class) REFERENCES acl_class (id),
    CONSTRAINT foreign_fk_3 FOREIGN KEY (owner_sid) REFERENCES acl_sid (id) ON DELETE CASCADE
);

CREATE TABLE acl_entry (
    id                  BIGSERIAL PRIMARY KEY,
    acl_object_identity BIGINT  NOT NULL,
    ace_order           INT     NOT NULL,
    sid                 BIGINT  NOT NULL,
    mask                INTEGER NOT NULL,
    granting            BOOLEAN NOT NULL,
    audit_success       BOOLEAN NOT NULL,
    audit_failure       BOOLEAN NOT NULL,
    CONSTRAINT unique_uk_4 UNIQUE (acl_object_identity, ace_order),
    CONSTRAINT foreign_fk_4 FOREIGN KEY (acl_object_identity) REFERENCES acl_object_identity (id) ON DELETE CASCADE,
    CONSTRAINT foreign_fk_5 FOREIGN KEY (sid) REFERENCES acl_sid (id) ON DELETE CASCADE
);

ALTER TABLE owned_entity ADD COLUMN shared BOOLEAN DEFAULT FALSE;
ALTER TABLE owned_entity RENAME TO shareable_entity;

CREATE OR REPLACE FUNCTION update_share_flag()
    RETURNS TRIGGER AS
$$
BEGIN
    UPDATE dashboard_widget
    SET share = (SELECT shared FROM shareable_entity WHERE shareable_entity.id = new.id)
    WHERE widget_id = new.id;
    RETURN new;
END;
$$
    LANGUAGE plpgsql;

CREATE TRIGGER after_widget_update
    AFTER UPDATE
    ON widget
    FOR EACH ROW
EXECUTE PROCEDURE update_share_flag();