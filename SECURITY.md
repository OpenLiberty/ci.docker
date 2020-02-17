## Configuring Security


The following variables configure container security using the SocialLogin-1.0 feature. They can be expressed as Liberty server variables in a server xml file,
passed in as environment variables (not the most secure), or passed in as server variables through the Liberty Operator.

Security configuration takes effect when the container starts via [docker-server.sh](releases/latest/kernel/helpers/runtime/docker-server.sh), so it can be added later if desired.

These generally require the use of HTTPS. 

The variable `sec_sso_providers` must be defined and contain a space delimited list of the providers to use. If more than one is specified, the user can choose which one to authenticate with. Valid values are any of `oidc oauth facebook twitter github google linkedin`.

Each provider requires additional configuration.  Client ID and Client Secret are obtained from the provider.  RedirectToRPHostAndPort is the protocol, host, and port that the provider should send the browser back to after authentication.  In many containers, the pod cannot figure this out, so it will need to be specified. Other variables may be needed in some situations and are documented in detail in the [Open Liberty Documentation](https://openliberty.io/docs/ref/feature/#socialLogin-1.0.html) under each type of provider.

 name                                 | required for this provider |
|------------------------------------ | ------ |
|sec_sso_oidc_clientId                | y |
|sec_sso_oidc_clientSecret            | y |
|sec_sso_oidc_discoveryEndpoint       | y |
|sec_sso_oidc_redirectToRPHostAndPort | y |
|sec_sso_oidc_groupNameAttribute      | n |
|sec_sso_oidc_userNameAttribute      | n |
|sec_sso_oidc_displayName      | n |
|sec_sso_oidc_userInfoEndpointEnabled      | n |
|sec_sso_oidc_mapToUserRegistry |n|
|sec_sso_oidc_realmNameAttribute |n|
|sec_sso_oidc_scope      | n |
|sec_sso_oidc_tokenEndpointAuthMethod      | n |
|||
|sec_sso_oauth2_clientId             |y|
|sec_sso_oauth2_clientSecret             |y|
|sec_sso_oauth2_rediretToRPHostAndPort             |y|
|sec_sso_oauth2_tokenEndpoint             |y|
|sec_sso_oauth2_authorizationEndpoint             |y|
|sec_sso_oauth2_groupNameAttribute      | n |
|sec_sso_oauth2_userNameAttribute      | n |
|sec_sso_oauth2_displayName      | n |
|sec_sso_oauth2_mapToUserRegistry      | n |
|sec_sso_oauth2_realmNameAttribute      | n |
|sec_sso_oauth2_scope      | n |
|sec_sso_oauth2_tokenEndpointAuthMethod      | n |
|sec_sso_oauth2_accessTokenHeaderName      | n |
|sec_sso_oauth2_accessTokenRequired      | n |
|sec_sso_oauth2_userApiType      | n |
|||
|sec_sso_google_clientId       | y |
|sec_sso_google_clientSecret       | y |
|sec_sso_google_redirectToRPHostAndPort       | y |
|sec_sso_google_mapToUserRegistry       | n|
|||
|sec_sso_github_clientId       | y |
|sec_sso_github_clientSecret       | y |
|sec_sso_github_redirectToRPHostAndPort       | y |
|sec_sso_github_mapToUserRegistry       | n|
|sec_sso_github_hostname `(example: mycompany.github.com)`     | n|
|||
|sec_sso_facebook_clientId       | y |
|sec_sso_facebook_clientSecret       | y |
|sec_sso_facebook_redirectToRPHostAndPort       | y |
|sec_sso_facebook_mapToUserRegistry       | n|
|||
|sec_sso_twitter_clientId      | y |
|sec_sso_twitter_clientSecret      | y |
|sec_sso_twitter_redirectToRPHostAndPort      | y |
|sec_sso_twitter_mapToUserRegistry       | n|
|||
sec_sso_linkedin_clientId      | y |
sec_sso_linkedin_clientSecret      | y |
sec_sso_linkedin_redirectToRPHostAndPort      | y |
sec_sso_linkedin_mapToUserRegistry       | n|






