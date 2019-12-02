CREATE TABLE ldap_synchronization_attributes (
  id        BIGSERIAL
    CONSTRAINT ldap_synchronization_attributes_pk PRIMARY KEY,
  email     VARCHAR(256),
  full_name VARCHAR(256),
  photo     VARCHAR(128)
);

CREATE TABLE active_directory_config (
  id                 BIGINT
    CONSTRAINT active_directory_config_pk PRIMARY KEY REFERENCES integration (id) ON DELETE CASCADE UNIQUE,
  url                VARCHAR(256),
  base_dn            VARCHAR(256),
  sync_attributes_id BIGINT REFERENCES ldap_synchronization_attributes (id) ON DELETE CASCADE,
  domain             VARCHAR(256)
);

CREATE TABLE ldap_config (
  id                  BIGINT
    CONSTRAINT ldap_config_pk PRIMARY KEY REFERENCES integration (id) ON DELETE CASCADE UNIQUE,
  url                 VARCHAR(256),
  base_dn             VARCHAR(256),
  sync_attributes_id  BIGINT REFERENCES ldap_synchronization_attributes (id) ON DELETE CASCADE,
  user_dn_pattern     VARCHAR(256),
  user_search_filter  VARCHAR(256),
  group_search_base   VARCHAR(256),
  group_search_filter VARCHAR(256),
  password_attributes VARCHAR(256),
  manager_dn          VARCHAR(256),
  manager_password    VARCHAR(256),
  passwordencodertype PASSWORD_ENCODER_TYPE
);

-------------------------------- SAML configurations ------------------------------
CREATE TABLE saml_provider_details (
  id                      BIGSERIAL PRIMARY KEY,
  idp_name                VARCHAR NOT NULL,
  idp_metadata_url        VARCHAR NOT NULL,
  idp_name_id             VARCHAR,
  idp_alias               VARCHAR,
  idp_url                 VARCHAR,
  full_name_attribute_id  VARCHAR,
  first_name_attribute_id VARCHAR,
  last_name_attribute_id  VARCHAR,
  email_attribute_id      VARCHAR NOT NULL,
  enabled                 BOOLEAN
);

CREATE OR REPLACE FUNCTION migrate_ad() RETURNS VOID AS
$$
DECLARE
  ad_config_id BIGINT;
  auth_params  JSONB;
  sync_attr_id BIGINT;
BEGIN
  ad_config_id := (SELECT i.id
                   FROM integration i
                          JOIN integration_type it ON i.type = it.id
                   WHERE i.name = 'ad'
                     AND it.group_type = cast('AUTH' AS INTEGRATION_GROUP_ENUM)
                     AND it.name = 'ad'
                     AND project_id ISNULL);

  auth_params := (SELECT params -> 'params' FROM integration WHERE id = ad_config_id);

  INSERT INTO active_directory_config(id, url, base_dn, domain)
  VALUES (ad_config_id, auth_params ->> 'url', auth_params ->> 'baseDn', auth_params ->> 'domain');

  INSERT INTO ldap_synchronization_attributes(email, full_name, photo)
  VALUES (auth_params ->> 'email', auth_params ->> 'fullName', auth_params ->> 'photo');
  sync_attr_id := (SELECT currval(pg_get_serial_sequence('ldap_synchronization_attributes', 'id')));

  UPDATE active_directory_config SET sync_attributes_id = sync_attr_id WHERE id = ad_config_id;

  UPDATE integration
  SET params = NULL,
      type   = (SELECT it.id FROM integration_type it WHERE it.name = 'ldap' AND it.group_type = cast('AUTH' AS INTEGRATION_GROUP_ENUM))
  WHERE id = ad_config_id;

  DELETE FROM integration_type WHERE name = 'ad' AND group_type = cast('AUTH' AS INTEGRATION_GROUP_ENUM);

END ;
$$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION migrate_ldap() RETURNS VOID AS
$$
DECLARE
  ldap_config_id BIGINT;
  auth_params    JSONB;
  sync_attr_id   BIGINT;
BEGIN
  ldap_config_id := (SELECT i.id
                     FROM integration i
                            JOIN integration_type it ON i.type = it.id
                     WHERE i.name = 'ldap'
                       AND it.group_type = cast('AUTH' AS INTEGRATION_GROUP_ENUM)
                       AND it.name = 'ldap'
                       AND project_id ISNULL);

  auth_params := (SELECT params -> 'params' FROM integration WHERE id = ldap_config_id);

  INSERT INTO ldap_config(id, url, base_dn, user_dn_pattern, user_search_filter, group_search_base, group_search_filter,
                          password_attributes, manager_dn, manager_password, passwordencodertype)
  VALUES (ldap_config_id, auth_params ->> 'url', auth_params ->> 'baseDn', auth_params ->> 'userDnPattern',
          auth_params ->> 'userSearchFilter',
          auth_params ->> 'groupSearchBase', auth_params ->> 'groupSearchFilter', auth_params ->> 'passwordAttribute',
          auth_params ->> 'managerDn', auth_params ->> 'managerPassword',
          cast(auth_params ->> 'passwordEncoderType' AS PASSWORD_ENCODER_TYPE));

  INSERT INTO ldap_synchronization_attributes(email, full_name, photo)
  VALUES (auth_params ->> 'email', auth_params ->> 'fullName', auth_params ->> 'photo');
  sync_attr_id := (SELECT currval(pg_get_serial_sequence('ldap_synchronization_attributes', 'id')));

  UPDATE ldap_config SET sync_attributes_id = sync_attr_id WHERE id = ldap_config_id;

  UPDATE integration
  SET params = NULL
  WHERE id = ldap_config_id;

END ;
$$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION migrate_saml() RETURNS VOID AS
$$
DECLARE
  row INTEGRATION;
BEGIN
  FOR row IN SELECT i.id,
                    i.name,
                    i.project_id,
                    i.type,
                    i.enabled,
                    i.params -> 'params',
                    i.creator,
                    i.creation_date
             FROM integration i
                    JOIN integration_type it ON i.type = it.id
             WHERE it.name = 'saml'
               AND it.group_type = cast('AUTH' AS INTEGRATION_GROUP_ENUM)
               AND i.project_id ISNULL
    LOOP
      INSERT INTO saml_provider_details(idp_name, idp_metadata_url, idp_name_id, idp_alias, idp_url, full_name_attribute_id,
                                        first_name_attribute_id, last_name_attribute_id, email_attribute_id, enabled)
      VALUES (row.name, row.params ->> 'identityProviderMetadataUrl', row.params ->> 'identityProviderNameId',
              row.params ->> 'identityProviderAlias', row.params ->> 'identityProviderUrl', row.params ->> 'fullNameAttribute',
              row.params ->> 'firstNameAttribute', row.params ->> 'lastNameAttribute', row.params ->> 'emailAttribute', row.enabled);
      DELETE FROM integration WHERE id = row.id;
    END LOOP;
  DELETE FROM integration_type WHERE name = 'saml' AND group_type = cast('AUTH' AS INTEGRATION_GROUP_ENUM);
END;
$$
  LANGUAGE plpgsql;

SELECT migrate_ad();
SELECT migrate_ldap();
SELECT migrate_saml();

DROP FUNCTION IF EXISTS migrate_saml();
DROP FUNCTION IF EXISTS migrate_ldap();
DROP FUNCTION IF EXISTS migrate_ad();


