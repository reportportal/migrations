UPDATE oauth_registration SET redirect_uri_template = '{baseUrl}/sso/login/{registrationId}' where id = 'github'