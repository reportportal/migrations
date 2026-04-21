ALTER TYPE integration_auth_flow_enum ADD VALUE IF NOT EXISTS 'SAML';

ALTER TABLE integration
    ADD COLUMN IF NOT EXISTS organization_id BIGINT REFERENCES organization (id) ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS integration_backup
(
    name          VARCHAR,
    auth_type     VARCHAR,
    enabled       BOOLEAN,
    params        JSONB,
    creator       VARCHAR,
    creation_date TIMESTAMP
);

INSERT INTO integration_backup (name, auth_type, enabled, params, creator)
SELECT i.name, it.name, i.enabled, i.params, i.creator
FROM integration i
         JOIN integration_type it ON i.type = it.id
WHERE it.name IN ('ldap', 'saml')
  AND it.group_type = 'AUTH'
  AND it.plugin_type = 'BUILT_IN';

INSERT INTO integration_backup (name, auth_type, enabled, params, creator, creation_date)
SELECT 'github', 'github', true,jsonb_build_object(
               'params', jsonb_build_object(
                       'clientId', r.client_id,
                       'clientSecret', r.client_secret,
                       'clientAuthMethod', r.client_auth_method,
                       'authGrantType', r.auth_grant_type,
                       'redirectUriTemplate', r.redirect_uri_template,
                       'authorizationUri', r.authorization_uri,
                       'tokenUri', r.token_uri,
                       'userInfoEndpointUri', r.user_info_endpoint_uri,
                       'userInfoEndpointNameAttr', r.user_info_endpoint_name_attr,
                       'jwkSetUri', r.jwk_set_uri,
                       'clientName', r.client_name,
                       'scopes', COALESCE(
                               (SELECT jsonb_agg(s.scope)
                                FROM oauth_registration_scope s
                                WHERE s.oauth_registration_fk = r.id),
                               '[]'::jsonb),
                       'restrictions', COALESCE(
                               (SELECT jsonb_object_agg('organizations', rs.vals)
                                FROM (SELECT type, jsonb_agg(value) AS vals
                                      FROM oauth_registration_restriction
                                      WHERE oauth_registration_fk = r.id
                                      GROUP BY type) rs),
                               '{}'::jsonb)
                   )
           ), 'backup@reportportal.internal', now()
FROM oauth_registration r;

DELETE
FROM integration_type
WHERE name IN ('ad', 'ldap', 'saml')
  AND group_type = 'AUTH'
  AND plugin_type = 'BUILT_IN';

DROP TABLE IF EXISTS oauth_registration_restriction;
DROP TABLE IF EXISTS oauth_registration_scope;
DROP TABLE IF EXISTS oauth_registration;
