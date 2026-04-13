INSERT INTO integration_type (enabled, name, creation_date, group_type, plugin_type, details)
VALUES (TRUE, 'ad', now(), 'AUTH', 'BUILT_IN', '{
  "details": {
    "id": "ad",
    "name": "Active Directory"
  }
}');

INSERT INTO integration_type (enabled, name, creation_date, group_type, plugin_type, auth_flow, details)
VALUES (TRUE, 'ldap', now(), 'AUTH', 'BUILT_IN', 'LDAP', '{
  "details": {
    "id": "ldap",
    "name": "LDAP"
  }
}');

INSERT INTO integration_type (enabled, name, creation_date, group_type, plugin_type, details)
VALUES (TRUE, 'saml', now(), 'AUTH', 'BUILT_IN', '{
  "details": {
    "id": "saml",
    "name": "SAML"
  }
}');



CREATE TABLE oauth_registration
(
    id                           VARCHAR(64) PRIMARY KEY,
    client_id                    VARCHAR(128) NOT NULL UNIQUE,
    client_secret                VARCHAR(256),
    client_auth_method           VARCHAR(64)  NOT NULL,
    auth_grant_type              VARCHAR(64),
    redirect_uri_template        VARCHAR(256),

    authorization_uri            VARCHAR(256),
    token_uri                    VARCHAR(256),

    user_info_endpoint_uri       VARCHAR(256),
    user_info_endpoint_name_attr VARCHAR(256),

    jwk_set_uri                  VARCHAR(256),
    client_name                  VARCHAR(128)
);

CREATE TABLE oauth_registration_scope
(
    id                    SERIAL
        CONSTRAINT oauth_registration_scope_pk PRIMARY KEY,
    oauth_registration_fk VARCHAR(128) REFERENCES oauth_registration (id) ON DELETE CASCADE,
    scope                 VARCHAR(256),
    CONSTRAINT oauth_registration_scope_unique UNIQUE (scope, oauth_registration_fk)
);

CREATE TABLE oauth_registration_restriction
(
    id                    SERIAL
        CONSTRAINT oauth_registration_restriction_pk PRIMARY KEY,
    oauth_registration_fk VARCHAR(128) REFERENCES oauth_registration (id) ON DELETE CASCADE,
    type                  VARCHAR(256) NOT NULL,
    value                 VARCHAR(256) NOT NULL,
    CONSTRAINT oauth_registration_restriction_unique UNIQUE (type, value, oauth_registration_fk)
);

DROP TABLE IF EXISTS integration_backup;
